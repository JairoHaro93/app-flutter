class AsistenciaMarca {
  final int id;
  final String tipoMarcado;
  final DateTime fechaHora;
  final String? lectorCodigo;
  final bool matchOk;
  final String? origen;
  final String? observacion;

  AsistenciaMarca({
    required this.id,
    required this.tipoMarcado,
    required this.fechaHora,
    this.lectorCodigo,
    required this.matchOk,
    this.origen,
    this.observacion,
  });

  factory AsistenciaMarca.fromJson(Map<String, dynamic> json) {
    return AsistenciaMarca(
      id: (json['id'] ?? 0) as int,
      tipoMarcado: json['tipo_marcado']?.toString() ?? 'ENTRADA',
      fechaHora: DateTime.parse(json['fecha_hora'].toString()),
      lectorCodigo: json['lector_codigo']?.toString(),
      matchOk: (json['match_ok'] ?? 1) == 1,
      origen: json['origen']?.toString(),
      observacion: json['observacion']?.toString(),
    );
  }
}
