class DiaHorarioSemana {
  final DateTime fecha;
  final bool tieneTurno;

  final String estadoAsistencia;

  final String? horaEntradaProg;
  final String? horaSalidaProg;

  final DateTime? horaEntradaReal;
  final DateTime? horaSalidaReal;

  final int? minTrabajados;
  final int? minAtraso;
  final int? minExtra;

  final String? observacion;
  final String? sucursal;

  // ✅ NUEVO: tipo de día
  // NORMAL | DEVOLUCION | VACACIONES | PERMISO
  final String tipoDia;

  // ✅ HORA ACUMULADA
  // NO | SOLICITUD | APROBADO | RECHAZADO
  final String estadoHoraAcumulada;
  final int? numHorasAcumuladas;

  DiaHorarioSemana({
    required this.fecha,
    required this.tieneTurno,
    required this.estadoAsistencia,
    this.horaEntradaProg,
    this.horaSalidaProg,
    this.horaEntradaReal,
    this.horaSalidaReal,
    this.minTrabajados,
    this.minAtraso,
    this.minExtra,
    this.observacion,
    this.sucursal,
    this.tipoDia = 'NORMAL',
    this.estadoHoraAcumulada = 'NO',
    this.numHorasAcumuladas,
  });

  factory DiaHorarioSemana.fromJson(Map<String, dynamic> json) {
    DateTime parseFechaLocal(String ymd) {
      final p = ymd.split('-');
      return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
    }

    DateTime? parseDT(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      // backend suele mandar ISO con Z: "2025-12-17T13:02:27.000Z"
      return DateTime.tryParse(s)?.toLocal();
    }

    int? toInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      final s = v.toString().trim();
      if (s.isEmpty) return null;
      return int.tryParse(s);
    }

    bool toBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      final s = v.toString().trim().toLowerCase();
      return s == '1' || s == 'true' || s == 'yes';
    }

    final tipo =
        (json['tipo_dia'] ?? json['tipoDia'] ?? 'NORMAL')
            .toString()
            .trim()
            .toUpperCase();

    final estadoHA =
        (json['estado_hora_acumulada'] ?? 'NO').toString().trim().toUpperCase();

    return DiaHorarioSemana(
      fecha: parseFechaLocal(json['fecha'].toString()),
      tieneTurno: toBool(json['tiene_turno']),
      estadoAsistencia: (json['estado_asistencia'] ?? 'SIN_TURNO').toString(),

      horaEntradaProg: json['hora_entrada_prog']?.toString(),
      horaSalidaProg: json['hora_salida_prog']?.toString(),

      horaEntradaReal: parseDT(json['hora_entrada_real']),
      horaSalidaReal: parseDT(json['hora_salida_real']),

      minTrabajados: toInt(json['min_trabajados']),
      minAtraso: toInt(json['min_atraso']),
      minExtra: toInt(json['min_extra']),

      observacion: json['observacion']?.toString(),
      sucursal: json['sucursal']?.toString(),

      // ✅ NUEVO
      tipoDia: tipo.isEmpty ? 'NORMAL' : tipo,

      // ✅ HORA ACUMULADA (normalizado)
      estadoHoraAcumulada: estadoHA.isEmpty ? 'NO' : estadoHA,
      numHorasAcumuladas: toInt(json['num_horas_acumuladas']),
    );
  }
}
