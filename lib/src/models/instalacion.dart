// lib/src/models/instalacion.dart  (o tu ruta actual)
class Instalacion {
  final int id;
  final String ordIns; // viene como string en el JSON
  final String? instTelefonos;
  final String? instCoordenadas; // ej: "-0.93, -78.60"
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

  Instalacion({
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

  factory Instalacion.fromJson(Map<String, dynamic> json) {
    String? _s(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      if (s.isEmpty || s.toLowerCase() == 'null') return null;
      return s;
    }

    String? _coords(dynamic v) {
      final s = _s(v);
      if (s == null) return null;
      // quita espacios alrededor de coma y espacios redundantes
      return s.replaceAll(RegExp(r'\s*,\s*'), ',');
    }

    return Instalacion(
      id:
          json['id'] is int
              ? json['id'] as int
              : int.tryParse('${json['id'] ?? 0}') ?? 0,
      ordIns: (json['ord_ins'] ?? '').toString().trim(),
      instTelefonos: _s(json['inst_telefonos']),
      instCoordenadas: _coords(json['inst_coordenadas']),
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

  /// ¿Hay al menos una imagen válida?
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

  /// Útil si quieres iterar/ordenar imágenes por clave
  Map<String, String> get imagenes {
    final m = <String, String>{};
    void addIf(String key, String? v) {
      if (v != null && v.trim().isNotEmpty) m[key] = v.trim();
    }

    addIf('fachada', fachada);
    addIf('router', router);
    addIf('ont', ont);
    addIf('potencia', potencia);
    addIf('speedtest', speedtest);
    addIf('cable_1', cable1);
    addIf('cable_2', cable2);
    addIf('equipo_1', equipo1);
    addIf('equipo_2', equipo2);
    addIf('equipo_3', equipo3);
    return m;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'ord_ins': ordIns,
    'inst_telefonos': instTelefonos,
    'inst_coordenadas': instCoordenadas,
    'inst_observacion': instObservacion,
    'fachada': fachada,
    'router': router,
    'ont': ont,
    'potencia': potencia,
    'speedtest': speedtest,
    'cable_1': cable1,
    'cable_2': cable2,
    'equipo_1': equipo1,
    'equipo_2': equipo2,
    'equipo_3': equipo3,
  };

  Instalacion copyWith({
    String? instTelefonos,
    String? instCoordenadas,
    String? instObservacion,
    String? fachada,
    String? router,
    String? ont,
    String? potencia,
    String? speedtest,
    String? cable1,
    String? cable2,
    String? equipo1,
    String? equipo2,
    String? equipo3,
  }) {
    return Instalacion(
      id: id,
      ordIns: ordIns,
      instTelefonos: instTelefonos ?? this.instTelefonos,
      instCoordenadas: instCoordenadas ?? this.instCoordenadas,
      instObservacion: instObservacion ?? this.instObservacion,
      fachada: fachada ?? this.fachada,
      router: router ?? this.router,
      ont: ont ?? this.ont,
      potencia: potencia ?? this.potencia,
      speedtest: speedtest ?? this.speedtest,
      cable1: cable1 ?? this.cable1,
      cable2: cable2 ?? this.cable2,
      equipo1: equipo1 ?? this.equipo1,
      equipo2: equipo2 ?? this.equipo2,
      equipo3: equipo3 ?? this.equipo3,
    );
  }
}
