import 'package:get/get.dart';
import 'package:redecom_app/src/models/trabajo.dart';
import 'package:redecom_app/src/models/instalacion_mysql.dart';
import 'package:redecom_app/src/models/imagen_instalacion.dart';
import 'package:redecom_app/src/providers/instalacion_provider.dart';
import 'package:redecom_app/src/providers/clientes_provider.dart';
import 'package:redecom_app/src/providers/imagenes_provider.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';

class DetalleInstalacionController extends GetxController {
  // Providers
  final instalacionProvider = InstalacionProvider();
  final clientesProvider = ClientesProvider();
  final imagenesProvider = ImagenesProvider();

  // Estado bruto (respuestas completas)
  final instalacionMysql = Rxn<InstalacionMysql>();
  final clienteJson = Rxn<Map<String, dynamic>>();

  // Estado de imágenes (campo -> objeto con url/ruta)
  final imagenesInstalacion = <String, ImagenInstalacion>{}.obs;

  // Estado de carga
  final isLoadingInst = false.obs;
  final isLoadingCliente = false.obs;
  final isLoadingImgs = false.obs;

  // Guards
  final _busy = false.obs;
  final _busyImgs = false.obs;

  // Trabajo recibido por args
  late final Trabajo trabajo;

  // ===== Campos mapeados (listos para UI) =====
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
  final clienteFechaInstalacion = Rxn<DateTime>();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Trabajo) {
      trabajo = args;
    } else {
      SnackbarService.error('No se recibió el trabajo para la instalación');
      trabajo = Trabajo(
        id: 0,
        tipo: '',
        subtipo: '',
        estado: '',
        ordenInstalacion: 0,
        soporteId: 0,
        ageIdTipo: 0,
        horaInicio: '',
        horaFin: '',
        fecha: '',
        vehiculo: '',
        tecnico: '',
        observaciones: '',
        coordenadas: '',
        telefono: '',
      );
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (trabajo.ordenInstalacion != 0) {
      cargarInstalacionYCliente();
    }
  }

  /// Instalación (MySQL) -> Cliente (SQL Server) -> Imágenes (imagenes service)
  Future<void> cargarInstalacionYCliente({bool force = false}) async {
    if (_busy.value && !force) {
      // ignore: avoid_print
      print('⏳ cargarInstalacionYCliente: ya hay una carga en curso.');
      return;
    }
    _busy.value = true;

    try {
      isLoadingInst.value = true;

      // 1) Instalación (MySQL)
      final inst = await instalacionProvider.getInstalacionMysqlByOrdIns(
        trabajo.ordenInstalacion,
      );
      instalacionMysql.value = inst;

      // 2) Cliente (SQL Server)
      final ordInsStr = inst?.ordIns ?? trabajo.ordenInstalacion.toString();
      final ordInsInt = int.tryParse(ordInsStr) ?? 0;

      if (ordInsInt != 0) {
        isLoadingCliente.value = true;
        final cli = await clientesProvider.getInfoServicioByOrdId(ordInsInt);
        // ignore: avoid_print
        print('👤 Cliente JSON: $cli');

        clienteJson.value = cli;
        _mapCliente(cli);
      } else {
        clienteJson.value = {};
        _clearCliente();
      }

      // 3) Imágenes (tabla neg_t_instalaciones, id = ord_ins STRING)
      await cargarImagenesInstalacion(force: true);
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error al cargar instalación/cliente: $e');
      SnackbarService.error('No se pudo cargar instalación/cliente');
    } finally {
      isLoadingCliente.value = false;
      isLoadingInst.value = false;
      _busy.value = false;
      // ignore: avoid_print
      print('🏁 cargarInstalacionYCliente: finalizado');
    }
  }

  Future<void> cargarImagenesInstalacion({bool force = false}) async {
    if (_busyImgs.value && !force) {
      // ignore: avoid_print
      print('⏳ cargarImagenesInstalacion: ya hay una carga en curso.');
      return;
    }
    final inst = instalacionMysql.value;
    if (inst == null || inst.ordIns.isEmpty) {
      imagenesInstalacion.clear();
      return;
    }

    _busyImgs.value = true;
    isLoadingImgs.value = true;
    try {
      final map = await imagenesProvider.getImagenesPorTrabajo(
        'neg_t_instalaciones',
        inst.ordIns, // ID debe ser string
      );
      imagenesInstalacion.assignAll(map);
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ No se pudieron cargar imágenes de instalación: $e');
      imagenesInstalacion.clear();
    } finally {
      isLoadingImgs.value = false;
      _busyImgs.value = false;
    }
  }

  // =======================
  // Helpers de mapeo cliente
  // =======================

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

    DateTime? _dt(dynamic v) {
      try {
        final s = _s(v);
        if (s.isEmpty) return null;
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    String _normalizeCoords(String s) {
      final raw = s.replaceAll(',,', ',').replaceAll(' ', '');
      return raw;
    }

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
    clienteFechaInstalacion.value = _dt(s0['fecha_instalacion']);

    final coords = _s(s0['coordenadas']);
    clienteCoordenadas.value = coords.isEmpty ? '' : _normalizeCoords(coords);
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
    clienteFechaInstalacion.value = null;
    clienteCoordenadas.value = '';
  }
}
