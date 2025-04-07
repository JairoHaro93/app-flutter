class User {
  String? id;
  String? username;
  String? name;
  List<String>? roles;
  String? sessionToken;

  User({this.id, this.username, this.name, this.roles, this.sessionToken});

  // Constructor desde JSON (decodificado del token o desde local storage)
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["usuario_id"],
    username: json["usuario_usuario"],
    name: json["usuario_nombre"],
    roles: List<String>.from(json["usuario_rol"] ?? []),
    sessionToken: json["session_token"], // Puede venir desde storage
  );

  // Convierte a JSON para guardar en GetStorage
  Map<String, dynamic> toJson() => {
    "usuario_id": id,
    "usuario_usuario": username,
    "usuario_nombre": name,
    "usuario_rol": roles,
    "session_token": sessionToken,
  };
}
