import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:redecom_app/src/pages/mi%20agenda/editar_trabajo_controller.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';
import 'package:redecom_app/src/models/imagen_instalacion.dart';

class EditarTrabajoPage extends StatelessWidget {
  const EditarTrabajoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EditarTrabajoController());

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Trabajo')),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  controller: controller.solucionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Solución',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Imágenes de Instalación:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                buildImageGrid(
                  campos: controller.camposInstalacion,
                  imagenes: controller.imagenesInstalacion,
                  onTapCampo: controller.seleccionarImagenInstalacion,
                ),

                if (controller.esSoporte) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Imágenes de Visita:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  buildImageGrid(
                    campos: controller.camposVisita,
                    imagenes: controller.imagenesVisita,
                    onTapCampo: controller.seleccionarImagenVisita,
                  ),
                ],

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        controller.isSaving.value
                            ? null
                            : controller.guardarSolucion,
                    icon: const Icon(Icons.save),
                    label:
                        controller.isSaving.value
                            ? const Text('Guardando...')
                            : const Text('GUARDAR'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildImageGrid({
    required List<String> campos,
    required Map<String, ImagenInstalacion> imagenes,
    required void Function(String campo) onTapCampo,
  }) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      children:
          campos.map((campo) {
            final imagen = imagenes[campo];

            return GestureDetector(
              onTap: () => onTapCampo(campo),
              child: Column(
                children: [
                  Text(
                    campo,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child:
                          imagen != null
                              ? Image.network(
                                imagen.url,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(Icons.add_a_photo_outlined),
                              )
                              : const Icon(
                                Icons.add_a_photo_outlined,
                                size: 40,
                                color: Colors.grey,
                              ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
