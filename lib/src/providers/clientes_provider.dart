// lib/src/providers/clientes_provider.dart
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/environmets/environment.dart';

class ClientesProvider extends GetConnect {
  final String _urlBase = '${Environment.API_URL}clientes';

  ClientesProvider() {
    httpClient.timeout = const Duration(seconds: 20);

    httpClient.addRequestModifier<dynamic>((r) {
      final token = GetStorage().read('token');
      if (token != null && token.toString().isNotEmpty) {
        r.headers['Authorization'] = 'Bearer $token';
        r.headers['x-token'] = token.toString();
        r.headers['Cookie'] = 'token=${token.toString()}';
      }
      r.headers['Content-Type'] = 'application/json';
      print('➡️ ${r.method} ${r.url}');
      return r;
    });

    httpClient.addResponseModifier<dynamic>((req, res) {
      print('⬅️ ${res.statusCode} ${req?.url}');
      print('🧾 Body: ${res.bodyString}');
      return res;
    });
  }

  /// SQL Server: info de cliente/servicio por ORD_INS (tu backend usa /clientes/{ordIns})
  Future<Map<String, dynamic>> getInfoServicioByOrdId(int ordIns) async {
    final url = '$_urlBase/$ordIns';
    print('🔗 GET $url');

    final resp = await get(url);
    final code = resp.statusCode ?? 0;

    if (code >= 200 && code < 300) {
      final b = resp.body;
      if (b is Map<String, dynamic>) return Map<String, dynamic>.from(b);
      if (b is List && b.isNotEmpty) {
        final first = b.first;
        return first is Map<String, dynamic>
            ? Map<String, dynamic>.from(first)
            : {'value': first};
      }
      return {};
    }

    print('❌ Error getInfoServicioByOrdId [$code], body: ${resp.bodyString}');
    throw Exception('Error al obtener info de cliente [$code]');
  }
}
