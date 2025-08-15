import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/environmets/environment.dart';
import 'package:redecom_app/src/models/trabajo.dart';

class AgendaProvider extends GetConnect {
  final String _urlBase = "${Environment.API_URL}agenda";

  AgendaProvider() {
    httpClient.timeout = const Duration(seconds: 20);

    // Logs de request
    httpClient.addRequestModifier<dynamic>((request) {
      // ignore: avoid_print
      print('➡️ ${request.method} ${request.url}');
      // ignore: avoid_print
      print('🧩 Headers: ${request.headers}');
      return request;
    });

    // Inyección de token y content-type
    httpClient.addRequestModifier<dynamic>((request) {
      final token = GetStorage().read('token');
      if (token != null && token.toString().isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Content-Type'] = 'application/json';
      return request;
    });

    // Logs de response
    httpClient.addResponseModifier<dynamic>((request, response) {
      // ignore: avoid_print
      print('⬅️ ${response.statusCode} ${request?.url}');
      // ignore: avoid_print
      print('🧾 Body: ${response.bodyString}');
      return response;
    });
  }

  /// Obtiene la agenda del técnico autenticado (o de [tecnicoId] si se pasa).
  Future<List<Trabajo>> getAgendaTec([int? tecnicoId]) async {
    final box = GetStorage();
    final id = tecnicoId ?? box.read('usuario_id');
    if (id == null) {
      throw Exception('No se encontró el ID del técnico en sesión.');
    }

    final url = '$_urlBase/mis-trabajos-tec/$id';

    // ignore: avoid_print
    print('🔗 GET $url');
    // ignore: avoid_print
    print('🌍 API_URL: ${Environment.API_URL}');
    // ignore: avoid_print
    print(
      '🔐 Token presente: ${box.read('token') != null && box.read('token').toString().isNotEmpty}',
    );

    final resp = await get(url);

    final code = resp.statusCode ?? 0;
    final body = resp.body;

    if (code >= 200 && code < 300 && body != null) {
      if (body is List) {
        return body.map<Trabajo>((e) => Trabajo.fromJson(e)).toList();
      }
      if (body is Map && body['data'] is List) {
        return (body['data'] as List)
            .map<Trabajo>((e) => Trabajo.fromJson(e))
            .toList();
      }
      throw Exception('Formato de respuesta no esperado al obtener la agenda.');
    }

    throw Exception(
      '[${code}] ${_extractError(body) ?? 'Error al obtener trabajos agendados'}',
    );
  }

  /// Marca un trabajo como CONCLUIDO actualizando la solución.
  /// Versión que recibe un MAP ya listo (por si quieres controlar el payload).
  /// Espera algo como: { "age_id": id, "age_estado": "CONCLUIDO", "age_solucion": "..." }
  Future<void> actualizarAgendaSolucion(
    int ageId,
    Map<String, dynamic> payload,
  ) async {
    // ignore: avoid_print
    print('📝 PUT $_urlBase/edita-sol/$ageId');
    // ignore: avoid_print
    print('📦 Payload: $payload');

    final resp = await put('$_urlBase/edita-sol/$ageId', payload);
    final code = resp.statusCode ?? 0;

    // 200/201/204 -> OK
    if ((code >= 200 && code < 300)) return;

    throw Exception(
      '[${code}] ${_extractError(resp.body) ?? 'Error al actualizar solución'}',
    );
  }

  /// Wrapper conveniente: acepta directamente un [Trabajo] y construye el payload
  /// vía `t.toSolucionJson()`.
  Future<void> actualizarAgendaSolucionByTrabajo(int ageId, Trabajo t) async {
    await actualizarAgendaSolucion(ageId, t.toSolucionJson());
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
