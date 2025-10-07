import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'package:redecom_app/src/models/agenda.dart';
import 'package:redecom_app/src/models/imagen_instalacion.dart';
import 'package:redecom_app/src/providers/images_provider.dart';
import 'package:redecom_app/src/providers/agenda_provider.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';
import 'package:redecom_app/src/utils/auth_service.dart';

class EditarInfraestructuraController extends GetxController {
  // ===== Dependencias =====
  final ImagesProvider _imgsProv = Get.find<ImagesProvider>();
  final AgendaProvider _agendaProv =
      Get.isRegistered<AgendaProvider>()
          ? Get.find<AgendaProvider>()
          : AgendaProvider();
  final AuthService _auth =
      Get.isRegistered<AuthService>() ? Get.find<AuthService>() : AuthService();
  final ImagePicker _picker = ImagePicker();

  // ===== Entrada =====
  late final Agenda trabajo; // usaremos agenda.idTipo como entityId

  // ===== Estado =====
  /// Referencias estáticas (no editables): claves ref_1, ref_2, ...
  final referencias = <String, ImagenInstalacion>{}.obs;

  /// Evidencias dinámicas (agregables): claves infra_1, infra_2, ...
  final evidencias = <String, ImagenInstalacion>{}.obs;

  final isLoadingImgs = false.obs;
  final isSaving = false.obs;
  final _busyLoad = false.obs;
  bool _isPicking = false;

  // Controlador de texto para la solución
  final solucionCtrl = TextEditingController();
  final RxInt solucionLen = 0.obs; // reactividad del botón Concluir
  void onSolucionChanged(String v) => solucionLen.value = v.trim().length;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Agenda) {
      trabajo = args;
      final prev = args.solucion?.trim() ?? '';
      solucionCtrl.text = prev;
      solucionLen.value = prev.length;
    } else {
      SnackbarService.error('No se recibió el trabajo de infraestructura');
      // fallback mínimo para evitar nulls
      trabajo = Agenda(
        id: 0,
        tipo: 'INFRAESTRUCTURA',
        estado: '',
        ordIns: 0,
        idSop: 0,
        idTipo: 0, // <- entityId
        horaInicio: '',
        horaFin: '',
        fecha: '',
        vehiculo: '',
        tecnico: '',
        diagnostico: '',
        coordenadas: '',
        telefono: '',
      );
    }
  }

  @override
  void onReady() {
    super.onReady();
    recargar();
  }

  @override
  void onClose() {
    solucionCtrl.dispose();
    super.onClose();
  }

  // ===== Computed =====
  bool get puedeConcluir => solucionLen.value > 0;

  // ===== Carga de imágenes (particiona por tag ref/infra) =====
  Future<void> recargar() async {
    if (_busyLoad.value) return;
    _busyLoad.value = true;
    isLoadingImgs.value = true;

    referencias.clear();
    evidencias.clear();

    try {
      final entityId = _entityId();
      if (entityId == null) return;

      // Esperamos keys del tipo "referencia_1", "infra_1", etc.
      final all = await _imgsProv.listAsLegacyMap(
        module: 'infraestructura',
        entityId: entityId,
      );

      all.forEach((k, v) {
        final key = k.trim().toLowerCase();
        if (key.startsWith('referencia_')) {
          referencias[k] = v;
        } else if (key.startsWith('infra_')) {
          evidencias[k] = v;
        } else {
          // si llegara otro tag, lo tratamos como evidencia
          evidencias[k] = v;
        }
      });
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ recargar infra: $e');
      SnackbarService.error('No se pudieron cargar las imágenes');
    } finally {
      isLoadingImgs.value = false;
      _busyLoad.value = false;
    }
  }

  // ===== Agregar evidencia (dinámico) =====
  Future<void> agregarEvidencia() async {
    if (_isPicking) return;
    _isPicking = true;

    try {
      final src = await _elegirFuenteImagen(); // forzamos cámara si quieres
      if (src == null) return;
      await Future.delayed(const Duration(milliseconds: 120));

      final entityId = _entityId();
      if (entityId == null) {
        SnackbarService.warning('Este trabajo no tiene identificador (idTipo)');
        return;
      }

      final nextPos = _siguientePosicionEvidencia(); // infra_N siguiente

      final picked = await _picker.pickImage(
        source: src,
        imageQuality: 92,
        maxWidth: 2048,
      );
      if (picked == null) return;

      final original = File(picked.path);

      isSaving.value = true;

      final comprimida = await _comprimirImagen(
        original,
        maxWidth: 1000,
        calidad: 85,
      );
      final estampada = await _procesarImagenConTexto(
        comprimida,
        'infra_$nextPos',
      );

      await _imgsProv.upload(
        module: 'infraestructura',
        entityId: entityId,
        tag: 'infra',
        position: nextPos,
        file: estampada,
      );

      await _refrescarSlot(tag: 'infra', position: nextPos);
      SnackbarService.success('Evidencia agregada');
    } catch (e) {
      // ignore: avoid_print
      print('❌ agregarEvidencia: $e');
      SnackbarService.error('No se pudo agregar la evidencia');
    } finally {
      isSaving.value = false;
      _isPicking = false;
    }
  }

  // ===== Reemplazar evidencia existente =====
  Future<void> reemplazarEvidencia(String campo) async {
    // campo esperado: "infra_3"
    final m = RegExp(r'^infra_(\d+)$').firstMatch(campo.trim().toLowerCase());
    if (m == null) {
      SnackbarService.warning('Slot inválido: $campo');
      return;
    }
    final pos = int.tryParse(m.group(1)!) ?? 0;
    if (pos <= 0) {
      SnackbarService.warning('Posición inválida para $campo');
      return;
    }

    if (_isPicking) return;
    _isPicking = true;

    try {
      final src = await _elegirFuenteImagen();
      if (src == null) return;
      await Future.delayed(const Duration(milliseconds: 120));

      final entityId = _entityId();
      if (entityId == null) {
        SnackbarService.warning('Este trabajo no tiene identificador (idTipo)');
        return;
      }

      final picked = await _picker.pickImage(
        source: src,
        imageQuality: 92,
        maxWidth: 2048,
      );
      if (picked == null) return;

      final original = File(picked.path);

      isSaving.value = true;

      final comprimida = await _comprimirImagen(
        original,
        maxWidth: 1000,
        calidad: 85,
      );
      final estampada = await _procesarImagenConTexto(comprimida, 'infra_$pos');

      await _imgsProv.upload(
        module: 'infraestructura',
        entityId: entityId,
        tag: 'infra',
        position: pos,
        file: estampada,
      );

      await _refrescarSlot(tag: 'infra', position: pos);
      SnackbarService.success('Imagen reemplazada');
    } catch (e) {
      // ignore: avoid_print
      print('❌ reemplazarEvidencia: $e');
      SnackbarService.error('No se pudo reemplazar la imagen');
    } finally {
      isSaving.value = false;
      _isPicking = false;
    }
  }

  // ===== Concluir trabajo =====
  Future<void> concluir() async {
    final texto = solucionCtrl.text.trim();
    if (texto.isEmpty) {
      SnackbarService.warning('La solución no puede estar vacía.');
      return;
    }

    if (isSaving.value) return; // evitar doble submit

    try {
      isSaving.value = true;

      // Construir un Agenda actualizado con estado y solución.
      final actualizado = trabajo.copyWith(
        estado: 'CONCLUIDO',
        solucion: texto,
      );

      await _agendaProv.actualizarAgendaSolucionByAgenda(
        trabajo.id,
        actualizado,
      );

      SnackbarService.success('Trabajo concluido y guardado');
      Get.back(result: true);
    } catch (e) {
      // ignore: avoid_print
      print('❌ concluir: $e');
      SnackbarService.error('No se pudo guardar la solución');
    } finally {
      isSaving.value = false;
    }
  }

  // ===== Handler general desde la UI =====
  Future<void> onTapSlot(String key) async {
    final k = key.trim().toLowerCase();
    if (k.startsWith('ref_')) {
      SnackbarService.warning('Las imágenes de referencia no se pueden editar');
      return;
    }
    if (k.startsWith('infra_')) {
      await reemplazarEvidencia(key);
      return;
    }
    // fallback: tratar como evidencia
    await reemplazarEvidencia(key);
  }

  // ===== Helpers =====
  String? _entityId() {
    final id = trabajo.idTipo;
    if (id == 0) return null;
    return id.toString();
  }

  int _siguientePosicionEvidencia() {
    int maxPos = 0;
    for (final k in evidencias.keys) {
      final m = RegExp(r'^infra_(\d+)$').firstMatch(k.toLowerCase());
      if (m != null) {
        final p = int.tryParse(m.group(1)!) ?? 0;
        if (p > maxPos) maxPos = p;
      }
    }
    return maxPos + 1;
  }

  Future<ImageSource?> _elegirFuenteImagen() async {
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

  Future<File> _comprimirImagen(
    File original, {
    int maxWidth = 1000,
    int calidad = 85,
  }) async {
    final bytes = await original.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw Exception('No se pudo leer la imagen');
    final resized = img.copyResize(decoded, width: maxWidth);
    final out = img.encodeJpg(resized, quality: calidad);

    final tmp = await getTemporaryDirectory();
    final path =
        '${tmp.path}/infra_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return File(path)..writeAsBytesSync(out, flush: true);
  }

  Future<File> _procesarImagenConTexto(File original, String campo) async {
    final bytes = await original.readAsBytes();
    img.Image? im = img.decodeImage(bytes);
    if (im == null) throw Exception('No se pudo procesar la imagen');

    im = img.bakeOrientation(im);
    final resized = img.copyResize(im, width: im.width);

    final font = img.arial_48;

    final now = DateTime.now();
    final fecha =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final tecnico =
        (_auth.currentUser?.username ?? _auth.currentUser?.name ?? '').trim();

    String texto = '$campo         Tecnico: $tecnico';

    try {
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

    const bandHeight = 120;
    img.fillRect(
      resized,
      0,
      0,
      resized.width,
      bandHeight,
      img.getColor(255, 255, 255),
    );
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
    final path =
        '${tmp.path}/infra_mod_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return File(path)..writeAsBytesSync(out, flush: true);
  }

  // Refresca 1 slot concreto tras subir
  Future<void> _refrescarSlot({
    required String tag,
    required int position,
  }) async {
    final entityId = _entityId();
    if (entityId == null) return;

    // Volvemos a pedir como legacy map y tomamos la clave concreta
    final all = await _imgsProv.listAsLegacyMap(
      module: 'infraestructura',
      entityId: entityId,
    );
    final key = '${tag.toLowerCase()}_$position';

    final imgItem = all[key];
    if (imgItem == null) return;

    if (tag == 'referencia') {
      referencias[key] = imgItem;
      referencias.refresh();
    } else {
      evidencias[key] = imgItem;
      evidencias.refresh();
    }
  }
}
