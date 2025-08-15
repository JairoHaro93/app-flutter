class Soporte {
  final int id;
  final int ordenInstalacion;
  final int opcion;
  final String telefono;
  final int registradoPorId;
  final String registradoPorNombre;
  final String observaciones;
  final String fechaRegistro;
  final String estado;
  final String clienteNombre;
  final String fechaAcepta;
  final String solucionDetalle;

  Soporte({
    required this.id,
    required this.ordenInstalacion,
    required this.opcion,
    required this.telefono,
    required this.registradoPorId,
    required this.registradoPorNombre,
    required this.observaciones,
    required this.fechaRegistro,
    required this.estado,
    required this.clienteNombre,
    required this.fechaAcepta,
    required this.solucionDetalle,
  });

  factory Soporte.fromJson(Map<String, dynamic> json) {
    return Soporte(
      id: json['id'] ?? 0,
      ordenInstalacion: json['ord_ins'] ?? 0,
      opcion: json['reg_sop_opc'] ?? 0,
      telefono: json['reg_sop_tel'] ?? '',
      registradoPorId: json['reg_sop_registrado_por_id'] ?? 0,
      registradoPorNombre: json['reg_sop_registrado_por_nombre'] ?? '',
      observaciones: json['reg_sop_observaciones'] ?? '',
      fechaRegistro: json['reg_sop_fecha'] ?? '',
      estado: json['reg_sop_estado'] ?? '',
      clienteNombre: json['reg_sop_nombre'] ?? '',
      fechaAcepta: json['reg_sop_fecha_acepta'] ?? '',
      solucionDetalle: json['reg_sop_sol_det'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ord_ins': ordenInstalacion,
      'reg_sop_opc': opcion,
      'reg_sop_tel': telefono,
      'reg_sop_registrado_por_id': registradoPorId,
      'reg_sop_registrado_por_nombre': registradoPorNombre,
      'reg_sop_observaciones': observaciones,
      'reg_sop_fecha': fechaRegistro,
      'reg_sop_estado': estado,
      'reg_sop_nombre': clienteNombre,
      'reg_sop_fecha_acepta': fechaAcepta,
      'reg_sop_sol_det': solucionDetalle,
    };
  }
}
