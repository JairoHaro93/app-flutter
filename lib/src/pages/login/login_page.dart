import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redecom_app/src/pages/login/login_controller.dart';

class LoginPage extends StatelessWidget {
  LoginController con = Get.put(LoginController());

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          _backGround(),

          // Contenido desplazable (logo, campos, etc.)
          SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 60,
              bottom: MediaQuery.of(context).viewInsets.bottom + 100,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _imagen(context, isKeyboardOpen),
                const SizedBox(height: 10),
                _textAppName(),
                _textFieldUsuario(),
                _textFieldPassword(),
              ],
            ),
          ),

          // Botón fijo abajo
          Positioned(bottom: 30, left: 40, right: 40, child: _buttonLogin()),
        ],
      ),
    );
  }

  Widget _backGround() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white,
    );
  }

  Widget _buttonLogin() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: () => con.login(),
        child: const Text('LOGIN', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _textFieldUsuario() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: con.usuarioController,
        decoration: const InputDecoration(
          hintText: "Usuario",
          prefixIcon: Icon(Icons.person),
        ),
      ),
    );
  }

  Widget _textFieldPassword() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: con.passwordController,
        obscureText: true,
        decoration: const InputDecoration(
          hintText: "Contraseña",
          prefixIcon: Icon(Icons.lock),
        ),
      ),
    );
  }

  Widget _textAppName() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        "REDECOM INTERNO",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _imagen(BuildContext context, bool isKeyboardOpen) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 20),
      child: Image.asset(
        'assets/img/logo.png',
        width:
            MediaQuery.of(context).size.height * (isKeyboardOpen ? 0.15 : 0.3),
      ),
    );
  }
}
