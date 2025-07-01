import 'package:get/get.dart';
import 'package:redecom_app/src/models/trabajo.dart';
import 'package:redecom_app/src/models/soporte.dart';
import 'package:redecom_app/src/models/imagen_instalacion.dart';
import 'package:redecom_app/src/providers/soporte_provider.dart';
import 'package:redecom_app/src/providers/imagenes_provider.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';

class DetalleTrabajoController extends GetxController {
  final trabajoSeleccionado = Rxn<Trabajo>();
  final trabajoDetalle = Rxn<Soporte>();
  final imagenesInstalacion = RxMap<String, ImagenInstalacion>();

  final soporteProvider = SoporteProvider();
  final imagenesProvider = ImagenesProvider();

  Future<void> verDetalle(Trabajo trabajo) async {
    try {
      trabajoSeleccionado.value = trabajo;
      trabajoDetalle.value = null;
      imagenesInstalacion.clear();

      if (trabajo.tipo == 'SOPORTE') {
        final detalle = await soporteProvider.getSopById(trabajo.soporteId);
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
      print(
        '📦 Buscando imágenes con tabla=neg_t_img_inst y id=${trabajo.ordenInstalacion}',
      );

      final imagenes = await imagenesProvider.getImagenesPorTrabajo(
        'neg_t_img_inst',
        trabajo.ordenInstalacion,
      );

      print('🔍 Imágenes recibidas:');
      imagenes.forEach((key, img) => print('🖼️ $key -> ${img.url}'));

      imagenesInstalacion.assignAll(imagenes);
    } catch (e) {
      print('❌ Error al cargar detalle: $e');
      SnackbarService.error('No se pudo cargar el detalle del trabajo');
    }
  }
}
