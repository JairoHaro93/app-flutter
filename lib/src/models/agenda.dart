class Agenda {
  final int id;
  final String tipo;
  final String estado;
  final int ordIns;
  final int idTipo;
  final int idSop;
  final String horaInicio;
  final String horaFin;
  final String fecha;
  final String vehiculo;
  final String tecnico;
  final String diagnostico;
  final String coordenadas;
  final String telefono;
  final String? solucion;
  final String subtipo;

  Agenda({
    required this.id,
    required this.tipo,
    required this.subtipo,
    required this.estado,
    required this.ordIns,
    required this.idSop,
    required this.idTipo,
    required this.horaInicio,
    required this.horaFin,
    required this.fecha,
    required this.vehiculo,
    required this.tecnico,
    required this.diagnostico,
    required this.coordenadas,
    required this.telefono,
    this.solucion,
  });

  factory Agenda.fromJson(Map<String, dynamic> json) => Agenda(
    id: json['id'] ?? json['age_id'] ?? 0,
    tipo: (json['age_tipo'] ?? json['tipo'] ?? '').toString(),
    subtipo: (json['age_subtipo'] ?? json['subtipo'] ?? '').toString(),
    estado: (json['age_estado'] ?? json['estado'] ?? '').toString(),
    ordIns:
        json['ord_ins'] is int
            ? json['ord_ins']
            : int.tryParse(json['ord_ins']?.toString() ?? '') ?? 0,
    idSop:
        json['age_id_sop'] is int
            ? json['age_id_sop']
            : int.tryParse(json['age_id_sop']?.toString() ?? '') ?? 0,
    idTipo:
        json['age_id_tipo'] is int
            ? json['age_id_tipo']
            : int.tryParse(json['age_id_tipo']?.toString() ?? '') ?? 0,
    horaInicio:
        (json['age_hora_inicio'] ?? json['horaInicio'] ?? '').toString(),
    horaFin: (json['age_hora_fin'] ?? json['horaFin'] ?? '').toString(),
    fecha: (json['age_fecha'] ?? json['fecha'] ?? '').toString(),
    vehiculo: (json['age_vehiculo'] ?? json['vehiculo'] ?? '').toString(),
    tecnico: (json['age_tecnico'] ?? json['tecnico'] ?? '').toString(),
    diagnostico:
        (json['age_diagnostico'] ?? json['diagnostico'] ?? '').toString(),
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
      'age_ord_ins': ordIns,
      'age_id_sop': idSop,
      'age_id_tipo': idTipo,
      'age_hora_inicio': horaInicio,
      'age_hora_fin': horaFin,
      'age_fecha': fecha,
      'age_vehiculo': vehiculo,
      'age_tecnico': tecnico,
      'age_diagnostico': diagnostico,
      'age_coordenadas': coordenadas,
      'age_telefono': telefono,
      'age_solucion': solucion,
    };
  }

  Agenda copyWith({String? estado, String? solucion}) {
    return Agenda(
      id: id,
      tipo: tipo,
      subtipo: subtipo,
      estado: estado ?? this.estado,
      ordIns: ordIns,
      idSop: idSop,
      idTipo: idTipo,
      horaInicio: horaInicio,
      horaFin: horaFin,
      fecha: fecha,
      vehiculo: vehiculo,
      tecnico: tecnico,
      diagnostico: diagnostico,
      coordenadas: coordenadas,
      telefono: telefono,
      solucion: solucion ?? this.solucion,
    );
  }
}

extension AgendaSolucionJson on Agenda {
  Map<String, dynamic> toSolucionJson() {
    return {'age_id': id, 'age_estado': estado, 'age_solucion': solucion};
  }
}
