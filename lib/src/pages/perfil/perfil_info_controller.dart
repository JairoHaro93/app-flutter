import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:redecom_app/src/models/user.dart';
import 'package:redecom_app/src/providers/login_provider.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';
import 'package:redecom_app/src/utils/auth_service.dart';

class PerfilInfoController extends GetxController {
  final _box = GetStorage();
  final _auth = Get.find<AuthService>();
  final _loginProvider = Get.put(LoginProvider());

  late final User user;
  final isLoggingOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    user = User.fromJson(_box.read('user') ?? {});
  }

  Future<void> signOut() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;

    final uid = _auth.userId;
    if (uid != null) {
      try {
        final r = await _loginProvider.logout(uid);
        if (r.success != true && r.message != null) {
          SnackbarService.warning(r.message!);
        }
      } catch (_) {}
    }

    await _auth
        .logout(); // <- cierra socket + limpia claves + Get.offAllNamed('/')

    isLoggingOut.value = false;
  }

  void actionBackAppBAr() => Get.back();
}
