import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redecom_app/src/pages/perfil/perfil_info_controller.dart';

class PerfilInfoPage extends StatelessWidget {
  PerfilInfoController con = Get.put(PerfilInfoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(leading: _backbuttonAppBar(), actions: [_logOutButton()]),
      body: Stack(
        children: [
          Center(child: Column(children: [_textName(), _textEmail()])),
        ],
      ),
    );
  }

  // Privado Boton atras
  Widget _backbuttonAppBar() {
    return SafeArea(
      child: Container(
        alignment: Alignment.topLeft,
        height: 60,
        width: 60,
        child: IconButton(
          onPressed: () => con.actionBackAppBAr(),
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 35),
        ),
      ),
    );
  }

  Widget _textName() {
    return Container(
      margin: EdgeInsets.only(top: 5),
      child: Text(
        '${con.user.name ?? ''} ',
        style: const TextStyle(color: Colors.black, fontSize: 30),
      ),
    );
  }

  Widget _textEmail() {
    return Container(
      margin: EdgeInsets.only(top: 0),
      child: ListTile(
        leading: Icon(Icons.email),
        title: Text('Email'),
        subtitle: Text(con.user.username ?? ''),
      ),
    );
  }

  Widget _logOutButton() {
    return Container(
      child: FilledButton.icon(
        onPressed: () => con.signOut(),
        icon: const Icon(Icons.power_settings_new),
        label: const Text(
          'Cerrar Sesion',
          style: TextStyle(color: Colors.black),
        ),
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.white),
          iconColor: WidgetStatePropertyAll(Colors.black),
        ),
      ),
    );
  }
}
