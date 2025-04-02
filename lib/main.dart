import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redecom_app/src/pages/login/login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Redecom_App",
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      getPages: [GetPage(name: "/", page: () => LoginPage())],

      theme: ThemeData(
        primaryColor: Colors.red,
        colorScheme: ColorScheme(
          primary: Colors.red,
          secondary: Colors.grey,
          brightness: Brightness.dark,
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          error: Colors.grey,
          onError: Colors.grey,
          surface: Colors.red,
          onSurface: Colors.black,
        ),
      ),
      navigatorKey: Get.key,
    );
  }
}
