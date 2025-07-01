import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'package:redecom_app/src/models/user.dart';
import 'package:redecom_app/src/utils/socket_service.dart';

class AuthService extends GetxService {
  final _storage = GetStorage();

  User? get currentUser {
    final data = _storage.read('user');
    return data != null ? User.fromJson(data) : null;
  }

  String? get token => _storage.read('token');
  int? get userId => _storage.read('usuario_id');

  bool get isLoggedIn => token != null && !Jwt.isExpired(token!);

  Future<void> login(User user, String token) async {
    user.sessionToken = token;

    _storage.write('token', token);
    _storage.write('user', user.toJson());
    if (user.id != null) {
      _storage.write('usuario_id', user.id);
    }
  }

  void logout() {
    _storage.erase();

    if (Get.isRegistered<SocketService>()) {
      Get.find<SocketService>().disposeSocket();
    }

    Get.offAllNamed('/login');
  }
}
