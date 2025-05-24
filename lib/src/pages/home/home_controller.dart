import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:redecom_app/src/models/user.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';

class HomeController extends GetxController {
  late User user;

  List<String> arrAdmin = [];
  List<String> arrBodega = [];
  List<String> arrNoc = [];
  List<String> arrTecnico = [];
  List<String> arrClientes = [];
  List<String> arrRecuperacion = [];
  Map<String, List<String>> opcionesVisibles = {};

  //ARRAY DONDE SE CREAN LAS OPCIONES DE FUNCIONES PARA LA APP
  final Map<String, List<String>> funcionesVisiblesFlutter = {
    'NOC': [],
    'Admin': [],
    'Técnico': ['Registro Soporte', 'Mi Agenda'],
    'Recuperación': ['Mapa Morosos'],
    'Bodega': ['Inventario'],
    // Puedes seguir agregando por área
  };

  @override
  void onInit() {
    super.onInit();
    final storage = GetStorage();
    final userData = storage.read('user');

    if (userData != null) {
      user = User.fromJson(userData);
      print(user.toJson());
      definirAreas();
    } else {
      print('No se encontró usuario en local storage');
    }
  }

  void definirAreas() {
    List<String> roles = List<String>.from(user.roles as Iterable);

    if (roles.isNotEmpty) {
      arrAdmin = roles.where((rol) => rol.startsWith('A')).toList();
      arrBodega = roles.where((rol) => rol.startsWith('B')).toList();
      arrNoc = roles.where((rol) => rol.startsWith('N')).toList();
      arrTecnico = roles.where((rol) => rol.startsWith('T')).toList();
      arrClientes = roles.where((rol) => rol.startsWith('C')).toList();
      arrRecuperacion = roles.where((rol) => rol.startsWith('R')).toList();

      opcionesVisibles = {
        'Admin':
            arrAdmin
                .map((e) => e.substring(1))
                .where(
                  (e) =>
                      funcionesVisiblesFlutter['Admin']?.contains(e) ?? false,
                )
                .toList(),
        'Bodega':
            arrBodega
                .map((e) => e.substring(1))
                .where(
                  (e) =>
                      funcionesVisiblesFlutter['Bodega']?.contains(e) ?? false,
                )
                .toList(),
        'NOC':
            arrNoc
                .map((e) => e.substring(1))
                .where(
                  (e) => funcionesVisiblesFlutter['NOC']?.contains(e) ?? false,
                )
                .toList(),
        'Técnico':
            arrTecnico
                .map((e) => e.substring(1))
                .where(
                  (e) =>
                      funcionesVisiblesFlutter['Técnico']?.contains(e) ?? false,
                )
                .toList(),
        'Clientes':
            arrClientes
                .map((e) => e.substring(1))
                .where(
                  (e) =>
                      funcionesVisiblesFlutter['Clientes']?.contains(e) ??
                      false,
                )
                .toList(),
        'Recuperación':
            arrRecuperacion
                .map((e) => e.substring(1))
                .where(
                  (e) =>
                      funcionesVisiblesFlutter['Recuperación']?.contains(e) ??
                      false,
                )
                .toList(),
      };

      print('Opciones visibles: $opcionesVisibles');
    }
  }

  void signOut() {
    GetStorage().remove('user');
    Get.offNamedUntil('/', (route) => false);
  }

  void gotoPerilInfoPage() {
    Get.toNamed('/home/perfil/info');
  }

  final Map<String, String> rutasPorOpcion = {
    'Mi Agenda': '/tecnico/mi-agenda',
    'Registro Soporte': '/tecnico/soporte',
    'Mapa Morosos': '/recuperacion/mapa',
    'Inventario': '/bodega/inventario',
    'Usuarios': '/admin/usuarios',
  };

  void gotoOpcion(String opcion) {
    final ruta = rutasPorOpcion[opcion];
    if (ruta != null) {
      Get.toNamed(ruta);
    } else {
      SnackbarService.warning('Función no implementada: $opcion');
    }
  }
}
