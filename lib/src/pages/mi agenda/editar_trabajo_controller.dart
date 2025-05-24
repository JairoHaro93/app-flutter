import 'package:get/get.dart';
import 'package:redecom_app/src/environmets/environment.dart';
import 'package:redecom_app/src/models/trabajo.dart';
import 'package:redecom_app/src/providers/agenda_provider.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';
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
    socket = IO.io(Environment.API_WEBSOKETS, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });
    socket.connect();
  }

  Future<void> guardarSolucion() async {
    final solucion = solucionController.text.trim();

    if (solucion.isEmpty) {
      SnackbarService.warning('Ingresa una solución');

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
    } catch (e) {
      SnackbarService.error('❌ No se pudo guardar la solución');
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
