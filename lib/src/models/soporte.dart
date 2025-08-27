class Soporte {
  final int id;
  final int ordIns;
  final int opcion;
  final String telefono;
  final int registradoPorId;
  final String comentarioCliente;
  final String fechaRegistro;
  final String estado;
  final String fechaAcepta;
  final String solucionDetalle;
  final String registradoPorNombre;

  Soporte({
    required this.id,
    required this.ordIns,
    required this.opcion,
    required this.telefono,
    required this.registradoPorId,
    required this.comentarioCliente,
    required this.registradoPorNombre,
    required this.fechaRegistro,
    required this.estado,
    required this.fechaAcepta,
    required this.solucionDetalle,
  });

  factory Soporte.fromJson(Map<String, dynamic> json) {
    return Soporte(
      id: json['id'] ?? 0,
      ordIns: json['ord_ins'] ?? 0,
      opcion: json['reg_sop_opc'] ?? 0,
      telefono: json['reg_sop_tel'] ?? '',
      registradoPorId: json['reg_sop_registrado_por_id'] ?? 0,
      comentarioCliente: json['reg_sop_coment_cliente'] ?? '',
      registradoPorNombre: json['reg_sop_registrado_por_nombre'] ?? '',
      fechaRegistro: json['reg_sop_fecha'] ?? '',
      estado: json['reg_sop_estado'] ?? '',
      fechaAcepta: json['reg_sop_fecha_acepta'] ?? '',
      solucionDetalle: json['reg_sop_sol_det'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ord_ins': ordIns,
      'reg_sop_opc': opcion,
      'reg_sop_tel': telefono,
      'reg_sop_registrado_por_id': registradoPorId,
      'reg_sop_coment_cliente': comentarioCliente,
      'reg_sop_registrado_por_nombre': registradoPorNombre,
      'reg_sop_fecha': fechaRegistro,
      'reg_sop_estado': estado,
      'reg_sop_fecha_acepta': fechaAcepta,
      'reg_sop_sol_det': solucionDetalle,
    };
  }
}
