// lib/src/bindings/app_bindings.dart
import 'package:get/get.dart';
import 'package:redecom_app/src/pages/mi_agenda/editar_agenda_controller.dart';

// Servicios globales
import 'package:redecom_app/src/utils/auth_service.dart';
import 'package:redecom_app/src/utils/socket_service.dart';

// Controllers de páginas
import 'package:redecom_app/src/pages/mi_agenda/mi_agenda_controller.dart';
import 'package:redecom_app/src/pages/mi_agenda/detalle_instalacion_controller.dart';
import 'package:redecom_app/src/pages/mi_agenda/detalle_soporte_controller.dart';

/// Se ejecuta al iniciar la app. Registra servicios globales.
class AppInitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthService>(AuthService(), permanent: true);
    Get.put<SocketService>(SocketService(), permanent: true);
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

// binding
class EditarAgendaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditarAgendaController>(
      () => EditarAgendaController(),
      fenix: true,
    );
  }
}
