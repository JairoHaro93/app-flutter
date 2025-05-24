import 'package:get/get.dart';
import 'package:redecom_app/src/models/trabajo.dart';
import 'package:redecom_app/src/models/soporte.dart';
import 'package:redecom_app/src/providers/soporte_provider.dart';

class DetalleTrabajoController extends GetxController {
  final trabajoSeleccionado = Rxn<Trabajo>();
  final trabajoDetalle = Rxn<Soporte>();

  final SoporteProvider soporteProvider = SoporteProvider();

  Future<void> verDetalle(Trabajo trabajo) async {
    try {
      trabajoSeleccionado.value = trabajo;
      trabajoDetalle.value = null;

      if (trabajo.tipo == 'SOPORTE') {
        final detalle = await soporteProvider.getSopById(
          int.parse(trabajo.soporteId),
        );
        trabajoDetalle.value = detalle;
      }

      if (trabajo.tipo == 'TRABAJO') {
        trabajoDetalle.value = Soporte(
          id: 0,
          ordenInstalacion: 0,
          opcion: 0,
          telefono: '',
          registradoPorId: 0,
          registradoPorNombre: 'REDECOM',
          observaciones: 'Trabajo interno',
          fechaRegistro: trabajo.fecha,
          estado: 'PENDIENTE',
          clienteNombre: '',
          fechaAcepta: '',
          solucionDetalle: '',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cargar el detalle del trabajo');
      print('❌ Error al cargar detalle del soporte: $e');
    }
  }
}
