import 'package:get/get.dart';
import 'package:redecom_app/src/environmets/environment.dart';
import 'package:redecom_app/src/models/response_api.dart';

class LoginProvider extends GetConnect {
  String url = "${Environment.API_URL}login";

  Future<ResponseApi> login(String usuario, String password) async {
    Response response = await post(
      url,

      {'usuario': usuario, 'password': password},
      headers: {'Contet-Type': 'application/json'},
    );

    print(url);

    if (response.body == null) {
      Get.snackbar('Eror', 'No se pudo ejecutar la pericion');
      return ResponseApi();
    }

    ResponseApi responseApi = ResponseApi.fromJson(response.body);

    return responseApi;
  }
}
