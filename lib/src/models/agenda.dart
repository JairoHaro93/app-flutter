// lib/src/models/agenda.dart
class Agenda {
  final int id;
  final int ordIns;
  final String tipo;
  final String estado;
  final int idTipo;
  final int idSop;
  final String horaInicio;
  final String horaFin;
  final String fecha; // ISO (ej: 2025-08-27T05:00:00.000Z)
  final String vehiculo;
  final String tecnico;
  final String diagnostico;
  final String coordenadas; // ej: "-0.93,-78.60"
  final String telefono;
  final String? solucion;

  Agenda({
    required this.id,
    required this.tipo,
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

  // -------- helpers de parseo simples --------
  static int _toInt(dynamic v, {int def = 0}) {
    if (v == null) return def;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? def;
  }

  static String _toStr(dynamic v) => v?.toString().trim() ?? '';

  /// Limpia coordenadas: quita espacios alrededor de coma (", ")
  static String _cleanCoords(String s) => s.replaceAll(RegExp(r'\s*,\s*'), ',');

  factory Agenda.fromJson(Map<String, dynamic> json) {
    return Agenda(
      id: _toInt(json['id'] ?? json['age_id']),
      tipo: _toStr(json['age_tipo']),
      estado: _toStr(json['age_estado']),
      ordIns: _toInt(json['ord_ins']),
      idTipo: _toInt(json['age_id_tipo']),
      idSop: _toInt(json['age_id_sop']),
      horaInicio: _toStr(json['age_hora_inicio']),
      horaFin: _toStr(json['age_hora_fin']),
      fecha: _toStr(json['age_fecha']),
      vehiculo: _toStr(json['age_vehiculo']),
      tecnico: _toStr(json['age_tecnico']),
      diagnostico: _toStr(json['age_diagnostico']),
      coordenadas: _cleanCoords(_toStr(json['age_coordenadas'])),
      telefono: _toStr(json['age_telefono']),
      solucion: json['age_solucion']?.toString(),
    );
  }

  /// Si necesitas enviar el objeto completo con prefijo `age_` (consistente)
  Map<String, dynamic> toJson() {
    return {
      'age_id': id,
      'age_tipo': tipo,
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

  /// Payload mínimo para PUT /agenda/edita-sol/:ageId
  Map<String, dynamic> toSolucionJson() {
    return {'age_id': id, 'age_estado': estado, 'age_solucion': solucion};
  }

  Agenda copyWith({String? estado, String? solucion}) {
    return Agenda(
      id: id,
      tipo: tipo,
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
