import 'package:get/get_connect/connect.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/environmets/environment.dart';
import 'package:redecom_app/src/models/soporte.dart';

class SoporteProvider extends GetConnect {
  final String urlBase = '${Environment.API_URL}/soportes';

  Future<Soporte> getSopById(int id) async {
    final token = GetStorage().read('token');
    final response = await get(
      '$urlBase/$id',
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200 && response.body != null) {
      return Soporte.fromJson(response.body);
    } else {
      final errorMsg =
          response.body?['message'] ??
          'No se pudo obtener el soporte con ID $id';
      throw Exception('❌ [${response.statusCode}] $errorMsg');
    }
  }
}
