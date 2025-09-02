import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/environments/environment.dart';

class VisProvider extends GetConnect {
  // ✅ inicializado directamente (sin late, sin onInit para esto)
  final String _urlBase = '${Environment.API_URL}vis';

  VisProvider() {
    httpClient.timeout = const Duration(seconds: 20);

    // Inyección de token + content-type
    httpClient.addRequestModifier<dynamic>((request) {
      final token = GetStorage().read('token');
      if (token != null && token.toString().isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Content-Type'] = 'application/json';
      return request;
    });

    // (Opcional) logs
    httpClient.addRequestModifier<dynamic>((r) {
      print('➡️ ${r.method} ${r.url}');
      return r;
    });
    httpClient.addResponseModifier<dynamic>((req, res) {
      print('⬅️ ${res.statusCode} ${req.url}');
      print('🧾 Body: ${res.bodyString}');
      return res;
    });
  }

  Future<Map<String, dynamic>> getVisById(int id) async {
    final resp = await get('$_urlBase/$id');
    final code = resp.statusCode ?? 0;
    if (code >= 200 && code < 300 && resp.body is Map) {
      return (resp.body as Map).cast<String, dynamic>();
    }
    throw Exception(
      '[${code}] ${_extractError(resp.body) ?? 'Error al obtener VIS/LOS'}',
    );
  }

  Future<void> updateVisById(int id, String estado, [String? solucion]) async {
    final payload = <String, dynamic>{
      'vis_estado': estado,
      if (solucion != null && solucion.trim().isNotEmpty)
        'vis_solucion': solucion.trim(),
    };
    await updateVisByIdRaw(id, payload);
  }

  Future<void> updateVisByIdRaw(int id, Map<String, dynamic> payload) async {
    final resp = await put('$_urlBase/$id', payload);
    final code = resp.statusCode ?? 0;
    if (code >= 200 && code < 300) return;
    throw Exception(
      '[${code}] ${_extractError(resp.body) ?? 'Error al actualizar VIS/LOS'}',
    );
  }

  String? _extractError(dynamic body) {
    if (body == null) return null;
    if (body is Map) {
      if (body['message'] != null) return body['message'].toString();
      if (body['error'] != null) return body['error'].toString();
      if (body['msg'] != null) return body['msg'].toString();
    }
    if (body is List && body.isNotEmpty) return body.first.toString();
    return body.toString();
  }
}
