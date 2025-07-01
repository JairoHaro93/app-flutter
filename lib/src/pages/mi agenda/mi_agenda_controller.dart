import 'package:get/get.dart';
import 'package:redecom_app/src/models/trabajo.dart';
import 'package:redecom_app/src/models/user.dart';
import 'package:redecom_app/src/providers/agenda_provider.dart';
import 'package:redecom_app/src/utils/socket_service.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';
import 'package:redecom_app/src/utils/auth_service.dart';

class MiAgendaController extends GetxController {
  final trabajos = <Trabajo>[].obs;
  final isLoading = false.obs;
  final AgendaProvider agendaProvider = AgendaProvider();
  late final User user;

  final socketService = Get.find<SocketService>();

  @override
  void onInit() {
    super.onInit();
    _setupUsuarioYAgenda();
  }

  Future<void> _setupUsuarioYAgenda() async {
    try {
      final authService = Get.find<AuthService>();
      final current = authService.currentUser;
      if (current == null) throw 'No hay usuario en sesión';

      user = current;

      await socketService.init(); // ✅ agrega esto
      await cargarTrabajos();

      _escucharSocket(); // ✅ ahora el socket ya está listo
    } catch (e) {
      print('❌ Error al obtener la agenda del técnico: $e');
      SnackbarService.error('❌ Error al obtener la agenda del técnico');
    }
  }

  void _escucharSocket() {
    socketService.on('trabajoAgendado', (_) async {
      await cargarTrabajos();
    });
  }

  Future<void> cargarTrabajos() async {
    isLoading.value = true;

    try {
      print('🔍 Usuario actual: ${user.toJson()}');
      final nuevosTrabajos = await agendaProvider.getAgendaTec(user.id!);

      final idsAnteriores = trabajos.map((t) => t.id).toSet();
      final idsNuevos = nuevosTrabajos.map((t) => t.id).toSet();

      final nuevos = idsNuevos.difference(idsAnteriores);
      final eliminados = idsAnteriores.difference(idsNuevos);

      trabajos.assignAll(nuevosTrabajos);

      if (nuevos.isNotEmpty) {
        SnackbarService.success('📥 Se ha recibido un nuevo trabajo');
      } else if (eliminados.isNotEmpty) {
        Get.offAllNamed('/home');
        SnackbarService.warning('📤 Se ha eliminado un trabajo de tu agenda');
      }
    } catch (e) {
      print('❌ Error en cargarTrabajos: $e');
      SnackbarService.error('❌ No se pudo cargar la agenda');
    } finally {
      isLoading.value = false;
    }
  }
}
