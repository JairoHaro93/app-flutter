import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/environmets/environment.dart';
import 'package:redecom_app/src/models/agenda.dart';

class AgendaProvider extends GetConnect {
  AgendaProvider() {
    httpClient.baseUrl = Environment.API_URL; // p.ej. http://IP:PORT/api/
    httpClient.timeout = const Duration(seconds: 20);

    // Token en headers (estilo interceptor)
    httpClient.addRequestModifier<dynamic>((request) {
      final token = GetStorage().read('token')?.toString();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      // Solo métodos con cuerpo definen Content-Type
      if (request.method != 'get') {
        request.headers['Content-Type'] = 'application/json';
        request.headers['Accept'] = 'application/json';
      }
      return request;
    });
  }

  /// Agenda del técnico autenticado (o [tecnicoId]).
  Future<List<Agenda>> getAgendaTec([int? tecnicoId]) async {
    final id = tecnicoId ?? GetStorage().read('usuario_id');
    if (id == null) {
      throw Exception('No se encontró el ID del técnico en sesión.');
    }

    final resp = await get('agenda/mis-trabajos-tec/$id');
    final code = resp.statusCode ?? 0;
    final body = resp.body;

    if (code >= 200 && code < 300 && body != null) {
      if (body is List) {
        return body.map<Agenda>((e) => Agenda.fromJson(e)).toList();
      }
      if (body is Map && body['data'] is List) {
        return (body['data'] as List)
            .map<Agenda>((e) => Agenda.fromJson(e))
            .toList();
      }
      throw Exception('Formato de respuesta no esperado al obtener la agenda.');
    }

    throw Exception(
      '[${code}] ${_extractError(body) ?? 'Error al obtener trabajos agendados'}',
    );
  }

  /// Actualiza estado/solución de un trabajo.
  /// payload típico: { "age_id": id, "age_estado": "CONCLUIDO", "age_solucion": "..." }
  Future<void> actualizarAgendaSolucion(
    int ageId,
    Map<String, dynamic> payload,
  ) async {
    final resp = await put('agenda/edita-sol/$ageId', payload);
    final code = resp.statusCode ?? 0;
    if (code >= 200 && code < 300) return;
    throw Exception(
      '[${code}] ${_extractError(resp.body) ?? 'Error al actualizar solución'}',
    );
  }

  /// Azúcar: usa el payload mínimo desde el modelo.
  Future<void> actualizarAgendaSolucionByAgenda(int ageId, Agenda ag) async {
    await actualizarAgendaSolucion(ageId, ag.toSolucionJson());
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
