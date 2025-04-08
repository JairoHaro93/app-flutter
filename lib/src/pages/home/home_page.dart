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
        actions: [
          _backbutton(),
          /*
          GestureDetector(
            onTap: () => con.gotoPerilInfoPage(),
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25,
                  backgroundImage: NetworkImage(con.user.imagen ?? '')),
            ),
          ),*/
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(
          vertical: MediaQuery.of(context).size.height * 0.05,
        ),
        // Aquí puedes agregar el contenido principal del body
        child: Center(
          child: ElevatedButton(
            onPressed: () => con.signOut(),
            child: const Text("Cerrar sesión"),
          ),
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
      child: ElevatedButton(onPressed: () {}, child: const Text('Mi Perfil')),
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
          onPressed: () => con.signOut(),
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
}
