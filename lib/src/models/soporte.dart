class Soporte {
  final int id;
  final int ordIns;
  final int opcion; // reg_sop_opc
  final String telefono; // reg_sop_tel
  final int registradoPorId; // reg_sop_registrado_por_id
  final String comentarioCliente; // reg_sop_coment_cliente
  final String registradoPorNombre; // reg_sop_registrado_por_nombre
  final String fechaRegistro; // reg_sop_fecha (string ISO u otro)
  final String estado; // reg_sop_estado
  final String fechaAcepta; // reg_sop_fecha_acepta
  final String solucionDetalle; // reg_sop_sol_det

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

  // helpers de parseo seguros (como ya usas en Agenda)
  static int _toInt(dynamic v, {int def = 0}) {
    if (v == null) return def;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? def;
  }

  static String _toStr(dynamic v) => v?.toString() ?? '';

  factory Soporte.fromJson(Map<String, dynamic> json) => Soporte(
    id: _toInt(json['id']),
    ordIns: _toInt(json['ord_ins']),
    opcion: _toInt(json['reg_sop_opc']),
    telefono: _toStr(json['reg_sop_tel']),
    registradoPorId: _toInt(json['reg_sop_registrado_por_id']),
    comentarioCliente: _toStr(json['reg_sop_coment_cliente']),
    registradoPorNombre: _toStr(json['reg_sop_registrado_por_nombre']),
    fechaRegistro: _toStr(json['reg_sop_fecha']),
    estado: _toStr(json['reg_sop_estado']),
    fechaAcepta: _toStr(json['reg_sop_fecha_acepta']),
    solucionDetalle: _toStr(json['reg_sop_sol_det']),
  );

  Map<String, dynamic> toJson() => {
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
