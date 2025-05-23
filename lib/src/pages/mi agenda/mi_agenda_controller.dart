import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/models/trabajo.dart';
import 'package:redecom_app/src/models/user.dart';
import 'package:redecom_app/src/providers/agenda_provider.dart';

class MiAgendaController extends GetxController {
  final trabajos = <Trabajo>[].obs;
  final isLoading = false.obs;
  final AgendaProvider agendaProvider = AgendaProvider();
  late final User user;

  @override
  void onInit() {
    super.onInit();
    final storedUser = GetStorage().read('user');
    if (storedUser != null) {
      user = User.fromJson(storedUser);
      cargarTrabajos();
    } else {
      Get.snackbar('Error', 'Usuario no logueado');
    }
  }

  void cargarTrabajos() async {
    isLoading.value = true;
    try {
      if (user.id == null) {
        print('⚠️ user.id es null. No se puede cargar trabajos.');
        Get.snackbar(
          'Error',
          'ID del usuario no disponible',
          backgroundColor: Colors.amber,
          colorText: Colors.white,
        );
        return;
      }

      final list = await agendaProvider.getAgendaTec(user.id!);
      trabajos.assignAll(list);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cargar los trabajos asignados',
        backgroundColor: Colors.amber,
        colorText: Colors.white,
      );
      print('❌ Error al cargar trabajos: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
