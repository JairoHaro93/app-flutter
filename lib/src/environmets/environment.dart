// lib/src/environmets/environment.dart
class Environment {
  // ===== Selección de entorno =====
  // Cambia a true para producción
  static const bool useProd = true;

  // IPs por entorno
  static const String API_IP_DEV = "192.168.0.181";
  static const String API_IP_PROD = "192.168.0.150";

  // Selección efectiva (const porque depende de otra const)
  static const String API_IP = useProd ? API_IP_PROD : API_IP_DEV;

  // ===== Base común =====
  static const String SCHEME = "http"; // cambia a "https" si corresponde
  static const String API_PORT = "3000";
  static const String API_PATH = "/api/"; // debe terminar en '/'

  // Origin: scheme://host:port
  static const String ORIGIN = "$SCHEME://$API_IP:$API_PORT";

  // URL base de la API: origin + path
  static const String API_URL = "$ORIGIN$API_PATH";

  // Socket.IO normalmente va al origin (sin /api)
  static const String API_WEBSOKETS = ORIGIN; // (mantenemos tu nombre)
  static const String API_WEBSOCKETS_ALIAS = ORIGIN; // alias si luego renombras

  // ===== Helpers =====

  /// Construye endpoints tipo: api('imagenes/upload') => http://IP:PORT/api/imagenes/upload
  static String api(String subpath) {
    final clean = subpath.startsWith('/') ? subpath.substring(1) : subpath;
    return "$API_URL$clean";
    // Nota: no puede ser const porque depende de un parámetro.
  }

  /// Reemplaza localhost/127.0.0.1 por ORIGIN (útil cuando el backend manda URLs locales)
  static String fixLocalhost(String url) {
    if (url.isEmpty) return url;
    final reg = RegExp(r'^https?://(localhost|127\.0\.0\.1)(:\d+)?');
    return url.replaceFirst(reg, ORIGIN);
  }
}
