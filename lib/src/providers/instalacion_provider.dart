// lib/src/providers/instalacion_provider.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/environmets/environment.dart';
import 'package:redecom_app/src/models/instalacion.dart';

class InstalacionProvider extends GetConnect {
  InstalacionProvider() {
    httpClient.baseUrl = Environment.API_URL; // p.ej. http://IP:PORT/api/
    httpClient.timeout = const Duration(seconds: 20);

    httpClient.addRequestModifier<dynamic>((request) {
      final token = GetStorage().read('token')?.toString();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      // Solo métodos con body necesitan forzar content-type/accept
      if (request.method != 'get') {
        request.headers['Content-Type'] = 'application/json';
        request.headers['Accept'] = 'application/json';
      }
      return request;
    });
  }

  /// MySQL: devuelve una fila por ord_ins
  /// GET /api/instalaciones/{ordIns}
  Future<Instalacion?> getInstalacionByOrdIns(int ordIns) async {
    final resp = await get('instalaciones/$ordIns');
    final code = resp.statusCode ?? 0;
    final body = resp.body;

    if (code >= 200 && code < 300) {
      if (body is Map) {
        return Instalacion.fromJson(Map<String, dynamic>.from(body));
      }
      if (body is List && body.isNotEmpty) {
        final first = body.first;
        if (first is Map) {
          return Instalacion.fromJson(Map<String, dynamic>.from(first as Map));
        }
      }
      // 200 sin fila
      return null;
    }

    throw Exception(
      '[${code}] ${_extractError(body) ?? 'Error al obtener instalación MySQL'}',
    );
  }

  // ----------------- helpers -----------------

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
