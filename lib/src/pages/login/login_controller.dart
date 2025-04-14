import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'package:redecom_app/src/models/response_api.dart';
import 'package:redecom_app/src/models/user.dart';
import 'package:redecom_app/src/providers/login_provider.dart';

class LoginController extends GetxController {
  TextEditingController usuarioController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  LoginProvider loginProvider = LoginProvider();

  void login() async {
    String usuario = usuarioController.text.trim();
    String password = passwordController.text.trim();

    if (!await isValidForm(usuario, password)) return;

    // Hacemos la petición al backend
    ResponseApi responseApi = await loginProvider.login(usuario, password);
    print('Respuesta del backend: ${responseApi.toJson()}');

    if (responseApi.message == "Login Correcto") {
      String token = responseApi.token ?? '';

      // Decodificamos el JWT
      Map<String, dynamic> decodedToken = Jwt.parseJwt(token);
      print('Datos decodificados del token: $decodedToken');

      // Creamos el User desde el token
      User user = User.fromJson(decodedToken);
      user.sessionToken = token;

      // Guardamos el token y el usuario en local
      final storage = GetStorage();
      storage.write('token', token);
      storage.write('user', user.toJson());

      goToHomePage();
    } else {
      Get.snackbar(
        'Login Fallido',
        responseApi.message ?? 'Error desconocido',
        backgroundColor: Colors.amber,
        colorText: Colors.white,
      );
    }
  }

  Future<bool> isValidForm(String usuario, String password) async {
    if (usuario.isEmpty) {
      Get.snackbar(
        'Formulario inválido',
        'Ingresa el usuario',
        backgroundColor: Colors.amber,
        colorText: Colors.white,
      );
      return false;
    }

    if (password.isEmpty) {
      Get.snackbar(
        'Formulario inválido',
        'Ingresa la contraseña',
        backgroundColor: Colors.amber,
        colorText: Colors.white,
      );

      return false;
    }

    return true;
  }

  void goToHomePage() {
    Get.offAllNamed('/home');
  }
}
