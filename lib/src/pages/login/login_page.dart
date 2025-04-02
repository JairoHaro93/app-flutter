import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Asegura fondo blanco por defecto
      resizeToAvoidBottomInset: true, // Ajusta cuando aparece el teclado
      body: Stack(
        children: [
          _backGround(),
          SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              children: [
                _imagen(context),
                _textAppName(),
                _textFieldUsuario(),
                _textFieldPassword(),
                _buttonLogin(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backGround() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white, // Color de fondo visible siempre
      alignment: Alignment.center,
    );
  }

  Widget _buttonLogin() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        onPressed: () {},
        child: const Text('LOGIN', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _textFieldUsuario() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      child: const TextField(
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          hintText: "Usuario",
          prefixIcon: Icon(Icons.person),
        ),
      ),
    );
  }

  Widget _textFieldPassword() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: const TextField(
        keyboardType: TextInputType.text,
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Contraseña",
          prefixIcon: Icon(Icons.lock),
        ),
      ),
    );
  }

  Widget _textAppName() {
    return const Text(
      "REDECOM INTERNO",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _imagen(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/img/logo.png',
          width: MediaQuery.of(context).size.height * 0.3,
        ),
      ),
    );
  }
}
