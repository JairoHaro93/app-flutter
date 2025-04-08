import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redecom_app/src/pages/perfil/perfil_info_controller.dart';

class PerfilInfoPage extends StatelessWidget {
  PerfilInfoController con = Get.put(PerfilInfoController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        //   toolbarHeight: 100,
        // leading: _backbutton(),
        leading: _backbuttonAppBar(),
        actions: [
          _logOutButton(),
          // _backbutton(),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              children: [
                // _imageCover(),
                _textName(),
                _textEmail(),
                //     _textPhone(),
                //   _textCI(),
                //   _textfechaNacimiento(),
                //    _textGenero(),
              ],
            ),
          ),
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
  /*
  Widget _textPhone() {
    return Container(
      margin: EdgeInsets.only(top: 0),
      child: ListTile(
        leading: Icon(Icons.phone),
        title: Text('Telefono'),
        subtitle: Text(con.user.telefono ?? ''),
      ),
    );
  }
*/
  /*
  Widget _textCI() {
    return Container(
      margin: EdgeInsets.only(top: 0),
      child: ListTile(
        leading: Icon(Icons.person),
        title: Text('Cedula'),
        subtitle: Text(con.user.cedula ?? ''),
      ),
    );
  }
*/

  /*
  Widget _textfechaNacimiento() {
    var fecha = con.user.fecha_nacimiento ?? '';
    // var fecha2 = DateTime.parse(fecha);
    return Container(
      margin: EdgeInsets.only(top: 0),
      child: ListTile(
        leading: Icon(Icons.calendar_today),
        title: Text('Fecha de Nacimiento'),
        subtitle: Text((fecha)),
      ),
    );
  }
*/
  /*
  Widget _textGenero() {
    return Container(
      margin: EdgeInsets.only(top: 0),
      child: ListTile(
        leading: Icon(Icons.person),
        title: Text('Genero'),
        subtitle: Text((con.user.genero ?? '')),
      ),
    );
  }
*/
  /*
  //Privado Imagen LOGO
  Widget _imageCover() {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(top: 30, bottom: 20),
        child: CircleAvatar(
          backgroundColor: Colors.white,
          radius: 60,
          backgroundImage:
              con.user.imagen != null
                  ? NetworkImage(con.user.imagen!)
                  : AssetImage('assets/img/user.png') as ImageProvider,
        ),
      ),
    );
  }
*/

  Widget _logOutButton() {
    return Container(
      //alignment: Alignment.topLeft,
      // alignment: Alignment.center,
      //  alignment: Alignment(0, 0),
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
