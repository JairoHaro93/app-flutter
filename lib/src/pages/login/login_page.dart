// lib/src/pages/login/login_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redecom_app/src/pages/login/login_controller.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final LoginController con = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 480 ? 24.0 : 70.0;
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _imgLogo(),
                  const SizedBox(height: 8),
                  _txt1(),
                  const SizedBox(height: 32),
                  _boxForm(),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: SizedBox(height: 50, child: _txt2()),
    );
  }

  // Logo
  Widget _imgLogo() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Image.asset('assets/img/logo.png'),
    );
  }

  // Formulario
  Widget _boxForm() {
    return AutofillGroup(
      child: Column(
        children: [
          _txtfldUsuario(),
          _txtfldPassword(),
          const SizedBox(height: 8),
          _btnLogin(),
        ],
      ),
    );
  }

  Widget _txtfldUsuario() {
    return TextField(
      controller: con.usuarioController,
      style: const TextStyle(color: Colors.black, fontSize: 18),
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.username],
      autocorrect: false,
      enableSuggestions: false,
      decoration: const InputDecoration(
        hintText: 'Usuario',
        prefixIcon: Icon(Icons.person),
      ),
    );
  }

  Widget _txtfldPassword() {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: TextField(
          controller: con.passwordController,
          style: const TextStyle(color: Colors.black, fontSize: 18),
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            FocusScope.of(Get.context!).unfocus(); // cierra teclado
            con.login();
          },
          obscureText: !con.passwordVisible.value,
          autofillHints: const [AutofillHints.password],
          autocorrect: false,
          enableSuggestions: false,
          decoration: InputDecoration(
            hintText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              onPressed: () => con.passwordVisible.toggle(),
              icon: Icon(
                con.passwordVisible.value
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _btnLogin() {
    return Obx(() {
      final loading = con.isLoading.value;
      return SizedBox(
        width: 220,
        child: ElevatedButton(
          onPressed:
              loading
                  ? null
                  : () {
                    FocusScope.of(Get.context!).unfocus(); // cierra teclado
                    con.login();
                  },
          child:
              loading
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                  : const Text(
                    'Iniciar Sesión',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
        ),
      );
    });
  }

  // Texto superior
  Widget _txt1() {
    return const Text(
      'INTERNO',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 70, 41, 41),
      ),
    );
  }

  // Footer
  static Widget _txt2() {
    return const Center(
      child: Text(
        'REDECOM Marca Registrada 2025',
        style: TextStyle(color: Colors.red),
      ),
    );
  }
}
