class Trabajo {
  final int id;
  final String tipo;
  final String subtipo;
  final String estado;
  final String ordenInstalacion;
  final String soporteId;
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
    id: json['id'] ?? 0,
    tipo: json['age_tipo'] ?? '',
    subtipo: json['age_subtipo'] ?? '',
    estado: json['age_estado'] ?? '',
    ordenInstalacion: json['age_ord_ins'] ?? '',
    soporteId: json['age_id_sop'] ?? '',
    horaInicio: json['age_hora_inicio'] ?? '',
    horaFin: json['age_hora_fin'] ?? '',
    fecha: json['age_fecha'] ?? '',
    vehiculo: json['age_vehiculo'] ?? '',
    tecnico: json['age_tecnico'] ?? '',
    observaciones: json['age_observaciones'] ?? '',
    coordenadas: json['age_coordenadas'] ?? '',
    telefono: json['age_telefono'] ?? '',
    solucion: json['age_solucion'],
  );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'age_tipo': tipo,
      'age_subtipo': subtipo,
      'age_estado': estado,
      'age_ord_ins': ordenInstalacion,
      'age_id_sop': soporteId,
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
