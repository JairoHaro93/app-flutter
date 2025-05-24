import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redecom_app/src/pages/mi%20agenda/editar_trabajo_controller.dart';

class EditarTrabajoPage extends StatelessWidget {
  const EditarTrabajoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditarTrabajoController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Solución'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed('/tecnico/mi-agenda'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: controller.solucionController,
              maxLines: 6,
              decoration: const InputDecoration(
                labelText: 'Solución',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () => ElevatedButton.icon(
                onPressed:
                    controller.isSaving.value
                        ? null
                        : controller.guardarSolucion,
                icon: const Icon(Icons.save),
                label: Text(
                  controller.isSaving.value ? 'Guardando...' : 'Guardar',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
