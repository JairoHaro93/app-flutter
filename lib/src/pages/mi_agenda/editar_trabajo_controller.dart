// lib/src/pages/mi_agenda/editar_trabajo_controller.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:redecom_app/src/models/agenda.dart';
import 'package:redecom_app/src/models/imagen_instalacion.dart';
import 'package:redecom_app/src/providers/imagenes_provider.dart';
import 'package:redecom_app/src/providers/agenda_provider.dart';
import 'package:redecom_app/src/providers/instalacion_provider.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';

class EditarTrabajoController extends GetxController {
  // --------- Dependencias ---------
  final _imgsProv = ImagenesProvider();
  final _agendaProv = AgendaProvider();
  final _picker = ImagePicker();
  // --------- Estado principal ---------
  final trabajo = Rxn<Agenda>();
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

  final List<String> camposVisita = const [
    // ajusta si tienes convención propia en backend para VIS/LOS
    'fachada', 'ont', 'potencia', 'speedtest', 'evidencia_1', 'evidencia_2',
  ];

  // Mapas campo -> ImagenInstalacion (para miniaturas)
  final imagenesInstalacion = <String, ImagenInstalacion>{}.obs;
  final imagenesVisita = <String, ImagenInstalacion>{}.obs;

  // Solución
  final solucionController = TextEditingController();

  // --- NUEVO: terminar instalación ---
  final coordCtrl = TextEditingController();
  final ipCtrl = TextEditingController();
  final isTerminating = false.obs;

  final _instProv = InstalacionProvider();

  bool get esInstalacion =>
      (trabajo.value?.tipo.toUpperCase() ?? '') == 'INSTALACION';

  @override
  void onInit() {
    super.onInit();

    // Recibir Agenda por argumentos
    final args = Get.arguments;
    if (args is Agenda) {
      trabajo.value = args;
      // Cargar imágenes existentes
      _cargarMiniaturas();
      // Precargar solución si viene
      solucionController.text = args.solucion?.trim() ?? '';
    }
    if (esInstalacion) {
      coordCtrl.text = args.coordenadas.trim(); // 👈 prefill si aplica
    } else {
      SnackbarService.warning('No se recibió el trabajo a editar');
    }
  }

  Future<File?> _pickImage() async {
    try {
      // Mostrar opciones al usuario
      final source = await Get.bottomSheet<ImageSource>(
        SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Cámara'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galería'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
      );

      if (source == null) return null; // canceló

      final XFile? x = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (x == null) return null; // canceló en picker

      return File(x.path);
    } catch (e) {
      SnackbarService.error('No se pudo abrir el selector: $e');
      return null;
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

      // Si quieres volver atrás confirmando
      // Get.back(result: true);

      // O refrescar algo local si aplica
    } catch (e) {
      SnackbarService.error(e.toString());
    } finally {
      isTerminating.value = false;
    }
  }

  // ---------- Carga de miniaturas ----------
  Future<void> _cargarMiniaturas() async {
    final t = trabajo.value;
    if (t == null) return;

    try {
      // Instalación (id = ordIns como string)
      if (t.ordIns != 0) {
        final map = await _imgsProv.getImagenesPorAgenda(
          'neg_t_instalaciones',
          t.ordIns.toString(),
        );
        imagenesInstalacion.assignAll(map);
      } else {
        imagenesInstalacion.clear();
      }

      // VIS/LOS (id = age_id_tipo)
      if (!esInstalacion && t.idTipo != 0) {
        final map = await _imgsProv.getImagenesPorAgenda(
          'neg_t_vis',
          t.idTipo.toString(),
        );
        imagenesVisita.assignAll(map);
      } else {
        imagenesVisita.clear();
      }
    } catch (e) {
      SnackbarService.error('No se pudieron cargar imágenes: $e');
    }
  }

  // ---------- Selección/Subida de imágenes ----------
  Future<void> seleccionarImagenInstalacion(String campo) async {
    final t = trabajo.value;
    if (t == null || t.ordIns == 0) {
      SnackbarService.warning('Este trabajo no tiene ORD_INS');
      return;
    }

    final file = await _pickImage();
    if (file == null) return;

    try {
      await _imgsProv.postImagenUnitaria(
        tabla: 'neg_t_instalaciones',
        id: t.ordIns.toString(),
        campo: campo,
        directorio: t.ordIns.toString(), // convención actual
        file: file,
      );
      await _actualizarMiniatura('inst', campo);
      SnackbarService.success('Imagen actualizada');
    } catch (e) {
      SnackbarService.error('Error subiendo imagen: $e');
    }
  }

  Future<void> seleccionarImagenVisita(String campo) async {
    final t = trabajo.value;
    if (t == null || t.idTipo == 0) {
      SnackbarService.warning('Este VIS/LOS no tiene idTipo');
      return;
    }

    final file = await _pickImage();
    if (file == null) return;

    try {
      await _imgsProv.postImagenUnitaria(
        tabla: 'neg_t_vis',
        id: t.idTipo.toString(),
        campo: campo,
        directorio: t.idTipo.toString(), // convención actual
        file: file,
      );
      await _actualizarMiniatura('vis', campo);
      SnackbarService.success('Imagen actualizada');
    } catch (e) {
      SnackbarService.error('Error subiendo imagen: $e');
    }
  }

  // Recarga una sola miniatura tras subir
  Future<void> _actualizarMiniatura(String tipo, String campo) async {
    final t = trabajo.value;
    if (t == null) return;

    try {
      if (tipo == 'inst') {
        final map = await _imgsProv.getImagenesPorAgenda(
          'neg_t_instalaciones',
          t.ordIns.toString(),
        );
        final nuevo = map[campo];
        if (nuevo != null) {
          imagenesInstalacion[campo] = nuevo;
          imagenesInstalacion.refresh();
        }
      } else {
        final map = await _imgsProv.getImagenesPorAgenda(
          'neg_t_vis',
          t.idTipo.toString(),
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
      // Actualiza estado a CONCLUIDO (ajusta si usas otro flujo)
      final actualizado = t.copyWith(estado: 'CONCLUIDO', solucion: sol);

      await _agendaProv.actualizarAgendaSolucionByAgenda(t.id, actualizado);

      SnackbarService.success('Solución guardada');
      // Devuelve OK al caller (Detalle INST/Soporte) para que refresque
      Get.back(result: true);
    } catch (e) {
      SnackbarService.error('No se pudo guardar la solución: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> guardarTodo() async {
    // evita dobles taps
    if (isSaving.value || isTerminating.value) return;

    final t = trabajo.value;
    if (t == null) {
      SnackbarService.error('No hay trabajo cargado');
      return;
    }

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
      }

      // 2) Guardar solución (si hay texto)
      final sol = solucionController.text.trim();
      if (sol.isNotEmpty) {
        final actualizado = t.copyWith(estado: 'CONCLUIDO', solucion: sol);

        await _agendaProv.actualizarAgendaSolucionByAgenda(t.id, actualizado);
        trabajo.value = actualizado; // refresca en memoria
      }

      SnackbarService.success('Cambios guardados');
      Get.back(result: true);
    } catch (e) {
      // ignore: avoid_print
      print('❌ guardarTodo error: $e');
      SnackbarService.error('No se pudo guardar');
    } finally {
      isTerminating.value = false;
      isSaving.value = false;
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
