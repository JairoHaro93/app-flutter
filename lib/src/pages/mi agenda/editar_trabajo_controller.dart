import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

import 'package:redecom_app/src/models/trabajo.dart';
import 'package:redecom_app/src/models/imagen_instalacion.dart';
import 'package:redecom_app/src/providers/agenda_provider.dart';
import 'package:redecom_app/src/providers/soporte_provider.dart';
import 'package:redecom_app/src/providers/imagenes_provider.dart';
import 'package:redecom_app/src/utils/auth_service.dart';
import 'package:redecom_app/src/utils/socket_service.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';

class EditarTrabajoController extends GetxController {
  final AgendaProvider agendaProvider = AgendaProvider();
  final SoporteProvider soporteProvider = SoporteProvider();
  final ImagenesProvider imagenesProvider = ImagenesProvider();
  final SocketService socketService = Get.find<SocketService>();

  final solucionController = TextEditingController();
  final isSaving = false.obs;
  final imagenesInstalacion = <String, ImagenInstalacion>{}.obs;
  final imagenesVisita = <String, ImagenInstalacion>{}.obs;

  late Trabajo trabajo;

  List<String> get camposInstalacion => [
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

  List<String> get camposVisita => ['img_1', 'img_2', 'img_3', 'img_4'];

  bool get esSoporte => trabajo.tipo == 'SOPORTE';

  final AuthService authService = Get.find<AuthService>();
  late final String nombreUsuario;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Trabajo) {
      trabajo = Get.arguments as Trabajo;
      solucionController.text = trabajo.solucion ?? '';
      _cargarImagenes();
    }
  }

  void _cargarImagenes() async {
    try {
      final inicio = DateTime.now();

      final imgInst = await imagenesProvider.getImagenesPorTrabajo(
        'neg_t_img_inst',
        trabajo.ordenInstalacion,
      );
      imagenesInstalacion.assignAll(imgInst);

      if (esSoporte) {
        final imgVisita = await imagenesProvider.getImagenesPorTrabajo(
          'neg_t_agenda',
          trabajo.soporteId.toString(),
        );
        imagenesVisita.assignAll(imgVisita);
      }

      final fin = DateTime.now();
      print('📥 Tiempo de descarga de imágenes: ${fin.difference(inicio)}');
    } catch (_) {
      SnackbarService.error('No se pudieron cargar las imágenes');
    }
  }

  Future<void> seleccionarImagenInstalacion(String campo) async {
    _mostrarOpcionesImagen(
      campo: campo,
      tabla: 'neg_t_img_inst',
      id: trabajo.ordenInstalacion,
      directorio: trabajo.ordenInstalacion,
    );
  }

  Future<void> seleccionarImagenVisita(String campo) async {
    _mostrarOpcionesImagen(
      campo: campo,
      tabla: 'neg_t_agenda',
      id: trabajo.soporteId.toString(),
      directorio: trabajo.ordenInstalacion,
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
              title: const Text('Tomar Foto'),
              onTap: () async {
                Get.back();
                final picked = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (picked != null)
                  _subirImagen(campo, tabla, id, directorio, File(picked.path));
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de galería'),
              onTap: () async {
                Get.back();
                final picked = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (picked != null)
                  _subirImagen(campo, tabla, id, directorio, File(picked.path));
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Future<File> _procesarImagenConTexto(File original, String campo) async {
    final bytes = await original.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('No se pudo procesar la imagen');

    //CALDADAD DE IMAGEN
    final resized = img.copyResize(image, width: 1000);
    final font = img.arial_48;

    // 🕒 Fecha y hora
    final ahora = DateTime.now();
    String texto =
        '$campo         Tecnico: ${authService.currentUser?.username} ';

    // 📍 Intentar obtener coordenadas
    try {
      bool servicioHabilitado = await Geolocator.isLocationServiceEnabled();
      LocationPermission permiso = await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.deniedForever || !servicioHabilitado) {
        throw Exception('Permiso de ubicación denegado');
      }

      final pos = await Geolocator.getCurrentPosition();
      texto +=
          '\nLat: ${pos.latitude.toStringAsFixed(5)}, Lng: ${pos.longitude.toStringAsFixed(5)} ${ahora.day}/${ahora.month}/${ahora.year} ${ahora.hour}:${ahora.minute}   ';
    } catch (e) {
      texto += '\nSin coordenadas';
    }

    // 🏷️ Fondo blanco detrás del texto
    // Fondo blanco que cubre todo el ancho de la imagen
    img.fillRect(
      resized,
      0,
      0,
      resized.width,
      120, // ajusta según cantidad de líneas de texto
      img.getColor(255, 255, 255),
    );

    // 🖊️ Dibujar el texto
    img.drawString(
      resized,
      font,
      10,
      10,
      texto,
      color: img.getColor(255, 0, 0),
    );

    final tempDir = await getTemporaryDirectory();
    final newPath =
        '${tempDir.path}/img_modificada_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newImage = File(newPath)
      ..writeAsBytesSync(img.encodeJpg(resized, quality: 85));

    return newImage;
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

      final comprimida = await _comprimirImagen(archivoOriginal);
      final despuesComprimir = DateTime.now();

      final imagenProcesada = await _procesarImagenConTexto(comprimida, campo);
      final despuesProcesar = DateTime.now();

      await imagenesProvider.subirImagen(
        tabla: tabla,
        id: id,
        campo: campo,
        directorio: directorio,
        file: imagenProcesada,
      );
      final despuesSubida = DateTime.now();

      _cargarImagenes();
      final fin = DateTime.now();

      print('⏱️ Tiempo total: ${fin.difference(inicio)}');
      print('🗜️ Compresión: ${despuesComprimir.difference(inicio)}');
      print(
        '🖊️ Procesado texto: ${despuesProcesar.difference(despuesComprimir)}',
      );
      print('☁️ Subida: ${despuesSubida.difference(despuesProcesar)}');
      print('🔄 Recarga: ${fin.difference(despuesSubida)}');

      SnackbarService.success('✅ Imagen actualizada');
    } catch (e) {
      SnackbarService.error('❌ No se pudo subir la imagen');
    }
  }

  Future<void> guardarSolucion() async {
    final solucion = solucionController.text.trim();
    if (solucion.isEmpty) {
      SnackbarService.warning('Ingresa una solución');
      return;
    }

    isSaving.value = true;
    try {
      final actualizado = trabajo.copyWith(
        estado: 'CONCLUIDO',
        solucion: solucion,
      );

      await agendaProvider.actualizarAgendaSolucion(
        actualizado.id,
        actualizado,
      );

      if (trabajo.soporteId != 0) {
        await soporteProvider.actualizarEstadoSop(trabajo.soporteId, {
          'reg_sop_estado': 'RESUELTO',
          'reg_sop_sol_det': solucion,
        });
      }

      final userId = GetStorage().read('usuario_id');
      if (userId != null) {
        socketService.emit('trabajoCulminado', {'tecnicoId': userId});
      }

      SnackbarService.success('✅ Trabajo actualizado correctamente');
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed('/home');
    } catch (_) {
      SnackbarService.error('❌ No se pudo guardar la solución');
    } finally {
      isSaving.value = false;
    }
  }

  Future<File> _comprimirImagen(
    File original, {
    int maxWidth = 800,
    int calidad = 80,
  }) async {
    final bytes = await original.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) throw Exception('No se pudo leer la imagen');

    final resized = img.copyResize(image, width: maxWidth);
    final compressedBytes = img.encodeJpg(resized, quality: calidad);

    final tempDir = await getTemporaryDirectory();
    final path =
        '${tempDir.path}/img_comprimida_${DateTime.now().millisecondsSinceEpoch}.jpg';
    return File(path)..writeAsBytesSync(compressedBytes);
  }

  @override
  void onClose() {
    solucionController.dispose();
    super.onClose();
  }
}
