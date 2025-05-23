import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/models/response_api.dart';
import 'package:redecom_app/src/models/user.dart';
import 'package:redecom_app/src/providers/login_provider.dart';

class PerfilInfoController extends GetxController {
  User user = User.fromJson(GetStorage().read('user'));

  final LoginProvider loginProvider = LoginProvider();

  Future<void> signOut() async {
    ResponseApi responseApi = await loginProvider.logout(user.id ?? 0);

    // Si quieres verificar si fue exitoso, puedes usar algo como:
    if (responseApi.success == true) {
      GetStorage().remove('user');
      Get.offNamedUntil('/', (route) => false); // Redirige y limpia historial
    } else {
      Get.snackbar(
        'Error',
        'No se pudo cerrar la sesión',
        backgroundColor: Get.theme.colorScheme.errorContainer,
        colorText: Get.theme.colorScheme.onErrorContainer,
      );
    }
  }

  void actionBackAppBAr() {
    Get.toNamed('/home');
  }
}
