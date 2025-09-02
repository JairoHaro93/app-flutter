// lib/src/pages/mi_agenda/editar_trabajo_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:redecom_app/main.dart';

import 'package:redecom_app/src/pages/mi_agenda/editar_trabajo_controller.dart';

class EditarTrabajoPage extends GetView<EditarTrabajoController> {
  const EditarTrabajoPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<EditarTrabajoController>()) {
      Get.put(EditarTrabajoController());
    }

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          final t = controller.trabajo.value;
          final tipo = (t?.tipo ?? 'Agenda').toUpperCase();
          return Text('Editar $tipo');
        }),
      ),
      body: Stack(
        children: [
          Obx(() {
            final t = controller.trabajo.value;
            if (t == null) {
              return const Center(child: CircularProgressIndicator());
            }

            final camposInst = [
              ...controller.camposInstalacion,
              ...controller.imagenesInstalacion.keys.where(
                (k) => !controller.camposInstalacion.contains(k),
              ),
            ];
            final camposVis = [
              ...controller.camposVisita,
              ...controller.imagenesVisita.keys.where(
                (k) => !controller.camposVisita.contains(k),
              ),
            ];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ---- GALERÍA INSTALACIÓN ----
                if (t.tipo == "INSTALACION" ||
                    t.tipo == "TRASLADO EXT" ||
                    t.tipo == "VISITA" ||
                    t.tipo == "MIGRACION")
                  _card(
                    title: 'Imágenes Instalación',
                    children: [
                      if (t.ordIns == 0)
                        const Text('Este trabajo no tiene ORD_INS asignado.')
                      else
                        _gridCampos(
                          context: context,
                          campos: camposInst,
                          obtenerUrl:
                              (campo) =>
                                  controller.imagenesInstalacion[campo]?.url,
                          onAddOrReplace:
                              (campo) => controller
                                  .seleccionarImagenInstalacion(campo),
                        ),
                    ],
                  ),
                const SizedBox(height: 12),

                // ---- GALERÍA VIS/LOS ----
                if (t.tipo == "LOS" || t.tipo == "VISITA" || t.tipo == "RETIRO")
                  _card(
                    title: 'Imágenes Visita',
                    children: [
                      // const Text('Este trabajo es una instalación, no VIS/LOS.')
                      _gridCampos(
                        context: context,
                        campos: camposVis,
                        obtenerUrl:
                            (campo) => controller.imagenesVisita[campo]?.url,
                        onAddOrReplace:
                            (campo) =>
                                controller.seleccionarImagenVisita(campo),
                      ),
                    ],
                  ),
                const SizedBox(height: 24),

                // ---- SOLUCIÓN ----
                //if (t.tipo == "INSTALACION" || t.tipo == "TRASLADO EXT" || t.tipo == "RETIRO")
                _card(
                  title: 'Solución',
                  children: [
                    TextFormField(
                      controller: controller.solucionController,
                      minLines: 3,
                      maxLines: 6,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'OBSERVACION',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ---- CAMPOS EXTRAS SOLO PARA INSTALACIÓN ----
                if (t.tipo == "INSTALACION" ||
                    t.tipo == "TRASLADO EXT" ||
                    t.tipo == "MIGRACION")
                  _card(
                    title: 'Finalizar instalación',
                    children: [
                      TextFormField(
                        controller: controller.coordCtrl,
                        decoration: InputDecoration(
                          labelText: 'Coordenadas confirmadas',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: 'Elegir en mapa',
                            onPressed: () async {
                              final result = await Get.toNamed(
                                Routes.mapSelect,
                              );
                              if (result is LatLng) {
                                controller.coordCtrl.text =
                                    '${result.latitude.toStringAsFixed(6)},${result.longitude.toStringAsFixed(6)}';
                              }
                            },
                            icon: const Icon(Icons.map),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: controller.ipCtrl,
                        keyboardType: TextInputType.visiblePassword,
                        decoration: const InputDecoration(
                          labelText: 'IP del servicio',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),

                // ---- ÚNICO BOTÓN GUARDAR ----
                Obx(() {
                  final busy =
                      controller.isSaving.value ||
                      controller.isTerminating.value;
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: busy ? null : controller.guardarTodo,
                      icon: const Icon(Icons.save),
                      label: Text(busy ? 'GUARDANDO…' : 'GUARDAR'),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            );
          }),

          // Overlay (cuando guarda)
          Obx(() {
            final show =
                controller.isSaving.value || controller.isTerminating.value;
            if (!show) return const SizedBox.shrink();
            return Container(
              color: Colors.black.withOpacity(0.2),
              child: const Center(
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------- Helpers UI ----------
  Widget _card({
    required String title,
    List<Widget> children = const [],
    Widget? trailing,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle.merge(
          style: const TextStyle(fontSize: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (trailing != null) trailing,
                ],
              ),
              const SizedBox(height: 10),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _gridCampos({
    required BuildContext context,
    required List<String> campos,
    required String? Function(String campo) obtenerUrl,
    required Future<void> Function(String campo) onAddOrReplace,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: campos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (_, i) {
        final campo = campos[i];
        final raw = (obtenerUrl(campo) ?? '').trim();
        final isBad =
            raw.isEmpty || raw.endsWith('/null') || raw.contains('/undefined');
        final url = isBad ? '' : raw;

        return InkWell(
          onTap: url.isEmpty ? null : () => _verImagen(url, campo),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Text(
                  campo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (url.isEmpty)
                          Container(
                            color: Colors.black12,
                            child: const Center(
                              child: Icon(Icons.image, color: Colors.black45),
                            ),
                          )
                        else
                          Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  color: Colors.black12,
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      color: Colors.black45,
                                    ),
                                  ),
                                ),
                            loadingBuilder: (c, w, p) {
                              if (p == null) return w;
                              return const Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                          ),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Material(
                            color: Colors.black.withOpacity(0.35),
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: Icon(
                                url.isEmpty ? Icons.add_a_photo : Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                              tooltip:
                                  url.isEmpty
                                      ? 'Añadir foto'
                                      : 'Reemplazar foto',
                              onPressed: () => onAddOrReplace(campo),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _verImagen(String url, String titulo) {
    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 12,
                right: 12,
                bottom: 6,
              ),
              child: Text(
                titulo,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            AspectRatio(
              aspectRatio: 1,
              child: InteractiveViewer(
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  loadingBuilder:
                      (c, w, p) =>
                          p == null
                              ? w
                              : const Center(
                                child: CircularProgressIndicator(),
                              ),
                  errorBuilder:
                      (_, __, ___) => const Center(
                        child: Text('No se pudo cargar la imagen'),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: Get.back, child: const Text('Cerrar')),
          ],
        ),
      ),
    );
  }
}
