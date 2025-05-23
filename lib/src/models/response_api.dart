import 'dart:convert';

ResponseApi responseApiFromJson(String str) =>
    ResponseApi.fromJson(json.decode(str));

String responseApiToJson(ResponseApi data) => json.encode(data.toJson());

class ResponseApi {
  String? message;
  dynamic token;
  bool? success; // ✅ Opción extra para indicar si la operación fue exitosa

  ResponseApi({this.message, this.token, this.success});

  factory ResponseApi.fromJson(Map<String, dynamic> json) => ResponseApi(
    message: json["message"],
    token: json["token"],
    success: json["success"], // <- Solo si tu backend lo envía
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "token": token,
    "success": success,
  };
}
