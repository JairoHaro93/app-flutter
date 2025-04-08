import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redecom_app/src/pages/login/login_controller.dart';

class LoginPage extends StatelessWidget {
  LoginController con = Get.put(LoginController());

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(children: [_imgLogo(), _txt1(), _boxForm(context)]),
      ),
      bottomNavigationBar: SizedBox(height: 50, child: _txt2()),
    );
  }

  // Imagen Logo
  Widget _imgLogo() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        alignment: Alignment.center,
        width: 200,
        height: 200,
        child: Image.asset('assets/img/logo.png'),
      ),
    );
  }

  Widget _boxForm(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60, left: 70, right: 70),
      //height: MediaQuery.of(context).size.height * 0.45,
      child: Column(children: [_txtfldEmail(), _txtfldPassword(), _btnLogin()]),
    );
  }

  Widget _txtfldEmail() {
    return TextField(
      controller: con.usuarioController,
      style: const TextStyle(color: Colors.black, fontSize: 18),
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        hintText: 'Usuario',
        prefixIcon: Icon(Icons.person),
      ),
    );
  }

  Widget _txtfldPassword() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: TextField(
        controller: con.passwordController,
        style: const TextStyle(color: Colors.black, fontSize: 18),
        keyboardType: TextInputType.text,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: 'Contraseña',
          prefixIcon: Icon(Icons.lock),
        ),
      ),
    );
  }

  Widget _btnLogin() {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: () => con.login(),
        child: const Text(
          'Iniciar Sesion',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  // Texto 1
  Widget _txt1() {
    return const Text(
      'INTERNO',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  // Texto 1
  Widget _txt2() {
    return const Center(
      child: Text(
        ' REDECOM Marca Registrada 2025',
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}
