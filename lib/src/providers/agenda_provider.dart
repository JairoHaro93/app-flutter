import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/environmets/environment.dart';
import 'package:redecom_app/src/models/trabajo.dart';

class AgendaProvider extends GetConnect {
  final String _urlBase = "${Environment.API_URL}agenda";

  Future<List<Trabajo>> getAgendaTec(int tecnicoId) async {
    final token = GetStorage().read('token');

    final response = await get(
      '$_urlBase/mis-trabajos-tec/$tecnicoId',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('📡 GET trabajos agendados: $_urlBase/mis-trabajos-tec/$tecnicoId');

    if (response.statusCode == 200 && response.body != null) {
      List<dynamic> body = response.body;
      return body.map((item) => Trabajo.fromJson(item)).toList();
    } else {
      final errorMsg =
          response.body?['message'] ?? 'Error al obtener trabajos agendados';
      throw Exception('❌ [${response.statusCode}] $errorMsg');
    }
  }

  Future<void> actualizarAgendaSolucion(int age_id, Trabajo trabajo) async {
    final token = GetStorage().read('token');

    final response = await put(
      '$_urlBase/edita-sol/$age_id',
      trabajo.toSolucionJson(),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('📡 PUT trabajo CONCLUIDO: $_urlBase/edita-sol/$age_id');
    print('📥 Status: ${response.statusCode}');
    print('📥 Response body: ${response.body}');

    if (response.statusCode! < 200 || response.statusCode! >= 300) {
      print('❌ PUT falló: ${response.statusCode}');
      final message =
          response.body is Map && response.body?['message'] != null
              ? response.body['message']
              : 'Error al actualizar solución';
      throw Exception('❌ [$response.statusCode] $message');
    }
  }
}
