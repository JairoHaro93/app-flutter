class DiaHorarioSemana {
  final int? id;

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

  // NORMAL | DEVOLUCION | VACACIONES | PERMISO
  final String tipoDia;

  // NO | SOLICITUD | APROBADO | RECHAZADO
  final String estadoHoraAcumulada;
  final int? numHorasAcumuladas;

  // ==========================
  // ✅ JUSTIFICACIONES TURNO
  // ==========================
  // NO | PENDIENTE | APROBADA | RECHAZADA
  final String justAtrasoEstado;
  final String? justAtrasoMotivo;
  final int? justAtrasoMinutos;
  final int? justAtrasoJefeId;

  final String justSalidaEstado;
  final String? justSalidaMotivo;
  final int? justSalidaMinutos;
  final int? justSalidaJefeId;

  DiaHorarioSemana({
    required this.id,
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

    // justificaciones
    this.justAtrasoEstado = 'NO',
    this.justAtrasoMotivo,
    this.justAtrasoMinutos,
    this.justAtrasoJefeId,
    this.justSalidaEstado = 'NO',
    this.justSalidaMotivo,
    this.justSalidaMinutos,
    this.justSalidaJefeId,
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
      return s == '1' || s == 'true' || s == 'yes' || s == 'si';
    }

    String normUpper(dynamic v, {String def = 'NO'}) {
      final s = (v ?? def).toString().trim().toUpperCase();
      return s.isEmpty ? def : s;
    }

    final tipo = normUpper(json['tipo_dia'] ?? json['tipoDia'], def: 'NORMAL');
    final estadoHA = normUpper(json['estado_hora_acumulada'], def: 'NO');

    return DiaHorarioSemana(
      id: toInt(json['id']),

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

      tipoDia: tipo,
      estadoHoraAcumulada: estadoHA,
      numHorasAcumuladas: toInt(json['num_horas_acumuladas']),

      // ✅ justificaciones
      justAtrasoEstado: normUpper(json['just_atraso_estado'], def: 'NO'),
      justAtrasoMotivo: json['just_atraso_motivo']?.toString(),
      justAtrasoMinutos: toInt(json['just_atraso_minutos']),
      justAtrasoJefeId: toInt(json['just_atraso_jefe_id']),

      justSalidaEstado: normUpper(json['just_salida_estado'], def: 'NO'),
      justSalidaMotivo: json['just_salida_motivo']?.toString(),
      justSalidaMinutos: toInt(json['just_salida_minutos']),
      justSalidaJefeId: toInt(json['just_salida_jefe_id']),
    );
  }
}
