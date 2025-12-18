class TurnoDiario {
  final int id;
  final DateTime fecha;
  final String? sucursal;
  final String horaEntradaProg; // "HH:mm:ss" o "HH:mm"
  final String horaSalidaProg;
  final DateTime? horaEntradaReal;
  final DateTime? horaSalidaReal;
  final String estadoAsistencia;
  final int? minTrabajados;
  final int? minAtraso;
  final int? minExtra;
  final String? observacion;

  TurnoDiario({
    required this.id,
    required this.fecha,
    this.sucursal,
    required this.horaEntradaProg,
    required this.horaSalidaProg,
    this.horaEntradaReal,
    this.horaSalidaReal,
    required this.estadoAsistencia,
    this.minTrabajados,
    this.minAtraso,
    this.minExtra,
    this.observacion,
  });

  factory TurnoDiario.fromJson(Map<String, dynamic> json) {
    DateTime? parseDT(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      if (s.isEmpty) return null;
      return DateTime.tryParse(s);
    }

    return TurnoDiario(
      id: (json['id'] ?? 0) as int,
      fecha: DateTime.parse(json['fecha'].toString()),
      sucursal: json['sucursal']?.toString(),
      horaEntradaProg: json['hora_entrada_prog']?.toString() ?? '',
      horaSalidaProg: json['hora_salida_prog']?.toString() ?? '',
      horaEntradaReal: parseDT(json['hora_entrada_real']),
      horaSalidaReal: parseDT(json['hora_salida_real']),
      estadoAsistencia: json['estado_asistencia']?.toString() ?? 'SIN_MARCA',
      minTrabajados: json['min_trabajados'] as int?,
      minAtraso: json['min_atraso'] as int?,
      minExtra: json['min_extra'] as int?,
      observacion: json['observacion']?.toString(),
    );
  }
}
