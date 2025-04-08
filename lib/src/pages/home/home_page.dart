import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:redecom_app/src/pages/home/home_controller.dart';

class HomePage extends StatelessWidget {
  HomeController con = Get.put(HomeController());

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
          childAspectRatio: 0.85,
          children:
              con.opcionesVisibles.entries
                  .expand(
                    (entry) => entry.value.map((opcion) {
                      final areaKey = entry.key;
                      return _cardOpcion(areaKey, opcion);
                    }),
                  )
                  .toList(),
        ),
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
            '${con.user.name ?? ''}',
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

  Widget _cardOpcion(String area, String opcion) {
    return GestureDetector(
      onTap: () => con.gotoOpcion(opcion),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 70,
                width: 70,
                child: Image.asset(
                  'assets/img/$opcion.png',
                  fit: BoxFit.contain,
                  errorBuilder:
                      (context, error, stackTrace) =>
                          const Icon(Icons.image_not_supported, size: 50),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                opcion,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
