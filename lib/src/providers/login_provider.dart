import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redecom_app/src/environmets/environment.dart';
import 'package:redecom_app/src/models/response_api.dart';

class LoginProvider extends GetConnect {
  final String _url = "${Environment.API_URL}login";

  Future<ResponseApi> login(String usuario, String password) async {
    return await _postRequest('$_url/app', {
      'usuario': usuario,
      'password': password,
    });
  }

  Future<ResponseApi> logout(int usuarioId) async {
    return await _postRequest('$_url/notapp', {'usuario_id': usuarioId});
  }

  Future<ResponseApi> _postRequest(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final Response response = await post(
      endpoint,
      body,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.body == null) {
      Get.snackbar(
        'Error',
        'No se pudo ejecutar la petición',
        backgroundColor: Colors.amber,
        colorText: Colors.white,
      );
      return ResponseApi();
    }

    return ResponseApi.fromJson(response.body);
  }
}
