// lib/src/models/infraestructura.dart
class Infraestructura {
  final int agendaId;
  final String ageTipo;
  final String ageEstado;
  final String ordIns;
  final int ageIdTipo;
  final int? ageIdSop;
  final String? ageHoraInicio;
  final String? ageHoraFin;
  final DateTime? ageFecha;
  final String? ageVehiculo;
  final int? ageTecnico;
  final String? ageDiagnostico;
  final String? ageCoordenadas;
  final String? ageTelefono;
  final String? ageSolucion;

  final int infraId;
  final String infraNombre;
  final String? infraCoordenadas;
  final String? infraObservacion;
  final String? infraImgRef1;
  final String? infraImgRef2;
  final DateTime? infraCreatedAt;
  final DateTime? infraUpdatedAt;

  final String? tecnicoNombre;

  Infraestructura({
    required this.agendaId,
    required this.ageTipo,
    required this.ageEstado,
    required this.ordIns,
    required this.ageIdTipo,
    this.ageIdSop,
    this.ageHoraInicio,
    this.ageHoraFin,
    this.ageFecha,
    this.ageVehiculo,
    this.ageTecnico,
    this.ageDiagnostico,
    this.ageCoordenadas,
    this.ageTelefono,
    this.ageSolucion,
    required this.infraId,
    required this.infraNombre,
    this.infraCoordenadas,
    this.infraObservacion,
    this.infraImgRef1,
    this.infraImgRef2,
    this.infraCreatedAt,
    this.infraUpdatedAt,
    this.tecnicoNombre,
  });

  factory Infraestructura.fromJson(Map<String, dynamic> json) {
    int? _int(dynamic v) => v == null ? null : int.tryParse('$v');
    int _intReq(dynamic v) => int.tryParse('$v') ?? 0;
    String? _s(dynamic v) {
      if (v == null) return null;
      final s = v.toString().trim();
      return s.isEmpty || s.toLowerCase() == 'null' ? null : s;
    }

    DateTime? _dt(dynamic v) {
      final s = _s(v);
      if (s == null) return null;
      try {
        return DateTime.parse(s);
      } catch (_) {
        return null;
      }
    }

    return Infraestructura(
      agendaId: _intReq(json['agenda_id']),
      ageTipo: _s(json['age_tipo']) ?? '',
      ageEstado: _s(json['age_estado']) ?? '',
      ordIns: _s(json['ord_ins']) ?? '',
      ageIdTipo: _intReq(json['age_id_tipo']),
      ageIdSop: _int(json['age_id_sop']),
      ageHoraInicio: _s(json['age_hora_inicio']),
      ageHoraFin: _s(json['age_hora_fin']),
      ageFecha: _dt(json['age_fecha']),
      ageVehiculo: _s(json['age_vehiculo']),
      ageTecnico: _int(json['age_tecnico']),
      ageDiagnostico: _s(json['age_diagnostico']),
      ageCoordenadas: _s(json['age_coordenadas']),
      ageTelefono: _s(json['age_telefono']),
      ageSolucion: _s(json['age_solucion']),
      infraId: _intReq(json['infra_id']),
      infraNombre: _s(json['infra_nombre']) ?? '',
      infraCoordenadas: _s(json['infra_coordenadas']),
      infraObservacion: _s(json['infra_observacion']),
      infraImgRef1: _s(json['infra_img_ref1']),
      infraImgRef2: _s(json['infra_img_ref2']),
      infraCreatedAt: _dt(json['infra_created_at']),
      infraUpdatedAt: _dt(json['infra_updated_at']),
      tecnicoNombre: _s(json['tecnico_nombre']),
    );
  }
}
