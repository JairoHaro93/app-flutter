import 'dart:convert';
import 'dart:async';

import 'package:get/get.dart';
import 'package:redecom_app/src/environmets/environment.dart';
import 'package:redecom_app/src/models/response_api.dart';

class LoginProvider extends GetConnect {
  LoginProvider() {
    httpClient.baseUrl = Environment.API_URL; // termina en /api/
    httpClient.timeout = const Duration(seconds: 20);

    httpClient.addRequestModifier<dynamic>((req) {
      // Aceptamos JSON; GetConnect pondrá Content-Type adecuado si body es Map
      req.headers['Accept'] = 'application/json';
      return req;
    });
  }

  Future<ResponseApi> login(String usuario, String password) {
    return _postJson('login/app', {'usuario': usuario, 'password': password});
  }

  Future<ResponseApi> logout(int usuarioId) {
    return _postJson('login/notapp', {'usuario_id': usuarioId});
  }

  // ------------------ PRIVADO ------------------

  Future<ResponseApi> _postJson(String path, Map<String, dynamic> body) async {
    try {
      final resp = await post(path, body);

      // Si el servidor no respondió
      if (resp.statusCode == null) {
        return ResponseApi(
          success: false,
          message: 'Sin respuesta del servidor ${Environment.API_IP} ',
        );
      }

      // Intenta mapear el body
      final parsed = _parseBody(resp.body, resp.bodyString);

      // 200–299 => OK
      if ((resp.statusCode ?? 0) >= 200 && (resp.statusCode ?? 0) < 300) {
        return ResponseApi.fromJson(parsed ?? {});
      }

      // Errores HTTP => trata de extraer mensaje útil
      final msg =
          (parsed?['message'] ??
                  parsed?['error'] ??
                  'Error HTTP ${resp.statusCode}')
              .toString();
      return ResponseApi(success: false, message: msg);
    } on TimeoutException {
      return ResponseApi(success: false, message: 'Tiempo de espera agotado');
    } on Exception catch (e) {
      return ResponseApi(success: false, message: 'Error de red: $e');
    }
  }

  Map<String, dynamic>? _parseBody(dynamic body, String? bodyString) {
    if (body is Map<String, dynamic>) return body;
    if (body is Map) return body.cast<String, dynamic>();
    if (bodyString != null && bodyString.isNotEmpty) {
      try {
        final decoded = json.decode(bodyString);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) return decoded.cast<String, dynamic>();
      } catch (_) {}
    }
    return null;
  }
}
