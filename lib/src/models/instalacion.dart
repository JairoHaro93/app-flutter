// instalacion.dart
class Instalacion {
  final int id;
  final int ordIns;
  final String direccion;
  final String telefonos;
  final String coordenadas;
  final String plan;
  final String nombre;
  final String apellido;

  Instalacion({
    required this.id,
    required this.ordIns,
    required this.direccion,
    required this.telefonos,
    required this.coordenadas,
    required this.plan,
    required this.nombre,
    required this.apellido,
  });

  factory Instalacion.fromJson(Map<String, dynamic> json) {
    return Instalacion(
      id: json['id'] ?? 0,
      ordIns: json['ord_ins'] ?? 0,
      direccion: json['direccion'] ?? '',
      telefonos: json['telefonos'] ?? '',
      coordenadas: json['coordenadas'] ?? '',
      plan: json['plan'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ord_ins': ordIns,
      'direccion': direccion,
      'telefonos': telefonos,
      'coordenadas': coordenadas,
      'plan': plan,
      'nombre': nombre,
      'apellido': apellido,
    };
  }
}
