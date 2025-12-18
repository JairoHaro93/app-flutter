// lib/src/bindings/app_bindings.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:redecom_app/src/pages/home/mi_horario_controller.dart';
import 'package:redecom_app/src/pages/mi_agenda/editar_infra_controller.dart';
import 'package:redecom_app/src/providers/mi_horario_provider.dart';

// Servicios globales
import 'package:redecom_app/src/utils/auth_service.dart';
import 'package:redecom_app/src/utils/socket_service.dart';

// Controllers de páginas
import 'package:redecom_app/src/pages/mi_agenda/mi_agenda_controller.dart';
import 'package:redecom_app/src/pages/mi_agenda/detalle_instalacion_controller.dart';
import 'package:redecom_app/src/pages/mi_agenda/detalle_soporte_controller.dart';
import 'package:redecom_app/src/pages/mi_agenda/editar_trabajo_controller.dart';

import 'package:redecom_app/src/providers/images_provider.dart';

class AppInitialBinding extends Bindings {
  @override
  void dependencies() {
    // Asegura servicios globales (por si arrancas sin registrarlos en main)
    if (!Get.isRegistered<AuthService>()) {
      Get.put<AuthService>(AuthService(), permanent: true);
    }
    if (!Get.isRegistered<SocketService>()) {
      Get.put<SocketService>(SocketService(), permanent: true);
    }

    final auth = Get.find<AuthService>();
    final socket = Get.find<SocketService>();

    if (auth.isLoggedIn) {
      // No bloquea el arranque si falla
      unawaited(
        // ignore: body_might_complete_normally_catch_error
        socket.init().catchError((_) {
          // log opcional
        }),
      );
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

class EditarInfraBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ImagesProvider>()) {
      Get.lazyPut<ImagesProvider>(() => ImagesProvider(), fenix: true);
    }
    // AuthService ya está en AppInitialBinding (permanent: true). No re-registrar.
    Get.lazyPut<EditarInfraestructuraController>(
      () => EditarInfraestructuraController(),
      fenix: true,
    );
  }
}

// Binding para Mi Horario (Turnos + Asistencias)
class MiHorarioBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MiHorarioProvider>()) {
      Get.lazyPut<MiHorarioProvider>(() => MiHorarioProvider(), fenix: true);
    }

    Get.lazyPut<MiHorarioController>(
      () => MiHorarioController(provider: Get.find<MiHorarioProvider>()),
      fenix: true,
    );
  }
}
