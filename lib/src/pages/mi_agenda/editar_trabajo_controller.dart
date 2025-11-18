// lib/src/pages/mi_agenda/editar_trabajo_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redecom_app/src/models/agenda.dart';
import 'package:redecom_app/src/models/imagen_instalacion.dart';
import 'package:redecom_app/src/providers/agenda_provider.dart';
import 'package:redecom_app/src/providers/instalacion_provider.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:redecom_app/src/utils/auth_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:redecom_app/src/utils/socket_service.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/providers/images_provider.dart';

class EditarTrabajoController extends GetxController {
  // --------- Dependencias ---------

  final _imgsNew = ImagesProvider();
  final _agendaProv = AgendaProvider();
  final _picker = ImagePicker();
  final AuthService authService = Get.find<AuthService>();
  // --------- Estado principal ---------
  final trabajo = Rxn<Agenda>();

  final SocketService _socket = Get.find<SocketService>();

  final RxBool _isEmitting = false.obs;
  final isSaving = false.obs;

  // Campos “canónicos” que sueles usar (puedes ajustar orden/nombres si tu backend define otros)
  final List<String> camposInstalacion = const [
    'fachada',
    'router',
    'ont',
    'potencia',
    'speedtest',
    'cable_1',
    'cable_2',
    'equipo_1',
    'equipo_2',
    'equipo_3',
  ];

  final List<String> camposVisita = const ['img_1', 'img_2', 'img_3', 'img_4'];

  // Mapas campo -> ImagenInstalacion (para miniaturas)
  final imagenesInstalacion = <String, ImagenInstalacion>{}.obs;
  final imagenesVisita = <String, ImagenInstalacion>{}.obs;

  // Solución
  final solucionController = TextEditingController();

  // --- NUEVO: terminar instalación ---
  final coordCtrl = TextEditingController();
  final ipCtrl = TextEditingController();
  final isTerminating = false.obs;
  bool _isPicking = false;

  final _instProv = InstalacionProvider();

  bool get esInstalacion =>
      (trabajo.value?.tipo.toUpperCase() ?? '') == 'INSTALACION';
  bool get esTrasladoExt =>
      (trabajo.value?.tipo.toUpperCase() ?? '') == 'TRASLADO EXT';

  // Preferimos el id de la agenda como entity_id de VIS/LOS; fallback a idTipo
  int get _ageIdVisita {
    final t = trabajo.value;
    if (t == null) return 0;
    return (t.id != 0) ? t.id : t.idTipo;
  }

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments;
    if (args is Agenda) {
      trabajo.value = args;

      _cargarMiniaturas();

      solucionController.text = args.solucion?.trim() ?? '';
      /*
      if (esInstalacion) {
        coordCtrl.text = args.coordenadas.trim(); // 👈 prefill si aplica
      }*/
    } else {
      SnackbarService.warning('No se recibió el trabajo a editar');
    }
  }

  Future<void> seleccionarImagenInstalacion(String campo) async {
    final t = trabajo.value;
    if (t == null || t.ordIns == 0) {
      SnackbarService.warning('Este trabajo no tiene ORD_INS');
      return;
    }
    if (_isPicking) return;
    _isPicking = true;

    try {
      final src = await _elegirFuenteImagen();
      if (src == null) return; // canceló

      // Asegura que la hoja terminó de cerrarse antes de abrir picker
      await Future.delayed(const Duration(milliseconds: 120));

      await _tomarOSubir(
        source: src,
        campo: campo,
        tabla: 'neg_t_instalaciones',
        id: t.ordIns.toString(),
        directorio: t.ordIns.toString(),
      );
    } finally {
      _isPicking = false;
    }
  }

  Future<void> seleccionarImagenVisita(String campo) async {
    final t = trabajo.value;
    final ageId = _ageIdVisita;
    if (t == null || ageId == 0) {
      SnackbarService.warning('Este VIS/LOS no tiene ID de agenda');
      return;
    }
    if (_isPicking) return;
    _isPicking = true;

    try {
      final src = await _elegirFuenteImagen();
      if (src == null) return;

      await Future.delayed(const Duration(milliseconds: 120));

      await _tomarOSubir(
        source: src,
        campo: campo,
        tabla: 'neg_t_vis', // para el switch interno (module='visitas')
        id: ageId.toString(), // << entity_id = age_id
        directorio: t.ordIns.toString(), // << lo usaremos como ord_ins
      );
    } finally {
      _isPicking = false;
    }
  }

  Future<ImageSource?> _elegirFuenteImagen() async {
    // ✅ Forzar cámara (simple de revertir)
    // return ImageSource.camera;

    //----------MOSTRAR OPCION SELECCIONAR DESDE GALERIA

    return await Get.bottomSheet<ImageSource>(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tomar foto'),
              onTap: () => Get.back(result: ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () => Get.back(result: ImageSource.gallery),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Future<void> _tomarOSubir({
    required ImageSource source,
    required String campo,
    required String tabla,
    required String id,
    required String directorio,
  }) async {
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 92,
      maxWidth: 2048,
    );
    if (picked == null) return;

    final original = File(picked.path);

    try {
      // 1) Comprimir
      final comprimida = await _comprimirImagen(
        original,
        maxWidth: 1000,
        calidad: 85,
      );

      // 2) Estampar (técnico, fecha, coords) como antes
      final estampada = await _procesarImagenConTexto(comprimida, campo);

      // 3) Subir
      /*
      await _imgsProv.postImagenUnitaria(
        tabla: tabla,
        id: id,
        campo: campo,
        directorio: directorio,
        file: estampada,
      );
*/

      // Nuevo backend:
      // instalaciones => module='instalaciones', tag = campo, position=0
      // visitas       => module='visitas',       tag = 'img', position = N (de 'img_N')
      late final String module;
      late final String tag;
      int position = 0;
      String? ordIns; // << NUEVO

      if (tabla == 'neg_t_instalaciones') {
        module = 'instalaciones';
        tag = campo; // fachada, router, ont, ...
        position = 0;
        ordIns = null;
      } else {
        module = 'visitas';
        tag = 'img';
        final m = RegExp(r'^img_(\d+)$').firstMatch(campo);
        position = m != null ? int.parse(m.group(1)!) : 0;
        ordIns = directorio; // << aquí directorio = ord_ins
      }
      await _imgsNew.upload(
        module: module,
        entityId: id,
        tag: tag,
        position: position,
        file: estampada,
        ordIns:
            ordIns, // << clave para que multer guarde en instalaciones/<ord_ins>/<age_id>/
      );

      // 4) Refrescar SOLO esa miniatura
      final esInst = tabla == 'neg_t_instalaciones';
      await _actualizarMiniatura(esInst ? 'inst' : 'vis', campo);

      SnackbarService.success('Imagen actualizada');
    } catch (e) {
      SnackbarService.error('No se pudo subir la imagen');
    }
  }

  Future<File> _comprimirImagen(
    File original, {
    int maxWidth = 1000,
    int calidad = 85,
  }) async {
    final bytes = await original.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('No se pudo leer la imagen');

    final resized = img.copyResize(image, width: maxWidth);
    final out = img.encodeJpg(resized, quality: calidad);

    final tmp = await getTemporaryDirectory();
    final path = '${tmp.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return File(path)..writeAsBytesSync(out);
  }

  Future<File> _procesarImagenConTexto(File original, String campo) async {
    final bytes = await original.readAsBytes();
    img.Image? im = img.decodeImage(bytes);
    if (im == null) throw Exception('No se pudo procesar la imagen');

    im = img.bakeOrientation(im);

    // Redimensionado suave (coincide con compresión previa)
    final resized = img.copyResize(im, width: im.width);

    final font = img.arial_48;

    // Construir texto como antes:
    final now = DateTime.now();
    final fecha =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final tecnico = (authService.currentUser?.username ?? '').trim();

    String texto = '$campo         Tecnico: $tecnico';

    try {
      // permisos + posición
      bool service = await Geolocator.isLocationServiceEnabled();
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (service &&
          perm != LocationPermission.denied &&
          perm != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition();
        texto +=
            '\n ${pos.latitude.toStringAsFixed(5)},${pos.longitude.toStringAsFixed(5)} $fecha   ';
      } else {
        texto += '\nSin coordenadas';
      }
    } catch (_) {
      texto += '\nSin coordenadas';
    }

    // Banda blanca superior (como hacías)
    const bandHeight = 120;
    img.fillRect(
      resized,
      0,
      0,
      resized.width,
      bandHeight,
      img.getColor(255, 255, 255),
    );

    // Texto rojo
    img.drawString(
      resized,
      font,
      10,
      10,
      texto,
      color: img.getColor(255, 0, 0),
    );

    final out = img.encodeJpg(resized, quality: 85);

    final tmp = await getTemporaryDirectory();
    final newPath =
        '${tmp.path}/img_mod_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final stamped = File(newPath)..writeAsBytesSync(out, flush: true);
    return stamped;
  }

  /*
  Future<void> terminarInstalacion() async {
    final t = trabajo.value;
    if (t == null) {
      SnackbarService.warning('No hay trabajo cargado');
      return;
    }
    if (!esInstalacion) {
      SnackbarService.warning('Este trabajo no es una instalación');
      return;
    }
    if (t.ordIns == 0) {
      SnackbarService.warning('El trabajo no tiene ORD_INS');
      return;
    }

    final coords = coordCtrl.text.trim();
    final ip = ipCtrl.text.trim();
    if (coords.isEmpty || ip.isEmpty) {
      SnackbarService.warning('Coordenadas e IP son obligatorias');
      return;
    }

    try {
      isTerminating.value = true;
      await _instProv.terminarInstalacion(
        ordIns: t.ordIns,
        coordenadas: coords,
        ip: ip,
      );
      SnackbarService.success('Instalación actualizada correctamente');

      // Si quieres volver atrás confirmando
      // Get.back(result: true);

      // O refrescar algo local si aplica
    } catch (e) {
      SnackbarService.error(e.toString());
    } finally {
      isTerminating.value = false;
    }
  }
*/
  // ---------- Carga de miniaturas ----------
  Future<void> _cargarMiniaturas() async {
    final t = trabajo.value;
    if (t == null) return;

    try {
      // Instalación (ord_ins) SIEMPRE que exista
      if (t.ordIns != 0) {
        final mapInst = await _imgsNew.listInstalacionAsLegacyMap(
          t.ordIns.toString(),
        );
        imagenesInstalacion
          ..clear()
          ..assignAll(mapInst);
        // debug opcional:
        // print('[IMG] instalacion keys: ${imagenesInstalacion.keys.toList()}');
      } else {
        imagenesInstalacion.clear();
      }

      // VIS/LOS/RETIRO: cargar imágenes de la visita (idTipo) desde el NUEVO backend
      final tipo = (t.tipo).toUpperCase();
      final esVis = tipo == 'VISITA' || tipo == 'LOS' || tipo == 'RETIRO';

      if (esVis) {
        final ageId = _ageIdVisita; // 👈 preferimos el id de Agenda

        if (ageId != 0) {
          final mapVis = await _imgsNew.listVisitaAsLegacyMap(ageId.toString());
          imagenesVisita
            ..clear()
            ..assignAll(mapVis);
        } else {
          imagenesVisita.clear();
        }
      }
    } catch (e) {
      SnackbarService.error('No se pudieron cargar imágenes: $e');
    }
  }

  // Recarga una sola miniatura tras subir
  Future<void> _actualizarMiniatura(String tipo, String campo) async {
    final t = trabajo.value;
    if (t == null) return;

    try {
      if (tipo == 'inst') {
        /*
        final map = await _imgsProv.getImagenesPorAgenda(
          'neg_t_instalaciones',
          t.ordIns.toString(),
        );*/

        final map = await _imgsNew.listInstalacionAsLegacyMap(
          t.ordIns.toString(),
        );
        final nuevo = map[campo];
        if (nuevo != null) {
          imagenesInstalacion[campo] = nuevo;
          imagenesInstalacion.refresh();
        }
      } else {
        /*
        final map = await _imgsProv.getImagenesPorAgenda(
          'neg_t_vis',
          t.idTipo.toString(),
        );
*/
        //  final map = await _imgsNew.listVisitaAsLegacyMap(t.idTipo.toString());
        final map = await _imgsNew.listVisitaAsLegacyMap(
          _ageIdVisita.toString(),
        );
        final nuevo = map[campo];
        if (nuevo != null) {
          imagenesVisita[campo] = nuevo;
          imagenesVisita.refresh();
        }
      }
    } catch (_) {
      // silencio: si falla la mini recarga puntual, no caemos
    }
  }

  Future<String> _sellarSolucion(String base) async {
    // Fecha/hora local en formato dd/MM/yyyy HH:mm
    final now = DateTime.now();
    final fecha =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Técnico (username o name; ajusta si prefieres otro campo)
    final tecnico =
        (authService.currentUser?.username ??
                authService.currentUser?.name ??
                'desconocido')
            .trim();

    // Coordenadas (permite “Sin coordenadas” si no hay permisos/servicio)
    String coordsTxt = 'Sin coordenadas';
    try {
      final service = await Geolocator.isLocationServiceEnabled();
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (service &&
          perm != LocationPermission.denied &&
          perm != LocationPermission.deniedForever) {
        final pos = await Geolocator.getCurrentPosition();
        coordsTxt =
            '${pos.latitude.toStringAsFixed(5)},${pos.longitude.toStringAsFixed(5)}';
      }
    } catch (_) {
      // mantenemos "Sin coordenadas"
    }

    // Sello (se agrega al final de la solución ingresada por el técnico)
    final sello = '\n\n— Guardada por: $tecnico | $fecha | $coordsTxt';
    return base + sello;
  }

  Future<void> abrirSelectorCoordenadas() async {
    // Centrar en lo ya escrito, si es válido
    LatLng? initial;
    final raw = coordCtrl.text.trim();
    final re = RegExp(r'^\s*(-?\d+(\.\d+)?)\s*,\s*(-?\d+(\.\d+)?)\s*$');
    final m = re.firstMatch(raw);
    if (m != null) {
      final lat = double.tryParse(m.group(1)!);
      final lng = double.tryParse(m.group(3)!);
      if (lat != null && lng != null) initial = LatLng(lat, lng);
    }

    final result = await Get.toNamed('/map/seleccionar', arguments: initial);
    if (result is LatLng) {
      coordCtrl.text =
          '${result.latitude.toStringAsFixed(6)},${result.longitude.toStringAsFixed(6)}';
    }
  }

  void _emitTrabajoCulminado(Agenda t) {
    if (_isEmitting.value) return; // evita duplicados si algo dispara 2 veces
    _isEmitting.value = true;
    try {
      final tecnicoId =
          GetStorage().read('usuario_id') ?? authService.currentUser?.id;
      final payload = {
        'evento': 'trabajoCulminado',
        'trabajo_id': t.id,
        'tipo': t.tipo,
        'estado': 'CULMINADO',
        'ord_ins': t.ordIns, // 0 si no aplica
        'id_tipo': t.idTipo, // 0 si no aplica (VIS/LOS/RETIRO)
        'tecnico_id': tecnicoId,
        'timestamp': DateTime.now().toIso8601String(),
      };
      _socket.emit('trabajoCulminado', payload);
    } finally {
      _isEmitting.value = false;
    }
  }

  // ---------- Guardar solución ----------
  Future<void> guardarSolucion() async {
    final t = trabajo.value;
    if (t == null) return;

    final sol = solucionController.text.trim();
    if (sol.isEmpty) {
      SnackbarService.warning('Ingresa la solución antes de guardar');
      return;
    }

    isSaving.value = true;
    try {
      final solSellada = await _sellarSolucion(sol);
      final actualizado = t.copyWith(estado: 'CONCLUIDO', solucion: solSellada);
      await _agendaProv.actualizarAgendaSolucionByAgenda(t.id, actualizado);
      trabajo.value = actualizado;

      // 👉 emite
      _emitTrabajoCulminado(actualizado);

      SnackbarService.success('Solución guardada');
      Get.back(result: true);
    } catch (e) {
      SnackbarService.error('No se pudo guardar la solución: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> guardarTodo() async {
    if (isSaving.value || isTerminating.value) return;

    final t = trabajo.value;
    if (t == null) {
      SnackbarService.error('No hay trabajo cargado');
      return;
    }

    bool finalizoInstalacion = false;
    bool actualizoSolucion = false;

    try {
      isSaving.value = true;

      // 1) Si es INSTALACION: terminar instalación (coords + ip)
      if (esInstalacion) {
        final coords = coordCtrl.text.trim();
        final ip = ipCtrl.text.trim();

        if (!_validCoords(coords)) {
          SnackbarService.warning(
            'Ingresa coordenadas válidas: ej. -0.938606,-78.600826',
          );
          isSaving.value = false;
          return;
        }
        if (!_validIp(ip)) {
          SnackbarService.warning('Ingresa una IP válida: ej. 192.168.1.10');
          isSaving.value = false;
          return;
        }
        if (t.ordIns == 0) {
          SnackbarService.warning('El trabajo no tiene ORD_INS');
          isSaving.value = false;
          return;
        }

        isTerminating.value = true;
        await _instProv.terminarInstalacion(
          ordIns: t.ordIns,
          coordenadas: coords,
          ip: ip,
        );
        isTerminating.value = false;
        finalizoInstalacion = true;
      }

      // 2) Guardar solución (si hay texto)
      final sol = solucionController.text.trim();
      if (sol.isNotEmpty) {
        final solSellada = await _sellarSolucion(sol);
        final actualizado = t.copyWith(
          estado: 'CONCLUIDO',
          solucion: solSellada,
        );
        await _agendaProv.actualizarAgendaSolucionByAgenda(t.id, actualizado);
        trabajo.value = actualizado; // refresca en memoria
        actualizoSolucion = true;
      }

      SnackbarService.success('Cambios guardados');

      // 3) Emitir UNA SOLA VEZ si hubo alguna acción que concluya el trabajo
      final tFinal = trabajo.value ?? t;
      if (finalizoInstalacion || actualizoSolucion) {
        _emitTrabajoCulminado(tFinal);
      }

      await Future.delayed(const Duration(milliseconds: 500));
      Get.offAllNamed('/tecnico/mi-agenda');
    } catch (e) {
      // ignore: avoid_print
      print('❌ guardarTodo error: $e');
      SnackbarService.error('No se pudo guardar');
    } finally {
      isTerminating.value = false;
      isSaving.value = false;
    }
  }

  Future<void> terminarInstalacion() async {
    final t = trabajo.value;
    if (t == null) {
      SnackbarService.warning('No hay trabajo cargado');
      return;
    }
    if (!esInstalacion) {
      SnackbarService.warning('Este trabajo no es una instalación');
      return;
    }
    if (t.ordIns == 0) {
      SnackbarService.warning('El trabajo no tiene ORD_INS');
      return;
    }

    final coords = coordCtrl.text.trim();
    final ip = ipCtrl.text.trim();
    if (coords.isEmpty || ip.isEmpty) {
      SnackbarService.warning('Coordenadas e IP son obligatorias');
      return;
    }

    try {
      isTerminating.value = true;
      await _instProv.terminarInstalacion(
        ordIns: t.ordIns,
        coordenadas: coords,
        ip: ip,
      );
      SnackbarService.success('Instalación actualizada correctamente');

      // 👉 emite
      _emitTrabajoCulminado(t);
    } catch (e) {
      SnackbarService.error(e.toString());
    } finally {
      isTerminating.value = false;
    }
  }

  // ---------- helpers privados ----------
  bool _validCoords(String s) {
    // form: lat,lon  (permite espacios, +/- y decimales)
    final re = RegExp(r'^\s*-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?\s*$');
    return re.hasMatch(s);
  }

  bool _validIp(String s) {
    // IPv4 simple
    final re = RegExp(
      r'^(25[0-5]|2[0-4]\d|1?\d?\d)\.'
      r'(25[0-5]|2[0-4]\d|1?\d?\d)\.'
      r'(25[0-5]|2[0-4]\d|1?\d?\d)\.'
      r'(25[0-5]|2[0-4]\d|1?\d?\d)$',
    );
    return re.hasMatch(s);
  }

  @override
  void onClose() {
    solucionController.dispose();
    coordCtrl.dispose();
    ipCtrl.dispose();
    super.onClose();
  }
}
