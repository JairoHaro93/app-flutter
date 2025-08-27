import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'package:redecom_app/src/models/agenda.dart';
import 'package:redecom_app/src/models/imagen_instalacion.dart';
import 'package:redecom_app/src/providers/agenda_provider.dart';
import 'package:redecom_app/src/providers/soporte_provider.dart';
import 'package:redecom_app/src/providers/imagenes_provider.dart';
import 'package:redecom_app/src/providers/vis_provider.dart';
import 'package:redecom_app/src/utils/auth_service.dart';
import 'package:redecom_app/src/utils/socket_service.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';

class EditarAgendaController extends GetxController {
  // Providers / services
  final agendaProvider = AgendaProvider();
  final soporteProvider = SoporteProvider();
  final imagenesProvider = ImagenesProvider();
  final visProvider = VisProvider();
  final socketService = Get.find<SocketService>();
  final authService = Get.find<AuthService>();

  // Estado
  final trabajo = Rxn<Agenda>(); // ✅ reactivo y nullable
  final solucionController = TextEditingController();
  final isSaving = false.obs;

  final imagenesInstalacion = <String, ImagenInstalacion>{}.obs;
  final imagenesVisita = <String, ImagenInstalacion>{}.obs;

  // Campos canónicos
  List<String> get camposInstalacion => const [
    'fachada',
    'router',
    'potencia',
    'ont',
    'speedtest',
    'cable_1',
    'cable_2',
    'equipo_1',
    'equipo_2',
    'equipo_3',
  ];

  // Ajustados a tu backend VIS/LOS
  List<String> get camposVisita => const ['img_1', 'img_2', 'img_3', 'img_4'];

  // Flags de tipo, seguros contra null
  bool get esInstalacion =>
      (trabajo.value?.tipo ?? '').toUpperCase() == 'INSTALACION';
  bool get esVisOLos {
    final t = (trabajo.value?.tipo ?? '').toUpperCase();
    return t == 'VISITA' || t == 'LOS';
  }

  @override
  void onInit() {
    super.onInit();
    // Carga de argumentos segura
    if (Get.arguments is Agenda) {
      trabajo.value = Get.arguments as Agenda;
      solucionController.text = trabajo.value?.solucion ?? '';
      _cargarImagenes();
    } else {
      SnackbarService.error('No se recibió el trabajo a editar');
      // Sal del flujo de edición con un after-frame para evitar pops en build
      Future.microtask(() => Get.offAllNamed('/tecnico/mi-agenda'));
    }
  }

  // ======================================================
  // CARGA INICIAL DE IMÁGENES
  // ======================================================
  Future<void> _cargarImagenes() async {
    final t = trabajo.value;
    if (t == null) return;

    try {
      // Instalación (por ORD_INS)
      if (t.ordIns != 0) {
        final inst = await imagenesProvider.getImagenesPorAgenda(
          'neg_t_instalaciones',
          t.ordIns.toString(),
        );
        imagenesInstalacion.assignAll(inst);
        // ignore: avoid_print
        print('🖼️ Inst: ${inst.keys.toList()}');
      } else {
        imagenesInstalacion.clear();
      }

      // VIS/LOS (por idTipo)
      if (esVisOLos && (t.idTipo != 0)) {
        final vis = await imagenesProvider.getImagenesPorAgenda(
          'neg_t_vis',
          t.idTipo.toString(),
        );
        imagenesVisita.assignAll(vis);
        // ignore: avoid_print
        print('🖼️ Vis/Los: ${vis.keys.toList()}');
      } else {
        imagenesVisita.clear();
      }
    } catch (e) {
      // ignore: avoid_print
      print('❌ No se pudieron cargar imágenes: $e');
      SnackbarService.error('No se pudieron cargar las imágenes');
    }
  }

  // ======================================================
  // SELECCIÓN / SUBIDA DE IMÁGENES
  // ======================================================
  Future<void> seleccionarImagenInstalacion(String campo) async {
    final t = trabajo.value;
    if (t == null) return;

    if (t.ordIns == 0) {
      SnackbarService.warning('Este trabajo no tiene ORD_INS');
      return;
    }
    await _mostrarOpcionesImagen(
      campo: campo,
      tabla: 'neg_t_instalaciones',
      id: t.ordIns.toString(),
      directorio: t.ordIns.toString(),
    );
  }

  Future<void> seleccionarImagenVisita(String campo) async {
    final t = trabajo.value;
    if (t == null) return;

    if (!esVisOLos || t.idTipo == 0) {
      SnackbarService.warning('Este trabajo no tiene VIS/LOS asociado');
      return;
    }
    await _mostrarOpcionesImagen(
      campo: campo,
      tabla: 'neg_t_vis',
      id: t.idTipo.toString(),
      directorio: t.ordIns.toString(), // agrupas por ORD_INS
    );
  }

  Future<void> _mostrarOpcionesImagen({
    required String campo,
    required String tabla,
    required String id,
    required String directorio,
  }) async {
    final picker = ImagePicker();

    await Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Tomar foto'),
              onTap: () async {
                Get.back();
                final x = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1600,
                  imageQuality: 85,
                );
                if (x != null) {
                  await _subirImagen(
                    campo,
                    tabla,
                    id,
                    directorio,
                    File(x.path),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () async {
                Get.back();
                final x = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 1600,
                  imageQuality: 85,
                );
                if (x != null) {
                  await _subirImagen(
                    campo,
                    tabla,
                    id,
                    directorio,
                    File(x.path),
                  );
                }
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Future<void> _subirImagen(
    String campo,
    String tabla,
    String id,
    String directorio,
    File archivoOriginal,
  ) async {
    try {
      final inicio = DateTime.now();

      // temp dir en main isolate
      final tmpDir = await getTemporaryDirectory();
      final outDir = tmpDir.path;

      // 1) Comprimir en isolate (900px)
      final comprimidaPath = await compute<_CompressArgs, String>(
        _compressImageCompute,
        _CompressArgs(
          inPath: archivoOriginal.path,
          outDir: outDir,
          maxWidth: 900,
          quality: 75,
        ),
      );
      final comprimida = File(comprimidaPath);

      // 2) Datos dinámicos
      final (lat, lng) = await _tryGetLatLng();
      final tecnico = authService.currentUser?.username ?? '';
      final ahora = DateTime.now();

      // 3) Calidad por tipo de campo
      final overlayQuality =
          (campo == 'speedtest' || campo == 'potencia') ? 82 : 75;

      // 4) Overlay sin reescalar otra vez (keepWidth=900)
      final overlayPath = await compute<_OverlayArgs, String>(
        _overlayImageCompute,
        _OverlayArgs(
          inPath: comprimida.path,
          outDir: outDir,
          campo: campo,
          tecnico: tecnico,
          fechaHora: ahora,
          lat: lat,
          lng: lng,
          quality: overlayQuality,
          keepWidth: 900,
        ),
      );
      final imagenProcesada = File(overlayPath);

      // 5) Subir
      await imagenesProvider.subirImagen(
        tabla: tabla,
        id: id,
        campo: campo,
        directorio: directorio,
        file: imagenProcesada,
      );

      // 6) Recargar galería (con retry)
      await _recargarImagenesConRetry(tabla, id);

      final fin = DateTime.now();
      // ignore: avoid_print
      print('⏱️ Total subida ${fin.difference(inicio)}');
      SnackbarService.success('✅ Imagen actualizada');
    } catch (e) {
      // ignore: avoid_print
      print('❌ _subirImagen error: $e');
      SnackbarService.error('❌ No se pudo subir la imagen');
    }
  }

  Future<void> _recargarImagenesConRetry(String tabla, String id) async {
    const delays = [300, 700, 1200]; // ms
    for (final d in delays) {
      await Future.delayed(Duration(milliseconds: d));
      try {
        final mapa = await imagenesProvider.getImagenesPorAgenda(tabla, id);
        if (tabla == 'neg_t_instalaciones') {
          imagenesInstalacion.assignAll(mapa);
        } else {
          imagenesVisita.assignAll(mapa);
        }
        return;
      } catch (_) {
        // reintenta
      }
    }
    // último intento
    final mapa = await imagenesProvider.getImagenesPorAgenda(tabla, id);
    if (tabla == 'neg_t_instalaciones') {
      imagenesInstalacion.assignAll(mapa);
    } else {
      imagenesVisita.assignAll(mapa);
    }
  }

  // ======================================================
  // GUARDAR SOLUCIÓN
  // ======================================================
  Future<void> guardarSolucion() async {
    final t = trabajo.value;
    if (t == null) return;

    final base = solucionController.text.trim();
    if (base.isEmpty) {
      SnackbarService.warning('Ingresa una solución');
      return;
    }

    isSaving.value = true;
    try {
      // 1) construir solución con metadatos (técnico/fecha/coords)
      final (lat, lng) = await _tryGetLatLng();
      final solucionFinal = _buildSolucionFinal(
        base: base,
        tecnico: authService.currentUser?.username ?? '',
        lat: lat,
        lng: lng,
        fecha: DateTime.now(),
      );

      // 2) actualizar AGENDA (CONCLUIDO + solución)
      final actualizado = t.copyWith(
        estado: 'CONCLUIDO',
        solucion: solucionFinal,
      );

      await agendaProvider.actualizarAgendaSolucionByAgenda(
        actualizado.id,
        actualizado,
      );

      // 3) VIS/LOS: marca como RESUELTO si corresponde
      if (esVisOLos && t.idTipo != 0) {
        await visProvider.updateVisById(t.idTipo, 'RESUELTO', solucionFinal);
      }

      // 4) SOPORTE si aplica
      if (t.idSop != 0) {
        await soporteProvider.actualizarEstadoSop(t.idSop, {
          'reg_sop_estado': 'RESUELTO',
          'reg_sop_sol_det': solucionFinal,
        });
      }

      // 5) Notificar por socket y navegar a Agenda
      final userId = GetStorage().read('usuario_id');
      if (userId != null) {
        socketService.emit('trabajoCulminado', {'tecnicoId': userId});
      }

      SnackbarService.success('✅ Agenda actualizado correctamente');
      await Future.delayed(const Duration(milliseconds: 250));
      Get.offAllNamed('/tecnico/mi-agenda');
    } catch (e) {
      // ignore: avoid_print
      print('❌ guardarSolucion error: $e');
      SnackbarService.error('❌ No se pudo guardar la solución');
    } finally {
      isSaving.value = false;
    }
  }

  /// Construye la solución final con metadatos mínimos.
  String _buildSolucionFinal({
    required String base,
    required String tecnico,
    required DateTime fecha,
    double? lat,
    double? lng,
  }) {
    String two(int n) => n.toString().padLeft(2, '0');
    final fechaStr =
        '${two(fecha.day)}/${two(fecha.month)}/${fecha.year} ${two(fecha.hour)}:${two(fecha.minute)}';

    final geo =
        (lat != null && lng != null)
            ? ' | ${lat.toStringAsFixed(5)} , ${lng.toStringAsFixed(5)}'
            : '';

    return '$base\n—  $tecnico | $fechaStr$geo';
  }

  // ======================================================
  // UTILS
  // ======================================================
  Future<(double?, double?)> _tryGetLatLng() async {
    try {
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.deniedForever) return (null, null);
      if (!await Geolocator.isLocationServiceEnabled()) return (null, null);

      final pos = await Geolocator.getCurrentPosition();
      return (pos.latitude, pos.longitude);
    } catch (_) {
      return (null, null);
    }
  }

  @override
  void onClose() {
    solucionController.dispose();
    super.onClose();
  }
}

// ======================================================
// compute helpers (NO USAN PLUGINS)
// ======================================================
class _CompressArgs {
  final String inPath;
  final String outDir;
  final int maxWidth;
  final int quality;
  _CompressArgs({
    required this.inPath,
    required this.outDir,
    required this.maxWidth,
    required this.quality,
  });
}

Future<String> _compressImageCompute(_CompressArgs a) async {
  final bytes = await File(a.inPath).readAsBytes();
  final decoded = img.decodeImage(bytes);
  if (decoded == null) throw Exception('decodeImage null');

  // ✅ corrige orientación EXIF
  final baked = img.bakeOrientation(decoded);

  final resized = img.copyResize(baked, width: a.maxWidth);
  final compressed = img.encodeJpg(
    resized,
    quality: a.quality,
    // progressive: true,
  );
  final out = '${a.outDir}/cmp_${DateTime.now().millisecondsSinceEpoch}.jpg';
  await File(out).writeAsBytes(compressed);
  return out;
}

class _OverlayArgs {
  final String inPath;
  final String outDir;
  final String campo;
  final String tecnico;
  final DateTime fechaHora;
  final double? lat;
  final double? lng;
  final int quality;
  final int keepWidth;
  _OverlayArgs({
    required this.inPath,
    required this.outDir,
    required this.campo,
    required this.tecnico,
    required this.fechaHora,
    required this.lat,
    required this.lng,
    required this.quality,
    required this.keepWidth,
  });
}

Future<String> _overlayImageCompute(_OverlayArgs a) async {
  final bytes = await File(a.inPath).readAsBytes();
  final src0 = img.decodeImage(bytes);
  if (src0 == null) throw Exception('decodeImage null');

  // ✅ corrige orientación EXIF
  final src = img.bakeOrientation(src0);

  // ❌ antes reescalaba siempre
  // final canvas =
  //     (src.width == a.keepWidth)
  //         ? img.copyResize(src, width: a.keepWidth)
  //         : img.copyResize(src, width: a.keepWidth);

  // ✅ si ya tiene el ancho, úsalo tal cual; si no, reescala
  final canvas =
      (src.width == a.keepWidth)
          ? src
          : img.copyResize(src, width: a.keepWidth);

  final font = img.arial_48;

  String two(int n) => n.toString().padLeft(2, '0');
  final dd = two(a.fechaHora.day);
  final mm = two(a.fechaHora.month);
  final yyyy = a.fechaHora.year.toString();
  final hh = two(a.fechaHora.hour);
  final nn = two(a.fechaHora.minute);

  final coords =
      (a.lat != null && a.lng != null)
          ? ' ${a.lat!.toStringAsFixed(5)}, ${a.lng!.toStringAsFixed(5)}'
          : 'Sin coordenadas';

  final lines = <String>[
    'Tecnico: ${a.tecnico}',
    '$coords  $dd/$mm/$yyyy $hh:$nn',
  ];

  const lineHeight = 40;
  const padding = 10;
  final blockH = padding * 2 + lines.length * lineHeight;

  // Banda blanca arriba
  img.fillRect(canvas, 0, 0, canvas.width, blockH, img.getColor(255, 255, 255));

  // Texto rojo
  var y = padding;
  for (final line in lines) {
    img.drawString(canvas, font, 10, y, line, color: img.getColor(255, 0, 0));
    y += lineHeight;
  }

  final outBytes = img.encodeJpg(canvas, quality: a.quality);
  final out = '${a.outDir}/ovl_${DateTime.now().millisecondsSinceEpoch}.jpg';
  await File(out).writeAsBytes(outBytes);
  return out;
}
