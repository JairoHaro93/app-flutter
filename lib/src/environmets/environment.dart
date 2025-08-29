// lib/src/environmets/environment.dart

class Environment {
  /// false = Desarrollo | true = Producción
  static bool useProd = false;

  // ---- Host/IP por entorno ----
  static const String API_IP_DEV = '192.168.0.181';
  static const String API_IP_PROD = '192.168.0.150';

  // ---- Puertos por entorno (prod sin puerto, como tu ejemplo) ----
  static const String API_PORT_DEV = '3000';
  static const String API_PORT_PROD = ''; // vacío => no se agrega :puerto

  // ---- Protocolo y path base ----
  static const String SCHEME = 'http';
  static const String API_PATH = '/api/'; // debe terminar en '/'

  // ---- IP activa según entorno ----
  static String get API_IP => useProd ? API_IP_PROD : API_IP_DEV;

  // ---- Selección de puerto según entorno ----
  static String get _port => useProd ? API_PORT_PROD : API_PORT_DEV;

  /// ORIGIN = scheme://host(:port?)
  static String get ORIGIN {
    final portPart = _port.isEmpty ? '' : ':$_port';
    return '$SCHEME://$API_IP$portPart';
  }

  /// Igual que tus constantes:
  /// DEV  -> http://192.168.0.181:3000/api/
  /// PROD -> http://192.168.0.150/api/
  static String get API_URL => '$ORIGIN$API_PATH';

  /// Socket.IO (sin /api)
  /// DEV  -> http://192.168.0.181:3000
  /// PROD -> http://192.168.0.150
  static String get API_WEBSOKETS => ORIGIN;

  // ---- Helpers ----
  static String api(String subpath) {
    final clean = subpath.startsWith('/') ? subpath.substring(1) : subpath;
    return '$API_URL$clean';
  }

  static String fixLocalhost(String url) {
    if (url.isEmpty) return url;
    final reg = RegExp(r'^https?://(localhost|127\.0\.0\.1)(:\d+)?');
    return url.replaceFirst(reg, ORIGIN);
  }
}


/*
class Environment {
  //USO EN DESARROLLO
  /*
  static const String API_URL = "http://192.168.0.181:3000/api/";
  static const String API_IP = "192.168.0.181";
  static const String API_WEBSOKETS = 'http://192.168.0.181:3000';
*/

  //   USO EN SERVIDOR
  static const String API_URL = "http://192.168.0.150/api/";
  static const String API_IP = "192.168.0.150";
  static const String API_WEBSOKETS = 'http://192.168.0.150';
}
*/