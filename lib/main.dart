// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

// PAGES
import 'package:redecom_app/src/pages/home/home_page.dart';
import 'package:redecom_app/src/pages/login/login_page.dart';
import 'package:redecom_app/src/pages/mi_agenda/mi_agenda_page.dart';
import 'package:redecom_app/src/pages/mi_agenda/detalle_instalacion_page.dart';
import 'package:redecom_app/src/pages/mi_agenda/detalle_soporte_page.dart';
import 'package:redecom_app/src/pages/mi_agenda/editar_trabajo_page.dart';
import 'package:redecom_app/src/pages/perfil/perfil_info_page.dart';

// BINDINGS
import 'package:redecom_app/src/bindings/app_bindings.dart';

class Routes {
  static const login = '/';
  static const home = '/home';
  static const perfilInfo = '/home/perfil/info';
  static const miAgenda = '/tecnico/mi-agenda';
  static const detalleInstalacion = '/detalle-instalacion';
  static const detalleSoporte = '/detalle-soporte';
  static const editarTrabajo = '/editar-trabajo';
}

class AuthGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final token = (GetStorage().read('token') ?? '').toString();
    if (token.isEmpty && route != Routes.login) {
      return const RouteSettings(name: Routes.login);
    }
    return null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  final box = GetStorage();
  final isFirstInstall = box.read('first_install_done') != true;
  if (isFirstInstall) {
    await box.erase();
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
    final initialRoute =
        isFirstInstall
            ? Routes.login
            : (isLoggedIn ? Routes.home : Routes.login);

    return GetMaterialApp(
      title: 'Redecom App',
      debugShowCheckedModeBanner: false,

      initialBinding: AppInitialBinding(),
      initialRoute: initialRoute,

      // Transición por defecto (opcional)
      defaultTransition: Transition.cupertino,

      getPages: [
        GetPage(name: Routes.login, page: () => LoginPage()),
        GetPage(
          name: Routes.home,
          page: () => HomePage(),
          middlewares: [AuthGuard()],
        ),
        GetPage(
          name: Routes.perfilInfo,
          page: () => PerfilInfoPage(),
          middlewares: [AuthGuard()],
        ),

        GetPage(
          name: Routes.miAgenda,
          page: () => const MiAgendaPage(),
          binding: MiAgendaBinding(),
          middlewares: [AuthGuard()],
        ),
        GetPage(
          name: Routes.detalleInstalacion,
          page: () => const DetalleInstalacionPage(),
          binding: DetalleInstalacionBinding(),
          middlewares: [AuthGuard()],
        ),
        GetPage(
          name: Routes.detalleSoporte,
          page: () => const DetalleSoportePage(),
          binding: DetalleSoporteBinding(),
          middlewares: [AuthGuard()],
        ),
        GetPage(
          name: Routes.editarTrabajo,
          page: () => const EditarTrabajoPage(),
          binding: EditarAgendaBinding(),
          middlewares: [AuthGuard()],
        ),
      ],

      unknownRoute: GetPage(
        name: '/404',
        page:
            () =>
                const Scaffold(body: Center(child: Text('Ruta no encontrada'))),
      ),

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
