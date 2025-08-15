import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:redecom_app/src/environmets/environment.dart';

class SocketService extends GetxService {
  IO.Socket? _socket;
  bool _initialized = false;

  bool get isConnected => _socket?.connected == true;

  @override
  void onInit() {
    super.onInit();
    // inicializa automáticamente
    // ignore: discarded_futures
    init();
  }

  Future<SocketService> init() async {
    if (_initialized) return this;
    _initialized = true;

    final userId = GetStorage().read('usuario_id');
    if (userId == null) {
      // ignore: avoid_print
      print('⚠️ Conexión sin usuario_id. No se conectará socket.');
      return this;
    }

    final url = '${Environment.API_WEBSOKETS}?usuario_id=$userId';
    // ignore: avoid_print
    print('🔌 Conectando socket a: $url');

    _socket = IO.io(url, {
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 1000,
    });

    _socket!.onConnect((_) {
      // ignore: avoid_print
      print('✅ Socket conectado (usuario_id: $userId)');
    });
    _socket!.onDisconnect((_) {
      // ignore: avoid_print
      print('🔌 Socket desconectado');
    });
    _socket!.onError((data) {
      // ignore: avoid_print
      print('⛔ Socket error: $data');
    });

    return this;
  }

  // ---------- API de conveniencia ----------
  void emit(String event, dynamic data) {
    final s = _socket;
    if (s == null) {
      // ignore: avoid_print
      print('⚠️ No se pudo emitir "$event": socket no inicializado');
      return;
    }
    if (s.connected) {
      s.emit(event, data);
    } else {
      // ignore: avoid_print
      print('⚠️ No se pudo emitir "$event": socket no conectado');
    }
  }

  void on(String event, void Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  /// Si pasas [handler], quita solo ese; si no, todos los del evento.
  void off(String event, [void Function(dynamic)? handler]) {
    if (handler != null) {
      _socket?.off(event, handler);
    } else {
      _socket?.off(event);
    }
  }

  void once(String event, void Function(dynamic) handler) {
    _socket?.once(event, handler);
  }

  void disposeSocket() {
    final s = _socket;
    if (s == null) return;
    try {
      if (s.connected) s.disconnect();
      s.dispose();
    } catch (_) {}
    _socket = null;
    _initialized = false;
  }
}
