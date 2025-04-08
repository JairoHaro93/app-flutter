import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/models/user.dart';

class PerfilInfoController extends GetxController {
  User user = User.fromJson(GetStorage().read('user'));
  void signOut() {
    GetStorage().remove('user');
    // Elimina el historial de pantallas
    Get.offNamedUntil('/', (route) => false);
  }

  void actionBackAppBAr() {
    Get.toNamed('/home');
  }
}
