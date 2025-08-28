import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:redecom_app/src/models/agenda.dart';
import 'package:redecom_app/src/providers/agenda_provider.dart';
import 'package:redecom_app/src/utils/socket_service.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';

class MiAgendaController extends GetxController {
  // Provider local (no permanente; el controller controla su ciclo de vida)
  final AgendaProvider _agendaProvider = Get.put(AgendaProvider());

  late final SocketService _socket;

  final trabajos = <Agenda>[].obs;
  final isLoading = false.obs;

  // Si llega un evento mientras se está cargando,
  // marcamos un reload pendiente para ejecutar al finalizar.
  bool _pendingReload = false;

  @override
  void onInit() {
    super.onInit();
    _socket = Get.find<SocketService>();
    _escucharSockets();

    if (kDebugMode)
      debugPrint('📅 MiAgendaController.onInit -> cargarAgenda()');
    cargarAgenda();
  }

  @override
  void onClose() {
    // Desuscribir TODOS los eventos que registramos
    const posibles = ['trabajoAgendadoTecnico', 'trabajoAgendado'];
    for (final ev in posibles) {
      _socket.off(ev);
    }
    super.onClose();
  }

  Future<void> cargarAgenda() async {
    if (isLoading.value) {
      // Llega otra petición (por socket/usuario) mientras carga
      _pendingReload = true; // agenda un reload al finalizar
      if (kDebugMode)
        debugPrint('⏳ cargarAgenda: ya cargando; marcar reload pendiente');
      return;
    }

    isLoading.value = true;
    if (kDebugMode) debugPrint('➡️ cargarAgenda: solicitando trabajos...');

    try {
      final lista = await _agendaProvider.getAgendaTec();

      if (kDebugMode)
        debugPrint('✅ cargarAgenda: recibidos ${lista.length} trabajos');

      // Orden por fecha y luego por hora de inicio
      lista.sort((a, b) {
        final fa = _parseFecha(a.fecha);
        final fb = _parseFecha(b.fecha);
        final cmpFecha = fa.compareTo(fb);
        if (cmpFecha != 0) return cmpFecha;

        final ha = _parseHora(a.horaInicio);
        final hb = _parseHora(b.horaInicio);
        return ha.compareTo(hb);
      });

      trabajos.assignAll(lista);
    } catch (e, st) {
      if (kDebugMode) debugPrint('❌ cargarAgenda ERROR: $e\n$st');
      SnackbarService.error(e.toString());
    } finally {
      isLoading.value = false;
      if (kDebugMode)
        debugPrint('🏁 cargarAgenda: finalizado (isLoading=false)');

      // Si quedó un reload pendiente por eventos concurrentes, ejecútalo una vez.
      if (_pendingReload) {
        _pendingReload = false;
        if (kDebugMode) debugPrint('🔁 Ejecutando reload pendiente…');
        // No esperamos el Future para no bloquear; lanza una nueva carga.
        // ignore: discarded_futures
        cargarAgenda();
      }
    }
  }

  void _escucharSockets() {
    // En tu backend/Angular he visto 'trabajoAgendadoTecnico' y 'trabajoAgendado'
    const posibles = ['trabajoAgendadoTecnico', 'trabajoAgendado'];

    for (final ev in posibles) {
      _socket.off(ev); // evita duplicados si el controller se re-crea
      _socket.on(ev, (dynamic _) {
        if (kDebugMode) debugPrint('🔔 socket "$ev" -> recargar agenda');
        SnackbarService.success('Agenda actualizada');
        // Si ya está cargando, se marcará _pendingReload dentro de cargarAgenda()
        // y se recargará automáticamente al terminar.
        // ignore: discarded_futures
        cargarAgenda();
      });
    }
  }

  DateTime _parseFecha(String? iso) {
    try {
      if (iso == null || iso.isEmpty)
        return DateTime.fromMillisecondsSinceEpoch(0);
      return DateTime.parse(
        iso,
      ); // asume ISO; si tu backend envía otro formato, ajusta aquí
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  int _parseHora(String? hhmm) {
    try {
      if (hhmm == null || hhmm.isEmpty) return 24 * 60; // inválida -> al final
      final parts = hhmm.split(':');
      final h = int.parse(parts[0]);
      final m = parts.length > 1 ? int.parse(parts[1]) : 0;
      return h * 60 + m;
    } catch (_) {
      return 24 * 60; // inválida -> al final
    }
  }
}
