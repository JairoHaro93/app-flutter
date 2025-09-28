// lib/src/providers/infraestructura_provider.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/environments/environment.dart';
import 'package:redecom_app/src/models/infraestructura.dart';
import 'package:redecom_app/src/models/infraestructura.dart';

class InfraestructuraProvider extends GetConnect {
  InfraestructuraProvider() {
    httpClient.baseUrl = Environment.API_URL; // p.ej. http://IP:PORT/api/
    httpClient.timeout = const Duration(seconds: 20);

    // Token + headers (mismo patrón que AgendaProvider)
    httpClient.addRequestModifier<dynamic>((request) {
      final raw = GetStorage().read('token')?.toString() ?? '';
      if (raw.isNotEmpty) {
        final token =
            raw.toLowerCase().startsWith('bearer ') ? raw : 'Bearer $raw';
        request.headers['Authorization'] = token;
      }
      if (request.method.toLowerCase() != 'get') {
        request.headers['Content-Type'] = 'application/json';
        request.headers['Accept'] = 'application/json';
      }
      return request;
    });
  }

  // ---------- Endpoints ----------

  /// GET /infraestructura/agenda/:id_agenda
  /// Devuelve el detalle unificado (agenda + infraestructura).
  Future<Infraestructura> getTrabajoInfraByAgendaId(int agendaId) async {
    final resp = await get('infraestructura/agenda/$agendaId');
    final code = resp.statusCode ?? 0;
    final body = resp.body;

    if (code >= 200 && code < 300 && body != null) {
      final Map<String, dynamic> map =
          (body is Map)
              ? Map<String, dynamic>.from(body as Map)
              : json.decode(resp.bodyString ?? '{}') as Map<String, dynamic>;
      return Infraestructura.fromJson(map);
    }

    throw Exception(
      '[${code}] ${_extractError(body) ?? 'Error al obtener el trabajo de infraestructura'}',
    );
  }

  /// GET /infraestructura/:id_infra
  /// Devuelve solo la infraestructura (objeto plano).
  Future<Infraestructura> getInfraestructuraById(int infraId) async {
    final resp = await get('infraestructura/$infraId');
    final code = resp.statusCode ?? 0;
    final body = resp.body;

    if (code >= 200 && code < 300 && body != null) {
      final Map<String, dynamic> map =
          (body is Map)
              ? Map<String, dynamic>.from(body as Map)
              : json.decode(resp.bodyString ?? '{}') as Map<String, dynamic>;
      return Infraestructura.fromJson(map);
    }

    throw Exception(
      '[${code}] ${_extractError(body) ?? 'Error al obtener la infraestructura'}',
    );
  }

  // ---------- Helpers ----------

  String? _extractError(dynamic body) {
    if (body == null) return null;
    if (body is Map) {
      if (body['message'] != null) return body['message'].toString();
      if (body['error'] != null) return body['error'].toString();
      if (body['msg'] != null) return body['msg'].toString();
      if (body['data'] is String) return body['data'].toString();
    }
    if (body is List && body.isNotEmpty) return body.first.toString();
    if (body is String && body.isNotEmpty) return body;
    return null;
  }
}
