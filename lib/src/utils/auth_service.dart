import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'package:redecom_app/src/models/user.dart';
import 'package:redecom_app/src/utils/socket_service.dart';

class AuthService extends GetxService {
  final _storage = GetStorage();

  // Claves de storage (evita typos)
  static const _kToken = 'token';
  static const _kUser = 'user';
  static const _kUserId = 'usuario_id';
  static const _kFirstInstall = 'first_install_done';

  User? get currentUser {
    final data = _storage.read(_kUser);
    return data != null ? User.fromJson(data) : null;
  }

  String? get token => _storage.read(_kToken);
  int? get userId => _storage.read(_kUserId);

  bool get isLoggedIn {
    final t = token;
    if (t == null || t.isEmpty) return false;
    try {
      return !Jwt.isExpired(t);
    } catch (_) {
      return false;
    }
  }

  Map<String, String> get authHeader {
    final t = token;
    return t != null && t.isNotEmpty ? {'Authorization': 'Bearer $t'} : {};
  }

  Future<void> login(User user, String sessionToken) async {
    user.sessionToken = sessionToken;

    await _storage.write(_kToken, sessionToken);
    await _storage.write(_kUser, user.toJson());
    if (user.id != null) {
      await _storage.write(_kUserId, user.id);
    }
  }

  /// Refresca el usuario en storage (por si cambias nombre, roles, etc.)
  Future<void> refreshUser(User user) async {
    await _storage.write(_kUser, user.toJson());
    if (user.id != null) {
      await _storage.write(_kUserId, user.id);
    }
  }

  /// Lanza si no hay sesión válida (útil en providers/controladores)
  void requireAuth() {
    if (!isLoggedIn) {
      Get.offAllNamed('/'); // o Routes.login si usas constantes
      throw Exception('Sesión no válida');
    }
  }

  Future<void> logout() async {
    // 1) Cierra socket si existe
    if (Get.isRegistered<SocketService>()) {
      try {
        Get.find<SocketService>().disposeSocket();
      } catch (_) {}
    }

    // 2) Limpia SOLO claves de sesión (no borres first_install_done)
    await _storage.remove(_kToken);
    await _storage.remove(_kUser);
    await _storage.remove(_kUserId);

    // 3) Navega al login (en tu app es '/')
    Get.offAllNamed('/'); // o Routes.login
  }
}
