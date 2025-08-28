import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:redecom_app/src/environmets/environment.dart';

class SocketService extends GetxService {
  IO.Socket? _socket;
  bool _initialized = false;

  bool get isConnected => _socket?.connected == true;

  // ⚠️ No auto-llamar init en onInit().
  // Espera a que el LoginController te invoque tras guardar usuario_id.
  @override
  void onClose() {
    disposeSocket();
    super.onClose();
  }

  /// Inicializa y conecta el socket usando el usuario_id guardado en GetStorage.
  Future<SocketService> init() async {
    if (_initialized && _socket != null) return this;
    final box = GetStorage();
    final userId = box.read('usuario_id');

    if (userId == null) {
      // No hay sesión aún (login no hecho)
      return this;
    }

    _initialized = true;

    final url = '${Environment.API_WEBSOKETS}?usuario_id=$userId';

    _socket = IO.io(
      url,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .enableReconnection() // reconexión habilitada
          .setReconnectionAttempts(10)
          .setReconnectionDelay(1000)
          .enableAutoConnect() // se conecta automáticamente
          .build(),
    );

    // Handlers
    _socket!.onConnect((_) {
      if (kDebugMode) debugPrint('✅ Socket conectado (usuario_id: $userId)');
    });

    _socket!.onDisconnect((_) {
      if (kDebugMode) debugPrint('🔌 Socket desconectado');
    });

    _socket!.onConnectError((err) {
      if (kDebugMode) debugPrint('⛔ Socket connect error: $err');
    });

    _socket!.onError((err) {
      if (kDebugMode) debugPrint('⛔ Socket error: $err');
    });

    return this;
  }

  // ---------- API de conveniencia ----------
  void emit(String event, dynamic data) {
    final s = _socket;
    if (s == null || s.disconnected) {
      if (kDebugMode)
        debugPrint('⚠️ No se pudo emitir "$event": socket no listo');
      return;
    }
    s.emit(event, data);
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
