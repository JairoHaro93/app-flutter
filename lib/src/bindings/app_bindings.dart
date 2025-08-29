// lib/src/bindings/app_bindings.dart
import 'package:get/get.dart';

// Servicios globales
import 'package:redecom_app/src/utils/auth_service.dart';
import 'package:redecom_app/src/utils/socket_service.dart';

// Controllers de páginas
import 'package:redecom_app/src/pages/mi_agenda/mi_agenda_controller.dart';
import 'package:redecom_app/src/pages/mi_agenda/detalle_instalacion_controller.dart';
import 'package:redecom_app/src/pages/mi_agenda/detalle_soporte_controller.dart';
import 'package:redecom_app/src/pages/mi_agenda/editar_trabajo_controller.dart';

/// Se ejecuta al iniciar la app. Registra servicios globales.
class AppInitialBinding extends Bindings {
  @override
  void dependencies() {
    // 1) Servicios singleton
    final auth = Get.put<AuthService>(AuthService(), permanent: true);
    final socket = Get.put<SocketService>(SocketService(), permanent: true);

    // 2) Si ya hay sesión válida al abrir la app, inicia socket
    if (auth.isLoggedIn) {
      // no await: el binding no es async; el init se ejecuta en background
      // y SocketService está preparado para múltiples llamadas idempotentes
      // (si ya está inicializado no hace nada).
      // ignore: discarded_futures
      socket.init();
    }
  }
}

/// Binding para Mi Agenda
class MiAgendaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MiAgendaController>(() => MiAgendaController(), fenix: true);
  }
}

/// Binding para Detalle Instalación
class DetalleInstalacionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetalleInstalacionController>(
      () => DetalleInstalacionController(),
      fenix: true,
    );
  }
}

/// Binding para Detalle Soporte (VISITA/LOS)
class DetalleSoporteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetalleSoporteController>(
      () => DetalleSoporteController(),
      fenix: true,
    );
  }
}

/// Binding para Editar Agenda
class EditarAgendaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditarTrabajoController>(
      () => EditarTrabajoController(),
      fenix: true,
    );
  }
}
