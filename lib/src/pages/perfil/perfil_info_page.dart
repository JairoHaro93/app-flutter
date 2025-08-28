import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redecom_app/src/pages/perfil/perfil_info_controller.dart';

class PerfilInfoPage extends StatelessWidget {
  final PerfilInfoController con = Get.put(PerfilInfoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(leading: _backbuttonAppBar(), actions: [_logOutButton()]),
      body: Center(child: Column(children: [_textName(), _textEmail()])),
    );
  }

  Widget _backbuttonAppBar() => SafeArea(
    child: IconButton(
      onPressed: con.actionBackAppBAr,
      icon: const Icon(Icons.arrow_back, color: Colors.black, size: 35),
    ),
  );

  Widget _textName() => Container(
    margin: const EdgeInsets.only(top: 5),
    child: Text(
      '${con.user.name ?? ''}',
      style: const TextStyle(color: Colors.black, fontSize: 30),
    ),
  );

  Widget _textEmail() => ListTile(
    leading: const Icon(Icons.email),
    title: const Text('Email'),
    subtitle: Text(con.user.username ?? ''),
  );

  Widget _logOutButton() {
    return Obx(() {
      final loading = con.isLoggingOut.value;
      return FilledButton.icon(
        onPressed: loading ? null : con.signOut,
        icon:
            loading
                ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                : const Icon(Icons.power_settings_new),
        label: const Text(
          'Cerrar Sesión',
          style: TextStyle(color: Colors.black),
        ),
        style: const ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.white),
          iconColor: WidgetStatePropertyAll(Colors.black),
        ),
      );
    });
  }
}
