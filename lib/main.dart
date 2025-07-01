import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/pages/home/home_page.dart';
import 'package:redecom_app/src/pages/login/login_page.dart';
import 'package:redecom_app/src/pages/mi%20agenda/mi_agenda_page.dart';
import 'package:redecom_app/src/pages/perfil/perfil_info_page.dart';
import 'package:redecom_app/src/utils/socket_service.dart';
import 'package:redecom_app/src/utils/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // Carga servicios globales
  Get.put(AuthService());
  Get.put(SocketService());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return GetMaterialApp(
      title: "Redecom_App",
      debugShowCheckedModeBanner: false,

      initialRoute: authService.isLoggedIn ? "/home" : "/",

      getPages: [
        GetPage(name: "/", page: () => LoginPage()),
        GetPage(name: "/home", page: () => HomePage()),
        GetPage(name: "/home/perfil/info", page: () => PerfilInfoPage()),
        GetPage(name: "/tecnico/mi-agenda", page: () => MiAgendaPage()),
      ],

      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme(
          primary: Colors.red,
          secondary: Colors.grey,
          brightness: Brightness.dark,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          error: Color.fromARGB(255, 187, 25, 25),
          onError: Colors.grey,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
      ),
      navigatorKey: Get.key,
    );
  }
}
