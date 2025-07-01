import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:redecom_app/src/environmets/environment.dart';

class SocketService extends GetxService {
  late IO.Socket _socket;

  IO.Socket get socket => _socket;

  Future<SocketService> init() async {
    final userId = GetStorage().read('usuario_id');

    if (userId == null) {
      print('⚠️ Conexión sin usuario_id. No se conectará socket.');
      return this;
    }

    _socket = IO.io('${Environment.API_WEBSOKETS}?usuario_id=$userId', {
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket.connect();

    _socket.onConnect((_) {
      print('✅ Socket conectado como usuario_id: $userId');
    });

    _socket.onDisconnect((_) {
      print('🔌 Socket desconectado');
    });

    return this;
  }

  void emit(String event, dynamic data) {
    if (_socket.connected) {
      _socket.emit(event, data);
    } else {
      print('⚠️ No se pudo emitir $event: socket no conectado');
    }
  }

  void on(String event, Function(dynamic) callback) {
    _socket.on(event, callback);
  }

  void disposeSocket() {
    _socket.dispose();
  }
}
