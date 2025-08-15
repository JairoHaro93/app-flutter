class Trabajo {
  final int id;
  final String tipo;
  final String subtipo;
  final String estado;
  final int ordenInstalacion; // ord_ins
  final int soporteId; // age_id_sop
  final int ageIdTipo; // ← NUEVO: VIS/LOS id (age_id_tipo)
  final String horaInicio;
  final String horaFin;
  final String fecha;
  final String vehiculo;
  final String tecnico;
  final String observaciones;
  final String coordenadas;
  final String telefono;
  final String? solucion;

  Trabajo({
    required this.id,
    required this.tipo,
    required this.subtipo,
    required this.estado,
    required this.ordenInstalacion,
    required this.soporteId,
    required this.ageIdTipo, // ← NUEVO
    required this.horaInicio,
    required this.horaFin,
    required this.fecha,
    required this.vehiculo,
    required this.tecnico,
    required this.observaciones,
    required this.coordenadas,
    required this.telefono,
    this.solucion,
  });

  factory Trabajo.fromJson(Map<String, dynamic> json) => Trabajo(
    id: json['id'] ?? json['age_id'] ?? 0,
    tipo: (json['age_tipo'] ?? json['tipo'] ?? '').toString(),
    subtipo: (json['age_subtipo'] ?? json['subtipo'] ?? '').toString(),
    estado: (json['age_estado'] ?? json['estado'] ?? '').toString(),
    ordenInstalacion:
        json['ord_ins'] is int
            ? json['ord_ins']
            : int.tryParse(json['ord_ins']?.toString() ?? '') ?? 0,
    soporteId:
        json['age_id_sop'] is int
            ? json['age_id_sop']
            : int.tryParse(json['age_id_sop']?.toString() ?? '') ?? 0,
    ageIdTipo:
        json['age_id_tipo']
                is int // ← NUEVO
            ? json['age_id_tipo']
            : int.tryParse(json['age_id_tipo']?.toString() ?? '') ?? 0,
    horaInicio:
        (json['age_hora_inicio'] ?? json['horaInicio'] ?? '').toString(),
    horaFin: (json['age_hora_fin'] ?? json['horaFin'] ?? '').toString(),
    fecha: (json['age_fecha'] ?? json['fecha'] ?? '').toString(),
    vehiculo: (json['age_vehiculo'] ?? json['vehiculo'] ?? '').toString(),
    tecnico: (json['age_tecnico'] ?? json['tecnico'] ?? '').toString(),
    observaciones:
        (json['age_observaciones'] ?? json['observaciones'] ?? '').toString(),
    coordenadas:
        (json['age_coordenadas'] ?? json['coordenadas'] ?? '').toString(),
    telefono: (json['age_telefono'] ?? json['telefono'] ?? '').toString(),
    solucion: (json['age_solucion'] ?? json['solucion']),
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'age_tipo': tipo,
      'age_subtipo': subtipo,
      'age_estado': estado,
      'age_ord_ins': ordenInstalacion,
      'age_id_sop': soporteId,
      'age_id_tipo': ageIdTipo, // ← NUEVO
      'age_hora_inicio': horaInicio,
      'age_hora_fin': horaFin,
      'age_fecha': fecha,
      'age_vehiculo': vehiculo,
      'age_tecnico': tecnico,
      'age_observaciones': observaciones,
      'age_coordenadas': coordenadas,
      'age_telefono': telefono,
      'age_solucion': solucion,
    };
  }

  Trabajo copyWith({String? estado, String? solucion}) {
    return Trabajo(
      id: id,
      tipo: tipo,
      subtipo: subtipo,
      estado: estado ?? this.estado,
      ordenInstalacion: ordenInstalacion,
      soporteId: soporteId,
      ageIdTipo: ageIdTipo, // ← respeta el valor actual
      horaInicio: horaInicio,
      horaFin: horaFin,
      fecha: fecha,
      vehiculo: vehiculo,
      tecnico: tecnico,
      observaciones: observaciones,
      coordenadas: coordenadas,
      telefono: telefono,
      solucion: solucion ?? this.solucion,
    );
  }
}

extension TrabajoSolucionJson on Trabajo {
  Map<String, dynamic> toSolucionJson() {
    return {'age_id': id, 'age_estado': estado, 'age_solucion': solucion};
  }
}
