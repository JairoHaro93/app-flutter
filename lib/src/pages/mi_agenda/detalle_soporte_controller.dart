import 'package:get/get.dart';
import 'package:redecom_app/src/models/agenda.dart';
import 'package:redecom_app/src/models/imagen_instalacion.dart';
import 'package:redecom_app/src/models/soporte.dart';
import 'package:redecom_app/src/providers/clientes_provider.dart';
import 'package:redecom_app/src/providers/soporte_provider.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';
import 'package:redecom_app/src/providers/images_provider.dart'; // << NUEVO

class DetalleSoporteController extends GetxController {
  // Providers
  final clientesProvider = ClientesProvider();
  final soporteProvider = SoporteProvider();
  final imagesProvider = ImagesProvider(); // << NUEVO
  // Agenda recibido por args
  late final Agenda agenda;

  // Cliente (map bruto + campos mapeados)
  final clienteJson = Rxn<Map<String, dynamic>>();
  final isLoadingCliente = false.obs;
  final clienteCedula = ''.obs;
  final clienteNombre = ''.obs;
  final clienteDireccion = ''.obs;
  final clienteReferencia = ''.obs;
  final clienteTelefonos = ''.obs;
  final clientePlan = ''.obs;
  final clienteEstado = ''.obs;
  final clienteInstaladoPor = ''.obs;
  final clienteIp = ''.obs;
  final clienteServicio = ''.obs;
  final clienteTipoInstalacion = ''.obs;
  final clienteEstadoInstalacion = ''.obs;
  final clienteCortado = ''.obs;
  final clienteCoordenadas = ''.obs;
  final clienteFechaInstalacion = ''.obs;
  final soporte = Rxn<Soporte>();
  final soporteComentario = ''.obs;

  // Imágenes VIS/LOS (id = idTipo)
  final imagenesVis = <String, ImagenInstalacion>{}.obs;
  final isLoadingImgsVis = false.obs;

  // Imágenes INSTALACIÓN (id = ord_ins como string)
  final imagenesInstalacion = <String, ImagenInstalacion>{}.obs;
  final isLoadingImgsInst = false.obs;

  // Guards
  final _busy = false.obs;
  final _busyImgsVis = false.obs;
  final _busyImgsInst = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Agenda) {
      agenda = args;
    } else {
      SnackbarService.error('No se recibió el trabajo (VIS/LOS)');
      agenda = Agenda(
        id: 0,
        tipo: '',
        estado: '',
        ordIns: 0,
        idSop: 0,
        idTipo: 0,
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
    cargarTodo();
  }

  Future<void> cargarTodo({bool force = false}) async {
    if (_busy.value && !force) return;
    _busy.value = true;
    try {
      await Future.wait([
        _cargarCliente(),
        _cargarImagenesVis(force: true),
        _cargarImagenesInstalacion(force: true),
        _cargarSoporte(), // 👈 NUEVO
      ]);
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error en cargarTodo VIS/LOS: $e');
      SnackbarService.error('No se pudo cargar VIS/LOS');
    } finally {
      _busy.value = false;
    }
  }

  Future<void> _cargarSoporte() async {
    final idSop = agenda.idSop;
    if (idSop == 0) {
      soporte.value = null;
      soporteComentario.value = '';
      return;
    }
    try {
      final s = await soporteProvider.getById(idSop);
      soporte.value = s;
      soporteComentario.value =
          s?.comentarioCliente.trim().isEmpty == true
              ? ''
              : s!.comentarioCliente.trim();
    } catch (_) {
      soporte.value = null;
      soporteComentario.value = '';
    }
  }

  // ========== CLIENTE ==========
  Future<void> _cargarCliente() async {
    final ordIns = agenda.ordIns;
    if (ordIns == 0) {
      _clearCliente();
      return;
    }

    isLoadingCliente.value = true;
    try {
      final cli = await clientesProvider.getInfoServicioByOrdId(ordIns);
      clienteJson.value = cli;
      _mapCliente(cli);
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ Error cargando cliente VIS/LOS: $e');
      _clearCliente();
    } finally {
      isLoadingCliente.value = false;
    }
  }

  void _mapCliente(Map<String, dynamic> cli) {
    final servicios = (cli['servicios'] as List?) ?? const [];
    final s0 =
        servicios.isNotEmpty && servicios.first is Map<String, dynamic>
            ? Map<String, dynamic>.from(servicios.first as Map)
            : const <String, dynamic>{};

    String _s(dynamic v) {
      final s = (v ?? '').toString().trim();
      if (s.isEmpty || s.toLowerCase() == 'null') return '';
      return s;
    }

    String _normCoords(String s) => s.replaceAll(',,', ',').replaceAll(' ', '');

    clienteCedula.value = _s(cli['cedula']);
    clienteNombre.value = _s(cli['nombre_completo']);
    clienteDireccion.value = _s(s0['direccion']);
    clienteReferencia.value = _s(s0['referencia']);
    clienteTelefonos.value = _s(s0['telefonos']);
    clientePlan.value = _s(s0['plan_nombre']);
    clienteEstado.value = _s(s0['estado']);
    clienteInstaladoPor.value = _s(s0['instalado_por']);
    clienteIp.value = _s(s0['ip']);
    clienteServicio.value = _s(s0['servicio']);
    clienteTipoInstalacion.value = _s(s0['tipo_instalacion']);
    clienteEstadoInstalacion.value = _s(s0['estado_instalacion']);
    clienteCortado.value = _s(s0['cortado']);
    clienteFechaInstalacion.value = _s(s0['fecha_instalacion']);

    final coords = _s(s0['coordenadas']);
    clienteCoordenadas.value = coords.isEmpty ? '' : _normCoords(coords);
  }

  void _clearCliente() {
    clienteCedula.value = '';
    clienteNombre.value = '';
    clienteDireccion.value = '';
    clienteReferencia.value = '';
    clienteTelefonos.value = '';
    clientePlan.value = '';
    clienteEstado.value = '';
    clienteInstaladoPor.value = '';
    clienteIp.value = '';
    clienteServicio.value = '';
    clienteTipoInstalacion.value = '';
    clienteEstadoInstalacion.value = '';
    clienteCortado.value = '';
    clienteFechaInstalacion.value = '';
    clienteCoordenadas.value = '';
  }

  // ========== IMÁGENES VIS/LOS ==========
  Future<void> _cargarImagenesVis({bool force = false}) async {
    if (_busyImgsVis.value && !force) return;

    final idVis = agenda.idTipo; // id del registro VIS/LOS
    if (idVis == 0) {
      imagenesVis.clear();
      return;
    }

    _busyImgsVis.value = true;
    isLoadingImgsVis.value = true;
    try {
      // NUEVO: backend nuevo con shape legacy
      final map = await imagesProvider.getLegacyMap(
        'neg_t_vis',
        idVis.toString(),
      );
      imagenesVis.assignAll(map);

      // debug opcional
      // print('[IMG][VIS] keys -> ${imagenesVis.keys.toList()}');
    } catch (e) {
      print('⚠️ No se pudieron cargar imágenes VIS/LOS: $e');
      imagenesVis.clear();
    } finally {
      isLoadingImgsVis.value = false;
      _busyImgsVis.value = false;
    }
  }

  // ========== IMÁGENES INSTALACIÓN ==========
  Future<void> _cargarImagenesInstalacion({bool force = false}) async {
    if (_busyImgsInst.value && !force) return;

    final ordIns = agenda.ordIns;
    if (ordIns == 0) {
      imagenesInstalacion.clear();
      return;
    }

    _busyImgsInst.value = true;
    isLoadingImgsInst.value = true;
    try {
      // NUEVO: backend nuevo con shape legacy
      final map = await imagesProvider.getLegacyMap(
        'neg_t_instalaciones',
        ordIns.toString(),
      );
      imagenesInstalacion.assignAll(map);

      // debug opcional
      // print('[IMG][INST] keys -> ${imagenesInstalacion.keys.toList()}');
    } catch (e) {
      print('⚠️ No se pudieron cargar imágenes de INSTALACIÓN: $e');
      imagenesInstalacion.clear();
    } finally {
      isLoadingImgsInst.value = false;
      _busyImgsInst.value = false;
    }
  }

  // Expuestos a la UI
  Future<void> recargarImagenesVis() => _cargarImagenesVis(force: true);
  Future<void> recargarImagenesInst() =>
      _cargarImagenesInstalacion(force: true);
}
