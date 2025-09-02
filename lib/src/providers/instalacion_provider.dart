// lib/src/providers/instalacion_provider.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/environments/environment.dart';
import 'package:redecom_app/src/models/instalacion.dart';

class InstalacionProvider extends GetConnect {
  InstalacionProvider() {
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

  Future<Instalacion?> getInstalacionByOrdIns(int ordIns) async {
    final resp = await get('instalaciones/$ordIns');
    final code = resp.statusCode ?? 0;
    final body = resp.body;

    if (code >= 200 && code < 300) {
      if (body is Map)
        return Instalacion.fromJson(Map<String, dynamic>.from(body));
      if (body is List && body.isNotEmpty && body.first is Map) {
        return Instalacion.fromJson(
          Map<String, dynamic>.from(body.first as Map),
        );
      }
      return null;
    }

    throw Exception(
      '[${code}] ${_extractError(body) ?? 'Error al obtener instalación MySQL'}',
    );
  }

  /// ✅ Nuevo: PATCH /instalaciones/terminar/:ord_ins
  Future<void> terminarInstalacion({
    required int ordIns,
    required String coordenadas,
    required String ip,
  }) async {
    final payload = {
      'coordenadas': _normalizeCoords(coordenadas),
      'ip': ip.trim(),
    };

    final resp = await patch('instalaciones/terminar/$ordIns', payload);
    final code = resp.statusCode ?? 0;

    if (code >= 200 && code < 300) return;

    throw Exception(
      '[${code}] ${_extractError(resp.body) ?? 'No se pudo terminar la instalación'}',
    );
  }

  // -------- helpers --------
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

  String _normalizeCoords(String s) =>
      s.replaceAll(',,', ',').replaceAll(' ', '');
}
