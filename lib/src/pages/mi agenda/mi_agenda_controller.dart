import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/models/trabajo.dart';
import 'package:redecom_app/src/models/user.dart';
import 'package:redecom_app/src/providers/agenda_provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MiAgendaController extends GetxController {
  final trabajos = <Trabajo>[].obs;
  final isLoading = false.obs;
  final AgendaProvider agendaProvider = AgendaProvider();
  late final User user;
  late IO.Socket socket;

  @override
  void onInit() {
    super.onInit();
    _setupUsuarioYAgenda();
  }

  Future<void> _setupUsuarioYAgenda() async {
    try {
      final storedUser = GetStorage().read('user');
      if (storedUser == null) throw 'No hay usuario en sesión';

      user = User.fromJson(storedUser);

      await cargarTrabajos();

      _initSocket(user.id!);
    } catch (e) {
      Get.snackbar('Error', '❌ Error al obtener la agenda del técnico');
      print('❌ $e');
    }
  }

  void _initSocket(int idtec) {
    socket = IO.io('http://192.168.0.181:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.connect();

    socket.onConnect((_) {
      print('🔌 Conectado al socket como técnico ID: $idtec');
    });

    socket.on('trabajoAgendado', (_) async {
      print('🔄 Evento trabajoAgendado recibido en MiAgendaController');
      await cargarTrabajos();
      Get.snackbar('Agenda actualizada', '📋 Se ha recibido un nuevo trabajo');
    });

    socket.onDisconnect((_) {
      print('🔌 Socket desconectado');
    });
  }

  Future<void> cargarTrabajos() async {
    isLoading.value = true;
    try {
      final list = await agendaProvider.getAgendaTec(user.id!);
      trabajos.assignAll(list);
    } catch (e) {
      Get.snackbar('Error', '❌ No se pudo cargar la agenda');
      print('❌ $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    socket.dispose();
    super.onClose();
  }
}
