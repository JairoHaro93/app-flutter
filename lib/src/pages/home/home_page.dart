import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:redecom_app/src/pages/home/home_controller.dart';

// ignore: must_be_immutable
class HomePage extends StatelessWidget {
  HomeController con = Get.put(HomeController());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        backgroundColor: Colors.redAccent,
        child: Column(
          children: [
            _drawerEncabezado(),
            _boton1Drawer(),
            _boton2Drawer(),
            _botonMiHorarioDrawer(), // <-- NUEVO
            _boton3Drawer(),
          ],
        ),
      ),
      appBar: AppBar(
        toolbarHeight: 80,
        title: const Text('Menu', style: TextStyle(color: Colors.black)),
        actions: [_backbutton()],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.05,
          horizontal: 15,
        ),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.9,
          children:
              con.opcionesVisibles.entries
                  .where((entry) => entry.value.isNotEmpty)
                  .map((entry) => _cardArea(entry.key, entry.value))
                  .toList(),
        ),
      ),
    );
  }

  Container _botonMiHorarioDrawer() {
    return Container(
      color: Colors.red,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => con.gotoMiHorario(),
        child: const Text('Mi Horario'),
      ),
    );
  }

  Container _boton1Drawer() {
    return Container(
      color: Colors.red,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Notificaciones'),
      ),
    );
  }

  Container _boton2Drawer() {
    return Container(
      color: Colors.red,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {},
        child: const Text('Solicitud Horas Extras'),
      ),
    );
  }

  Container _boton3Drawer() {
    return Container(
      color: Colors.red,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => con.gotoPerilInfoPage(),
        child: const Text('Mi Perfil'),
      ),
    );
  }

  Container _drawerEncabezado() {
    return Container(
      margin: const EdgeInsets.only(top: 50, bottom: 20),
      child: Column(
        children: [
          const CircleAvatar(backgroundColor: Colors.white, radius: 50),
          Text(
            '${con.user?.name ?? 'Usuario'}',
            style: const TextStyle(color: Colors.black, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _backbutton() {
    return SafeArea(
      child: Container(
        child: FilledButton.icon(
          onPressed: () => exit(0),
          icon: const Icon(Icons.arrow_back),
          label: const Text('SALIR', style: TextStyle(color: Colors.black)),
          style: const ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.white),
            iconColor: WidgetStatePropertyAll(Colors.black),
          ),
        ),
      ),
    );
  }

  void _mostrarOpcionesDeArea(String area, List<String> funciones) {
    showModalBottomSheet(
      context: Get.context!,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Text(
                'Opciones de $area',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(),
            ...funciones.map((opcion) {
              return ListTile(
                leading: const Icon(Icons.arrow_forward_ios),
                title: Text(opcion),
                onTap: () {
                  Get.back(); // cerrar el modal
                  con.gotoOpcion(opcion); // navegar
                },
              );
            }).toList(),
          ],
        );
      },
    );
  }

  Widget _cardArea(String area, List<String> funciones) {
    return GestureDetector(
      onTap: () => _mostrarOpcionesDeArea(area, funciones),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 70,
              width: 70,
              child: Image.asset(
                'assets/img/$area.png',
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.dashboard, size: 50),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              area,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
