import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'package:redecom_app/src/models/response_api.dart';
import 'package:redecom_app/src/models/user.dart';
import 'package:redecom_app/src/providers/login_provider.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';

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
      user.sessionToken = token;

      final storage = GetStorage();
      storage.write('token', token);
      storage.write('user', user.toJson());

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
