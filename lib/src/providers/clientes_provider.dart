// lib/src/providers/clientes_provider.dart
import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/environmets/environment.dart';

class ClientesProvider extends GetConnect {
  ClientesProvider() {
    httpClient.baseUrl = Environment.API_URL; // http://IP:PORT/api/
    httpClient.timeout = const Duration(seconds: 20);

    httpClient.addRequestModifier<dynamic>((r) {
      final token = GetStorage().read('token')?.toString();
      if (token != null && token.isNotEmpty) {
        r.headers['Authorization'] = 'Bearer $token';
        // Si tu backend lo requiere, descomenta:
        // r.headers['x-token'] = token;
        // r.headers['Cookie'] = 'token=$token';
      }
      if (r.method != 'get') {
        r.headers['Content-Type'] = 'application/json';
        r.headers['Accept'] = 'application/json';
      }
      return r;
    });
  }

  /// GET /api/clientes/{ordIns}
  Future<Map<String, dynamic>> getInfoServicioByOrdId(int ordIns) async {
    final Response resp = await get('clientes/$ordIns');
    final int code = resp.statusCode ?? 0;
    final body = resp.body;

    if (kDebugMode) {
      debugPrint('GET clientes/$ordIns -> $code');
    }

    // 404: sin datos
    if (code == 404) return <String, dynamic>{};

    if (code >= 200 && code < 300) {
      if (body is Map) {
        return Map<String, dynamic>.from(body as Map);
      }
      if (body is List && body.isNotEmpty) {
        final first = body.first;
        if (first is Map) {
          return Map<String, dynamic>.from(first as Map);
        }
        return {'value': first};
      }
      return <String, dynamic>{}; // 2xx pero sin body útil
    }

    throw Exception(
      '[${code}] ${_extractError(body) ?? 'Error al obtener info de cliente'}',
    );
  }

  String? _extractError(dynamic body) {
    if (body == null) return null;
    if (body is Map) {
      for (final k in const ['message', 'error', 'msg']) {
        final v = body[k];
        if (v != null) return v.toString();
      }
    }
    if (body is List && body.isNotEmpty) return body.first.toString();
    return body.toString();
  }
}
