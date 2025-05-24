import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/models/trabajo.dart';
import 'package:redecom_app/src/models/user.dart';
import 'package:redecom_app/src/providers/agenda_provider.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';
// ignore: library_prefixes
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
      SnackbarService.error('❌ Error al obtener la agenda del técnico');
    }
  }

  void _initSocket(int idtec) {
    socket = IO.io('http://192.168.0.181:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.connect();

    socket.onConnect((_) {});

    socket.on('trabajoAgendado', (_) async {
      await cargarTrabajos();

      //SnackbarService.success('📋 Se ha recibido un nuevo trabajo');
    });

    socket.onDisconnect((_) {});
  }

  Future<void> cargarTrabajos() async {
    isLoading.value = true;

    try {
      final nuevosTrabajos = await agendaProvider.getAgendaTec(user.id!);

      final idsAnteriores = trabajos.map((t) => t.id).toSet();
      final idsNuevos = nuevosTrabajos.map((t) => t.id).toSet();

      final nuevos = idsNuevos.difference(idsAnteriores);
      final eliminados = idsAnteriores.difference(idsNuevos);

      trabajos.assignAll(nuevosTrabajos);

      if (nuevos.isNotEmpty) {
        SnackbarService.success('📥 Se ha recibido un nuevo trabajo');
      } else if (eliminados.isNotEmpty) {
        SnackbarService.warning('📤 Se ha eliminado un trabajo de tu agenda');
      }
    } catch (e) {
      SnackbarService.error('❌ No se pudo cargar la agenda');
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
