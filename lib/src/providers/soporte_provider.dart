import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/environmets/environment.dart';
import 'package:redecom_app/src/models/soporte.dart';

class SoporteProvider extends GetConnect {
  SoporteProvider() {
    httpClient.baseUrl = Environment.API_URL; // ej: http://IP:PORT/api/
    httpClient.timeout = const Duration(seconds: 20);

    httpClient.addRequestModifier<dynamic>((r) {
      final token = GetStorage().read('token')?.toString();
      if (token != null && token.isNotEmpty) {
        r.headers['Authorization'] = 'Bearer $token';
      }
      if (r.method != 'get') {
        r.headers['Content-Type'] = 'application/json';
        r.headers['Accept'] = 'application/json';
      }
      return r;
    });
  }

  Future<Soporte?> getById(int id) async {
    final resp = await get('soportes/$id');
    final code = resp.statusCode ?? 0;
    final body = resp.body;

    if (code >= 200 && code < 300) {
      if (body is Map) {
        return Soporte.fromJson(Map<String, dynamic>.from(body));
      }
      if (body is List && body.isNotEmpty && body.first is Map) {
        return Soporte.fromJson(Map<String, dynamic>.from(body.first));
      }
      return null; // 200 pero vacío
    }

    throw Exception(
      '[${code}] ${_extractError(body) ?? 'Error al obtener soporte'}',
    );
  }

  Future<void> actualizarEstado(int idSop, Map<String, dynamic> body) async {
    final resp = await put('soportes/mis-soportes/solucion/$idSop', body);
    final code = resp.statusCode ?? 0;
    if (code >= 200 && code < 300) return;

    throw Exception(
      '[${code}] ${_extractError(resp.body) ?? 'Error al actualizar soporte'}',
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
