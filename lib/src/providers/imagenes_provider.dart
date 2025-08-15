import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:redecom_app/src/environmets/environment.dart';
import 'package:redecom_app/src/models/imagen_instalacion.dart';

class ImagenesProvider extends GetConnect {
  // Asegúrate que Environment.API_URL termine en "/"
  final String _urlBase = '${Environment.API_URL}imagenes';

  ImagenesProvider() {
    httpClient.timeout = const Duration(seconds: 20);

    // Logs de request
    httpClient.addRequestModifier<dynamic>((request) {
      // ignore: avoid_print
      print('➡️ ${request.method} ${request.url}');
      return request;
    });

    // Inyección de token y content-type JSON por defecto (GET)
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

  /// Descarga imágenes por tabla e id.
  /// Ej: tabla='neg_t_instalaciones', id=ord_ins (String o int)
  Future<Map<String, ImagenInstalacion>> getImagenesPorTrabajo(
    String tabla,
    Object trabajoId,
  ) async {
    final id = trabajoId.toString();
    final url = '$_urlBase/download/$tabla/$id'; // 👈 corregido
    // ignore: avoid_print
    print('📦 Buscando imágenes: tabla=$tabla id=$id');
    // ignore: avoid_print
    print('🌐 GET $url');

    // intento + retry suave
    Response resp;
    try {
      resp = await get(url);
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 400));
      resp = await get(url);
    }

    var code = resp.statusCode ?? 0;
    if (code == 0) {
      await Future.delayed(const Duration(milliseconds: 600));
      resp = await get(url);
      code = resp.statusCode ?? 0;
    }

    // Si el backend devuelve 404 cuando no hay imágenes, devuelve {} sin error
    if (code == 404) {
      return <String, ImagenInstalacion>{};
    }

    if (code == 200 && resp.body != null) {
      final data = resp.body;
      final raw = (data['imagenes'] as Map<String, dynamic>?) ?? {};

      final result = <String, ImagenInstalacion>{};

      // Origin real desde API_URL para reemplazar 'localhost'
      final api = Uri.parse(
        Environment.API_URL,
      ); // ej: http://192.168.0.181:3000/api/
      final origin =
          '${api.scheme}://${api.host}${api.hasPort ? ':${api.port}' : ''}';

      raw.forEach((k, v) {
        final im = ImagenInstalacion.fromJson(v);

        // Corrige hostname si llega como localhost
        var fixedUrl = (im.url).trim();
        if (fixedUrl.startsWith('http://localhost') ||
            fixedUrl.startsWith('https://localhost') ||
            fixedUrl.startsWith('http://127.0.0.1') ||
            fixedUrl.startsWith('https://127.0.0.1')) {
          fixedUrl = fixedUrl.replaceFirst(
            RegExp(r'^https?://(localhost|127\.0\.0\.1)(:\d+)?'),
            origin,
          );
        }

        // Filtra inválidas (ruta 'null' o url vacía/terminada en /null)
        final ruta = im.ruta?.toLowerCase();
        final invalid =
            (ruta == null || ruta == 'null') ||
            fixedUrl.isEmpty ||
            fixedUrl.endsWith('/null') ||
            fixedUrl.contains('/undefined');

        if (!invalid) {
          result[k] = ImagenInstalacion(ruta: im.ruta, url: fixedUrl);
        }
      });

      // ignore: avoid_print
      print('🔍 Imágenes recibidas: ${result.length}');
      result.forEach((k, v) {
        // ignore: avoid_print
        print('  $k -> ${v.url}');
      });

      return result;
    }

    // ignore: avoid_print
    print('❌ Error getImagenesPorTrabajo [$code]');
    // ignore: avoid_print
    print('❌ BODY: ${resp.body}');
    throw Exception('Error al obtener imágenes');
  }

  /// Subida de imagen unitaria (compatible con Angular)
  Future<void> postImagenUnitaria({
    required String tabla,
    required String id,
    required String campo,
    required String directorio,
    required File file,
  }) async {
    await subirImagen(
      tabla: tabla,
      id: id,
      campo: campo,
      directorio: directorio,
      file: file,
    );
  }

  /// Subida multipart con Authorization
  Future<void> subirImagen({
    required String tabla,
    required String id,
    required String campo,
    required String directorio,
    required File file,
  }) async {
    final uri = Uri.parse('$_urlBase/upload');
    final token = GetStorage().read('token');

    final request =
        http.MultipartRequest('POST', uri)
          ..fields['tabla'] = tabla
          ..fields['id'] = id
          ..fields['campo'] = campo
          ..fields['directorio'] = directorio
          ..files.add(
            await http.MultipartFile.fromPath(
              'imagen',
              file.path,
              contentType: MediaType('image', 'jpeg'),
            ),
          );

    if (token != null && token.toString().isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final resp = await request.send();

    if (resp.statusCode != 200) {
      final body = await resp.stream.bytesToString();
      // ignore: avoid_print
      print('❌ Error al subir imagen: [${resp.statusCode}] $body');
      throw Exception('Error al subir imagen: $body');
    }

    // ignore: avoid_print
    print('✅ Imagen subida correctamente');
  }
}
