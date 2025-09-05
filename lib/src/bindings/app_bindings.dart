// lib/src/bindings/app_bindings.dart
import 'dart:async';
import 'package:get/get.dart';

// Servicios globales
import 'package:redecom_app/src/utils/auth_service.dart';
import 'package:redecom_app/src/utils/socket_service.dart';

// Controllers de páginas
import 'package:redecom_app/src/pages/mi_agenda/mi_agenda_controller.dart';
import 'package:redecom_app/src/pages/mi_agenda/detalle_instalacion_controller.dart';
import 'package:redecom_app/src/pages/mi_agenda/detalle_soporte_controller.dart';
import 'package:redecom_app/src/pages/mi_agenda/editar_trabajo_controller.dart';

class AppInitialBinding extends Bindings {
  @override
  void dependencies() {
    final auth = Get.find<AuthService>(); // ya registrado en main()
    final socket = Get.find<SocketService>(); // ya registrado en main()

    if (auth.isLoggedIn) {
      socket.init().catchError((_) {
        // log sin hacer logout
      });
    }
  }
}

// Binding para Mi Agenda
class MiAgendaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MiAgendaController>(() => MiAgendaController(), fenix: true);
  }
}

// Binding para Detalle Instalación
class DetalleInstalacionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetalleInstalacionController>(
      () => DetalleInstalacionController(),
      fenix: true,
    );
  }
}

// Binding para Detalle Soporte (VISITA/LOS)
class DetalleSoporteBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DetalleSoporteController>(
      () => DetalleSoporteController(),
      fenix: true,
    );
  }
}

// Binding para Editar Agenda
class EditarAgendaBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditarTrabajoController>(
      () => EditarTrabajoController(),
      fenix: true,
    );
  }
}
