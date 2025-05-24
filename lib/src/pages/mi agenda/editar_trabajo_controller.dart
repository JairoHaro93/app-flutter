import 'package:get/get.dart';
import 'package:redecom_app/src/models/trabajo.dart';
import 'package:redecom_app/src/providers/agenda_provider.dart';
import 'package:get_storage/get_storage.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';

class EditarTrabajoController extends GetxController {
  final AgendaProvider agendaProvider = AgendaProvider();
  final isSaving = false.obs;
  final solucionController = TextEditingController();

  late Trabajo trabajo;
  late IO.Socket socket;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Trabajo) {
      trabajo = Get.arguments as Trabajo;
      solucionController.text = trabajo.solucion ?? '';
    }
    _initSocket();
  }

  void _initSocket() {
    socket = IO.io('http://192.168.0.181:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.connect();
  }

  Future<void> guardarSolucion() async {
    final solucion = solucionController.text.trim();

    if (trabajo.id == null || solucion.isEmpty) {
      Get.snackbar('Campo obligatorio', 'Ingresa una solución');
      return;
    }

    isSaving.value = true;

    try {
      final actualizado = trabajo.copyWith(
        estado: 'CONCLUIDO',
        solucion: solucion,
      );

      await agendaProvider.actualizarAgendaSolucion(
        actualizado.id,
        actualizado,
      );

      socket.emit('trabajoCulminado');

      Get.offAllNamed('/tecnico/mi-agenda');
      //Get.snackbar('Éxito', '✅ Trabajo actualizado correctamente');
    } catch (e) {
      Get.snackbar('Error', '❌ No se pudo guardar la solución');
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    solucionController.dispose();
    socket.dispose();
    super.onClose();
  }
}
