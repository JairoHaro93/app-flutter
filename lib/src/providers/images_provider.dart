import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:redecom_app/src/environments/environment.dart';
import 'package:redecom_app/src/models/imagen_instalacion.dart';

class ImagesProvider extends GetConnect {
  ImagesProvider() {
    httpClient.baseUrl = Environment.API_URL; // ej: http://IP:PORT/api/
    httpClient.timeout = const Duration(seconds: 20);

    httpClient.addRequestModifier<dynamic>((request) {
      final token = GetStorage().read('token')?.toString();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      // NO forzamos Content-Type aquí (GetConnect lo setea según tipo).
      return request;
    });
  }

  // ---------------------------------------------------------------------------
  // LISTADOS (backend nuevo) → mapa legacy {clave -> ImagenInstalacion}
  // ---------------------------------------------------------------------------

  /// GET /api/images/list/:module/:entityId  →  { clave -> ImagenInstalacion }
  Future<Map<String, ImagenInstalacion>> listAsLegacyMap({
    required String module,
    required String entityId,
  }) async {
    Response resp;
    try {
      resp = await get('images/list/$module/$entityId');
    } catch (_) {
      await Future.delayed(const Duration(milliseconds: 300));
      resp = await get('images/list/$module/$entityId');
    }

    final code = resp.statusCode ?? 0;
    if (code == 404) return <String, ImagenInstalacion>{};
    if (code < 200 || code >= 300) {
      throw Exception(
        '[${resp.statusCode}] ${_extractError(resp.body) ?? 'Error listando imágenes'}',
      );
    }

    final body = resp.body;
    if (body is! Map) return <String, ImagenInstalacion>{};
    final List items = (body['imagenes'] as List?) ?? const [];

    final out = <String, ImagenInstalacion>{};
    for (final row in items) {
      if (row is! Map) continue;
      final tag = (row['tag'] ?? '').toString().trim();
      final pos = int.tryParse('${row['position'] ?? 0}') ?? 0;
      final rel = (row['ruta_relativa'] ?? '').toString().trim();
      final url = (row['url'] ?? '').toString().trim();

      final bad =
          rel.isEmpty ||
          url.isEmpty ||
          url.endsWith('/null') ||
          url.contains('/undefined');
      if (bad) continue;

      // Clave legacy: si visitas y tag = 'img' ⇒ img_N; si no, tag o tag_pos>0
      final key = _legacyKey(module: module, tag: tag, position: pos);

      out[key] = ImagenInstalacion(ruta: rel, url: url);
    }
    return out;
  }

  /// Azúcar: instalaciones
  Future<Map<String, ImagenInstalacion>> listInstalacionAsLegacyMap(
    String ordIns,
  ) {
    return listAsLegacyMap(module: 'instalaciones', entityId: ordIns);
  }

  /// Azúcar: visitas
  Future<Map<String, ImagenInstalacion>> listVisitaAsLegacyMap(String visId) {
    return listAsLegacyMap(module: 'visitas', entityId: visId);
  }

  // ---------------------------------------------------------------------------
  // UPLOAD (backend nuevo)
  // ---------------------------------------------------------------------------

  /// POST /api/images/upload
  /// Campos:
  /// - module (instalaciones|visitas|infraestructura|…)
  /// - entity_id
  /// - tag (p.ej. 'router', 'img', 'sol', …)
  /// - position (int; para visitas: img_1 ⇒ tag=img, position=1)
  /// - image (archivo)
  Future<void> upload({
    required String module,
    required String entityId,
    required String tag,
    int position = 0,
    required File file,
  }) async {
    if (!await file.exists()) {
      throw Exception('El archivo no existe: ${file.path}');
    }

    final uri = Uri.parse('${Environment.API_URL}images/upload');
    final token = GetStorage().read('token')?.toString();

    final req =
        http.MultipartRequest('POST', uri)
          ..fields['module'] = module
          ..fields['entity_id'] = entityId
          ..fields['tag'] = tag
          ..fields['position'] = position.toString()
          ..files.add(
            await http.MultipartFile.fromPath(
              'image', // <-- campo requerido por el backend nuevo
              file.path,
              contentType: _contentTypeFor(file.path),
            ),
          );

    if (token != null && token.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $token';
    }
    req.headers['Accept'] = 'application/json';

    final resp = await req.send();
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      final body = await resp.stream.bytesToString();
      throw Exception(
        'Error al subir imagen: [${resp.statusCode}] ${body.isEmpty ? '(sin detalle)' : body}',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // COMPATIBILIDAD (firmas viejas) para migración sin romper UI
  // ---------------------------------------------------------------------------

  /// Equivalente legacy de lectura:
  /// getImagenesPorAgenda('neg_t_instalaciones'|'neg_t_vis', id)
  Future<Map<String, ImagenInstalacion>> getLegacyMap(String tabla, String id) {
    final module = _moduleFromTabla(tabla);
    return listAsLegacyMap(module: module, entityId: id);
  }

  /// Equivalente legacy de subida:
  /// postImagenUnitaria(tabla,id,campo,directorio,file)
  /// - instalaciones: tag = campo, position = 0
  /// - visitas: campo "img_1" ⇒ tag = "img", position = 1
  /// (directorio ya NO se usa en el backend nuevo; se ignora)
  Future<void> uploadLegacy({
    required String tabla,
    required String id,
    required String campo,
    required String directorio, // ignorado en backend nuevo
    required File file,
  }) async {
    final module = _moduleFromTabla(tabla);
    final tp = _parseTagAndPosition(campo);
    await upload(
      module: module,
      entityId: id,
      tag: tp.$1,
      position: tp.$2,
      file: file,
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  String _moduleFromTabla(String tabla) {
    final t = tabla.trim().toLowerCase();
    if (t == 'neg_t_instalaciones' || t == 'instalaciones')
      return 'instalaciones';
    if (t == 'neg_t_vis' || t == 'vis' || t == 'visitas') return 'visitas';
    if (t == 'infraestructura') return 'infraestructura';
    // fallback
    return t;
  }

  /// Devuelve (tag, position) a partir de "campo" legacy
  /// - "img_3" → ("img", 3)
  /// - "router" → ("router", 0)
  (String, int) _parseTagAndPosition(String campo) {
    final c = campo.trim().toLowerCase();
    final m = RegExp(r'^img_(\d+)$').firstMatch(c);
    if (m != null) {
      final p = int.tryParse(m.group(1)!) ?? 0;
      return ('img', p);
    }
    // también soporta "sol_2" por si más adelante lo reutilizas
    final m2 = RegExp(r'^([a-z0-9]+)_(\d+)$').firstMatch(c);
    if (m2 != null) {
      return (m2.group(1)!, int.tryParse(m2.group(2)!) ?? 0);
    }
    return (c, 0);
  }

  /// Construye la clave legacy para la UI
  String _legacyKey({
    required String module,
    required String tag,
    required int position,
  }) {
    final t = (tag.isEmpty ? 'otros' : tag).trim();
    if (module == 'visitas') {
      return (t == 'img' && position >= 0) ? 'img_$position' : t;
    }
    // instalaciones / otros módulos: usa tag o tag_position si >0
    return (position > 0) ? '${t}_$position' : t;
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
