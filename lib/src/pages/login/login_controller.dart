import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:redecom_app/src/models/response_api.dart';
import 'package:redecom_app/src/models/user.dart';
import 'package:redecom_app/src/providers/login_provider.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';
import 'package:redecom_app/src/utils/auth_service.dart';
import 'package:redecom_app/src/utils/socket_service.dart';

class LoginController extends GetxController {
  TextEditingController usuarioController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  LoginProvider loginProvider = LoginProvider();

  void login() async {
    String usuario = usuarioController.text.trim();
    String password = passwordController.text.trim();

    if (!await isValidForm(usuario, password)) return;

    ResponseApi responseApi = await loginProvider.login(usuario, password);
    debugPrint('Respuesta del backend: ${responseApi.toJson()}');

    if (responseApi.success == true) {
      String token = responseApi.token ?? '';

      if (Jwt.isExpired(token)) {
        SnackbarService.error('Tu sesión ha expirado, vuelve a iniciar sesión');
        return;
      }

      Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
      User user = User.fromJson(decodedToken);

      // 1️⃣ Guardar sesión
      await Get.find<AuthService>().login(user, token);

      // 2️⃣ Inicializar el socket con usuario_id ya disponible
      await Get.find<SocketService>().init();

      goToHomePage();
    } else {
      SnackbarService.warning(responseApi.message ?? 'Error desconocido');
    }
  }

  Future<bool> isValidForm(String usuario, String password) async {
    if (usuario.isEmpty) {
      SnackbarService.warning('Ingresa el usuario');
      return false;
    }

    if (password.isEmpty) {
      SnackbarService.warning('Ingresa la contraseña');
      return false;
    }

    return true;
  }

  void goToHomePage() {
    Get.offAllNamed('/home');
  }
}
