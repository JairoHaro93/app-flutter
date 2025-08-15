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
    trabajoSeleccionado.value = trabajo;
    trabajoDetalle.value = null;
    imagenesInstalacion.clear();

    print('🔧 Trabajo seleccionado:');
    print('🆔 ID: ${trabajo.id}');
    print('📦 Tipo: ${trabajo.tipo}');
    print('📅 Fecha: ${trabajo.fecha}');
    print('🚗 Vehículo: ${trabajo.vehiculo}');
    print('🧑 Técnico: ${trabajo.tecnico}');
    print('📞 Teléfono: ${trabajo.telefono}');
    print('🗺️ Coordenadas: ${trabajo.coordenadas}');
    print('🔗 OrdenInstalacion: ${trabajo.ordenInstalacion}');
    print('📄 Observaciones: ${trabajo.observaciones}');

    try {
      if (trabajo.tipo == 'SOPORTE') {
        final detalle = await soporteProvider.getSopById(trabajo.soporteId);
        trabajoDetalle.value = detalle;
        print('📘 Detalle SOPORTE: ${detalle.toJson()}');
      } else if (trabajo.tipo == 'TRABAJO' || trabajo.tipo == 'INSTALACION') {
        trabajoDetalle.value = Soporte(
          id: 0,
          ordenInstalacion: 0,
          opcion: 0,
          telefono: '',
          registradoPorId: 0,
          registradoPorNombre: 'REDECOM',
          observaciones:
              trabajo.tipo == 'TRABAJO'
                  ? 'Trabajo interno'
                  : 'Nueva Instalacion',
          fechaRegistro: trabajo.fecha,
          estado: 'PENDIENTE',
          clienteNombre: '',
          fechaAcepta: '',
          solucionDetalle: '',
        );
        print(
          '📘 Detalle generado para tipo ${trabajo.tipo}: ${trabajoDetalle.value!.toJson()}',
        );
      }
    } catch (e) {
      print('❌ Error al cargar detalle del trabajo: $e');
      SnackbarService.error('No se pudo cargar el detalle del trabajo');
      return;
    }

    try {
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
      print('⚠️ No se pudieron cargar las imágenes: $e');
    }
  }
}
