import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:redecom_app/src/environments/environment.dart';
import 'package:redecom_app/src/models/imagen_instalacion.dart';

class ImagenesProvider extends GetConnect {
  ImagenesProvider() {
    httpClient.baseUrl = Environment.API_URL; // http://IP:PORT/api/
    httpClient.timeout = const Duration(seconds: 20);

    httpClient.addRequestModifier<dynamic>((request) {
      final token = GetStorage().read('token')?.toString();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (request.method != 'get') {
        request.headers['Content-Type'] = 'application/json';
        request.headers['Accept'] = 'application/json';
      }
      return request;
    });
  }

  Future<Map<String, ImagenInstalacion>> getImagenesPorAgenda(
    String tabla,
    Object trabajoId,
  ) async {
    final id = trabajoId.toString();

    Response resp;
    try {
      resp = await get('imagenes/download/$tabla/$id');
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 400));
      resp = await get('imagenes/download/$tabla/$id');
    }

    final code = resp.statusCode ?? 0;

    if (code == 404) return <String, ImagenInstalacion>{};

    if (code >= 200 && code < 300 && resp.body is Map) {
      final data = resp.body as Map;
      final raw = (data['imagenes'] as Map?) ?? const {};
      final out = <String, ImagenInstalacion>{};

      raw.forEach((k, v) {
        if (v is Map) {
          final im = ImagenInstalacion.fromJson(Map<String, dynamic>.from(v));
          final ruta = im.ruta.toLowerCase();
          final url = im.url.trim();
          final invalid =
              ruta.isEmpty ||
              ruta == 'null' ||
              url.isEmpty ||
              url.endsWith('/null') ||
              url.contains('/undefined');
          if (!invalid) out[k.toString()] = im;
        }
      });

      return out;
    }

    throw Exception(
      '[${resp.statusCode}] ${_extractError(resp.body) ?? 'Error al obtener imágenes'}',
    );
  }

  Future<void> postImagenUnitaria({
    required String tabla,
    required String id,
    required String campo,
    required String directorio,
    required File file,
  }) async {
    if (!await file.exists()) {
      throw Exception('El archivo no existe: ${file.path}');
    }

    final uri = Uri.parse('${Environment.API_URL}imagenes/upload');
    final token = GetStorage().read('token')?.toString();

    final req =
        http.MultipartRequest('POST', uri)
          ..fields['tabla'] = tabla
          ..fields['id'] = id
          ..fields['campo'] = campo
          ..fields['directorio'] = directorio
          ..files.add(
            await http.MultipartFile.fromPath(
              'imagen',
              file.path,
              contentType: _contentTypeFor(file.path),
            ),
          );

    if (token != null && token.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $token';
    }

    try {
      final resp = await req.send();

      // Acepta cualquier 2xx como éxito
      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        final body = await resp.stream.bytesToString();
        throw Exception(
          'Error al subir imagen: [${resp.statusCode}] ${body.isEmpty ? '(sin detalle)' : body}',
        );
      }
    } catch (e) {
      throw Exception('No se pudo subir la imagen: $e');
    }
  }

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

  MediaType _contentTypeFor(String path) {
    final ext = path.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}
