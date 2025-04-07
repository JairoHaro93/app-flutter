import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:redecom_app/src/pages/home/home_controller.dart';

class HomePage extends StatelessWidget {
  HomeController con = Get.put(HomeController());

  HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text("Home PAge")));
  }
}
