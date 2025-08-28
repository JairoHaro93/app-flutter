// lib/src/pages/login/login_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jwt_decode/jwt_decode.dart';

import 'package:redecom_app/src/models/response_api.dart';
import 'package:redecom_app/src/models/user.dart';
import 'package:redecom_app/src/providers/login_provider.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';
import 'package:redecom_app/src/utils/auth_service.dart';
import 'package:redecom_app/src/utils/socket_service.dart';

class LoginController extends GetxController {
  // Text controllers
  final usuarioController = TextEditingController();
  final passwordController = TextEditingController();

  // Estado para la UI
  final isLoading = false.obs;
  final passwordVisible = false.obs;

  // Dependencias
  late final LoginProvider _loginProvider;
  late final AuthService _auth;
  late final SocketService _socket;

  @override
  void onInit() {
    super.onInit();
    _loginProvider =
        Get.isRegistered<LoginProvider>()
            ? Get.find<LoginProvider>()
            : LoginProvider();
    _auth = Get.find<AuthService>();
    _socket = Get.find<SocketService>();
  }

  @override
  void onClose() {
    usuarioController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> login() async {
    if (isLoading.value) return;

    final usuario = usuarioController.text.trim();
    final password = passwordController.text.trim();

    if (usuario.isEmpty) {
      SnackbarService.warning('Ingresa el usuario');
      return;
    }
    if (password.isEmpty) {
      SnackbarService.warning('Ingresa la contraseña');
      return;
    }

    isLoading.value = true;
    try {
      final ResponseApi r = await _loginProvider.login(usuario, password);

      if (r.success != true) {
        SnackbarService.warning(r.message ?? 'Credenciales inválidas');
        return;
      }

      final token = (r.token ?? '').trim();
      if (token.isEmpty) {
        SnackbarService.error('Token vacío en la respuesta');
        return;
      }

      // Valida expiración y parseo
      try {
        if (Jwt.isExpired(token)) {
          SnackbarService.error(
            'Tu sesión ha expirado, vuelve a iniciar sesión',
          );
          return;
        }
      } catch (_) {
        SnackbarService.error('Token inválido');
        return;
      }

      Map<String, dynamic> payload;
      try {
        payload = Jwt.parseJwt(token);
      } catch (_) {
        SnackbarService.error('No se pudo leer el token');
        return;
      }

      final user = User.fromJson(payload);

      // Guarda sesión e inicia socket
      await _auth.login(user, token);
      await _socket.init();

      // Navega a Home
      Get.offAllNamed('/home');
    } catch (e) {
      SnackbarService.error('Error de autenticación: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
