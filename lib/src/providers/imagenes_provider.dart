import 'package:get/get.dart';
import 'package:redecom_app/src/environmets/environment.dart';
import 'package:redecom_app/src/models/imagen_instalacion.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ImagenesProvider extends GetConnect {
  // Asegúrate de que Environment.API_URL termina en /api/
  final String urlBase = '${Environment.API_URL}imagenes';

  Future<Map<String, ImagenInstalacion>> getImagenesPorTrabajo(
    String tabla,
    String trabajoId,
  ) async {
    final url = '$urlBase/download/$tabla/$trabajoId';

    print('📦 Buscando imágenes con tabla=$tabla y id=$trabajoId');
    print('🌐 Petición a: $url');

    final response = await get('$url');

    if (response.statusCode == 200 && response.body != null) {
      final data = response.body;

      final imagenes = <String, ImagenInstalacion>{};

      if (data['imagenes'] != null) {
        (data['imagenes'] as Map<String, dynamic>).forEach((key, value) {
          imagenes[key] = ImagenInstalacion.fromJson(value);
        });
      }

      print('🔍 Imágenes recibidas:');
      imagenes.forEach((k, v) => print('🖼️ $k -> ${v.url}'));

      return imagenes;
    } else {
      print('❌ Error en getImagenesPorTrabajo: ${response.statusCode}');
      print('❌ BODY: ${response.body}');
      throw Exception('Error al obtener imágenes');
    }
  }

  Future<void> subirImagen({
    required String tabla,
    required String id,
    required String campo,
    required String directorio,
    required File file,
  }) async {
    final uri = Uri.parse('$urlBase/upload');

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
              contentType: MediaType(
                'image',
                'jpeg',
              ), // o usa image/png si es PNG
            ),
          );

    final response = await request.send();

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      print('❌ Error al subir imagen: $body');
      throw Exception('Error al subir imagen: $body');
    }

    print('✅ Imagen subida correctamente');
  }
}
