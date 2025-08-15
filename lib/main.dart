// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// Pages
import 'package:redecom_app/src/pages/home/home_page.dart';
import 'package:redecom_app/src/pages/login/login_page.dart';
import 'package:redecom_app/src/pages/mi%20agenda/mi_agenda_page.dart';
import 'package:redecom_app/src/pages/mi%20agenda/detalle_instalacion_page.dart';
import 'package:redecom_app/src/pages/mi%20agenda/detalle_soporte_page.dart';
import 'package:redecom_app/src/pages/mi%20agenda/editar_trabajo_page.dart';
import 'package:redecom_app/src/pages/perfil/perfil_info_page.dart';

// Bindings centralizados
import 'package:redecom_app/src/bindings/app_bindings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  final box = GetStorage();

  // Fuerza Login en primera instalación
  final isFirstInstall = box.read('first_install_done') != true;
  if (isFirstInstall) {
    await box.erase(); // limpia cualquier resto restaurado por el SO
    await box.write('first_install_done', true);
  }

  Intl.defaultLocale = 'es_EC';
  await initializeDateFormatting('es_EC');

  runApp(MyApp(isFirstInstall: isFirstInstall));
}

class MyApp extends StatelessWidget {
  final bool isFirstInstall;
  const MyApp({super.key, required this.isFirstInstall});

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final isLoggedIn = (box.read('token') ?? '').toString().isNotEmpty;

    final initialRoute = isFirstInstall ? '/' : (isLoggedIn ? '/home' : '/');

    return GetMaterialApp(
      title: "Redecom_App",
      debugShowCheckedModeBanner: false,

      // Registra servicios/controladores globales
      initialBinding: AppInitialBinding(),

      // Ruta inicial (Login en primera instalación)
      initialRoute: initialRoute,

      getPages: [
        GetPage(name: "/", page: () => LoginPage()),
        GetPage(name: "/home", page: () => HomePage()),
        GetPage(name: "/home/perfil/info", page: () => PerfilInfoPage()),

        // Agenda con binding
        GetPage(
          name: "/tecnico/mi-agenda",
          page: () => const MiAgendaPage(),
          binding: MiAgendaBinding(),
        ),

        // Detalles con bindings
        GetPage(
          name: "/detalle-instalacion",
          page: () => const DetalleInstalacionPage(),
          binding: DetalleInstalacionBinding(),
        ),
        GetPage(
          name: "/detalle-soporte",
          page: () => const DetalleSoportePage(),
          binding: DetalleSoporteBinding(),
        ),

        // Edición de trabajo
        GetPage(
          name: "/editar-trabajo",
          page: () => const EditarTrabajoPage(),
          binding: EditarTrabajoBinding(),
        ),
      ],

      // Tema claro y fondo blanco consistente
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.grey,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.black,
          onSurface: Colors.black,
          error: Color(0xFFBB1919),
          onError: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0.5,
        ),
        cardTheme: const CardTheme(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 1,
        ),
        canvasColor: Colors.white,
      ),

      navigatorKey: Get.key,
    );
  }
}
