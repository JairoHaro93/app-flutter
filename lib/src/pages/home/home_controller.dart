import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/models/user.dart';

class HomeController extends GetxController {
  late User user;

  HomeController() {
    final storage = GetStorage();
    final userData = storage.read('user');

    if (userData != null) {
      user = User.fromJson(userData);
      print(user.toJson());
    } else {
      print('No se encontró usuario en local storage');
    }
  }

  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil(
      '/',
      (route) => false,
    ); //Elimina el historial de pantallas
  }
}
