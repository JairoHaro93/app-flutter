import 'dart:convert';

ResponseApi responseApiFromJson(String str) =>
    ResponseApi.fromJson(json.decode(str));

String responseApiToJson(ResponseApi data) => json.encode(data.toJson());

class ResponseApi {
  String? message;
  dynamic token;

  ResponseApi({this.message, this.token});

  factory ResponseApi.fromJson(Map<String, dynamic> json) =>
      ResponseApi(message: json["message"], token: json["token"]);

  Map<String, dynamic> toJson() => {"message": message, "token": token};
}
