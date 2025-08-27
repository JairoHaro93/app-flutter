// lib/src/models/instalacion_mysql.dart
class InstalacionMysql {
  final int id;
  final String ordIns; // viene como string en el JSON
  final String? instTelefonos;
  final String? instCoordenadas;
  final String? instObservacion;

  // Campos de imágenes (rutas relativas tipo '103521\\img_....jpg' o "null")
  final String? fachada;
  final String? router;
  final String? ont;
  final String? potencia;
  final String? speedtest;
  final String? cable1;
  final String? cable2;
  final String? equipo1;
  final String? equipo2;
  final String? equipo3;

  InstalacionMysql({
    required this.id,
    required this.ordIns,
    this.instTelefonos,
    this.instCoordenadas,
    this.instObservacion,
    this.fachada,
    this.router,
    this.ont,
    this.potencia,
    this.speedtest,
    this.cable1,
    this.cable2,
    this.equipo1,
    this.equipo2,
    this.equipo3,
  });

  factory InstalacionMysql.fromJson(Map<String, dynamic> json) {
    String? _s(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      if (s.trim().isEmpty || s.toLowerCase() == 'null') return null;
      return s;
    }

    DateTime? _dt(dynamic v) {
      if (v == null) return null;
      try {
        return DateTime.parse(v.toString());
      } catch (_) {
        return null;
      }
    }

    return InstalacionMysql(
      id:
          json['id'] is int
              ? json['id']
              : int.tryParse('${json['id'] ?? 0}') ?? 0,
      ordIns: (json['ord_ins'] ?? '').toString(),
      instTelefonos: _s(json['inst_telefonos']),
      instCoordenadas: _s(json['inst_coordenadas']),
      instObservacion: _s(json['inst_observacion']),
      fachada: _s(json['fachada']),
      router: _s(json['router']),
      ont: _s(json['ont']),
      potencia: _s(json['potencia']),
      speedtest: _s(json['speedtest']),
      cable1: _s(json['cable_1']),
      cable2: _s(json['cable_2']),
      equipo1: _s(json['equipo_1']),
      equipo2: _s(json['equipo_2']),
      equipo3: _s(json['equipo_3']),
    );
  }

  /// Helper por si quieres saber si hay alguna imagen válida
  bool get tieneAlMenosUnaImagen =>
      fachada != null ||
      router != null ||
      ont != null ||
      potencia != null ||
      speedtest != null ||
      cable1 != null ||
      cable2 != null ||
      equipo1 != null ||
      equipo2 != null ||
      equipo3 != null;
}
