import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:redecom_app/src/models/trabajo.dart';
import 'package:redecom_app/src/pages/mi%20agenda/detalle_trabajo_page.dart';
import 'package:redecom_app/src/pages/mi%20agenda/mi_agenda_controller.dart';

class MiAgendaPage extends StatelessWidget {
  const MiAgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MiAgendaController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Agenda'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed('/home'),
        ),
      ),

      body: Obx(() {
        if (controller.trabajos.isEmpty) {
          return const Center(child: Text('No hay trabajos agendados'));
        }

        return ListView.builder(
          itemCount: controller.trabajos.length,
          itemBuilder: (context, index) {
            final Trabajo trabajo = controller.trabajos[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ListTile(
                leading: const Icon(Icons.work_outline),
                title: Text('${trabajo.tipo}  ${trabajo.subtipo}'),
                subtitle: Text(
                  '${formatFecha(trabajo.fecha)} | ${trabajo.horaInicio} - ${trabajo.horaFin}',
                ),
                trailing: Text(trabajo.vehiculo),
                onTap: () {
                  Get.to(() => DetalleTrabajoPage(trabajo: trabajo));
                },
              ),
            );
          },
        );
      }),
    );
  }

  String formatFecha(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return fecha; // Si el parse falla, muestra el valor original
    }
  }
}
