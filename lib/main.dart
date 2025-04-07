import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/models/user.dart';
import 'package:redecom_app/src/pages/home/home_page.dart';
import 'package:redecom_app/src/pages/login/login_page.dart';

late User userSession;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  final userData = GetStorage().read('user');
  if (userData is Map<String, dynamic> && userData.isNotEmpty) {
    userSession = User.fromJson(userData);
  } else {
    userSession = User(); // crea usuario vacío si no hay sesión
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    print('Usuario id: ${userSession.id}');
    return GetMaterialApp(
      title: "Redecom_App",
      debugShowCheckedModeBanner: false,

      initialRoute: userSession.id != null ? "/home" : "/",

      getPages: [
        GetPage(name: "/", page: () => LoginPage()),
        GetPage(name: "/home", page: () => HomePage()),
      ],

      theme: ThemeData(
        primaryColor: Colors.blue,
        colorScheme: const ColorScheme(
          primary: Colors.red,
          secondary: Colors.grey,
          brightness: Brightness.dark,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          error: Colors.grey,
          onError: Colors.grey,
          surface: Colors.green,
          onSurface: Colors.black,
        ),
      ),
      navigatorKey: Get.key,
    );
  }
}
