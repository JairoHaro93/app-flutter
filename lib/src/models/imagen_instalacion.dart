import 'package:redecom_app/src/environmets/environment.dart';

class ImagenInstalacion {
  final String ruta;
  final String url;

  ImagenInstalacion({required this.ruta, required this.url});

  factory ImagenInstalacion.fromJson(Map<String, dynamic> json) {
    String url = json['url'] ?? '';

    // Reemplaza 'localhost' por la IP del servidor si es necesario
    //url = url.replaceAll('localhost', '192.168.0.181');
    url = url.replaceAll('localhost', Environment.API_IP);
    return ImagenInstalacion(ruta: json['ruta'] ?? '', url: url);
  }
}
