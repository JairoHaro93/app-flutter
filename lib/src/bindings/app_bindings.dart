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
    // 1) Servicios singleton
    final auth = Get.put<AuthService>(AuthService(), permanent: true);
    final socket = Get.put<SocketService>(SocketService(), permanent: true);

    // 2) Arranque perezoso del socket si ya hay sesión (no bloqueante + timeout seguro)
    if (auth.isLoggedIn) {
      unawaited(
        socket.init().timeout(
          const Duration(seconds: 6),
          onTimeout: () => socket,
        ),
      );
    }

    // 3) (Opcional recomendado) Reaccionar a cambios de sesión:
    // Si tu AuthService expone algo como `RxBool loggedIn$`, usa:
    // ever<bool>(auth.loggedIn$, (logged) {
    //   if (logged) {
    //     unawaited(socket.init().timeout(const Duration(seconds: 6), onTimeout: () => null));
    //   } else {
    //     // Cierra socket sin lanzar
    //     unawaited(socket.disposeSafe());
    //   }
    // });
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
