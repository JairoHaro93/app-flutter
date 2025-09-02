// lib/src/models/imagen_instalacion.dart
import 'package:redecom_app/src/environments/environment.dart';

class ImagenInstalacion {
  final String ruta;
  final String url;

  ImagenInstalacion({required this.ruta, required this.url});

  factory ImagenInstalacion.fromJson(Map<String, dynamic> json) {
    final rawRuta = (json['ruta'] ?? '').toString().trim();
    final rawUrl = (json['url'] ?? '').toString().trim();

    // Corrige URLs locales que vengan como localhost/127.0.0.1
    final fixed = Environment.fixLocalhost(rawUrl);

    return ImagenInstalacion(ruta: rawRuta, url: fixed);
  }

  Map<String, dynamic> toJson() => {'ruta': ruta, 'url': url};
}
