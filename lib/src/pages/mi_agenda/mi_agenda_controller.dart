import 'package:get/get.dart';
import 'package:redecom_app/src/models/agenda.dart';
import 'package:redecom_app/src/providers/agenda_provider.dart';
import 'package:redecom_app/src/utils/socket_service.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';

class MiAgendaController extends GetxController {
  // ✅ registra el provider con Get para evitar múltiples instancias y asegurar lifecycle
  final AgendaProvider _agendaProvider = Get.put(
    AgendaProvider(),
    permanent: true,
  );

  late final SocketService _socket;

  final trabajos = <Agenda>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _socket = Get.find<SocketService>();
    _escucharSockets();

    // 🔎 log de arranque
    // ignore: avoid_print
    print('📅 MiAgendaController.onInit -> cargarAgenda()');
    cargarAgenda();
  }

  @override
  void onClose() {
    _socket.off('trabajoAgendado');
    super.onClose();
  }

  Future<void> cargarAgenda() async {
    if (isLoading.value) {
      // ignore: avoid_print
      print('⏳ cargarAgenda: ya hay una carga en curso, saliendo...');
      return;
    }

    isLoading.value = true;

    // ignore: avoid_print
    print('➡️ cargarAgenda: solicitando trabajos...');

    try {
      final lista = await _agendaProvider.getAgendaTec();

      // ignore: avoid_print
      print('✅ cargarAgenda: recibidos ${lista.length} trabajos');

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
      // ignore: avoid_print
      print('❌ cargarAgenda ERROR: $e\n$st');
      SnackbarService.error(e.toString());
    } finally {
      isLoading.value = false;
      // ignore: avoid_print
      print('🏁 cargarAgenda: finalizado (isLoading=false)');
    }
  }

  void _escucharSockets() {
    // Angular emite 'trabajoAgendadoTecnico'
    const posibles = [
      'trabajoAgendadoTecnico',
      'trabajoAgendado',
    ]; // escucha ambos por ahora
    for (final ev in posibles) {
      _socket.off(ev);
      _socket.on(ev, (dynamic _) {
        // ignore: avoid_print
        print('🔔 socket "$ev" -> recargar agenda');
        cargarAgenda();
        SnackbarService.success('Agenda actualizada');
      });
    }
  }

  DateTime _parseFecha(String iso) {
    try {
      return DateTime.parse(iso);
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  int _parseHora(String hhmm) {
    try {
      final parts = hhmm.split(':');
      final h = int.parse(parts[0]);
      final m = parts.length > 1 ? int.parse(parts[1]) : 0;
      return h * 60 + m;
    } catch (_) {
      return -1;
    }
  }
}
