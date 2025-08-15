// lib/src/providers/instalacion_provider.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/environmets/environment.dart';
import 'package:redecom_app/src/models/instalacion_mysql.dart';

class InstalacionProvider extends GetConnect {
  final String _urlBase = '${Environment.API_URL}instalaciones';

  InstalacionProvider() {
    httpClient.timeout = const Duration(seconds: 20);

    httpClient.addRequestModifier<dynamic>((request) {
      // Logs
      print('➡️ ${request.method} ${request.url}');
      // Token
      final token = GetStorage().read('token');
      if (token != null && token.toString().isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['x-token'] =
            token.toString(); // por si tu backend lo usa
        request.headers['Cookie'] = 'token=${token.toString()}';
      }
      request.headers['Content-Type'] = 'application/json';
      return request;
    });

    httpClient.addResponseModifier<dynamic>((req, res) {
      print('⬅️ ${res.statusCode} ${req?.url}');
      print('🧾 Body: ${res.bodyString}');
      return res;
    });
  }

  /// MySQL: devuelve una fila por ord_ins (tu backend usa /instalaciones/{ordIns})
  Future<InstalacionMysql?> getInstalacionMysqlByOrdIns(int ordIns) async {
    final url = '$_urlBase/$ordIns';
    print('🔗 GET $url');

    final resp = await get(url);
    final code = resp.statusCode ?? 0;
    final body = resp.body;

    if (code >= 200 && code < 300) {
      if (body is List &&
          body.isNotEmpty &&
          body.first is Map<String, dynamic>) {
        return InstalacionMysql.fromJson(body.first);
      }
      if (body is Map<String, dynamic>) {
        return InstalacionMysql.fromJson(body);
      }
      return null;
    }

    print(
      '❌ Error getInstalacionMysqlByOrdIns [$code] body: ${resp.bodyString}',
    );
    throw Exception('Error al obtener instalación MySQL [$code]');
  }
}
