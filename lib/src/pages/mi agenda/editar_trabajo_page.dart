// lib/src/pages/mi%20agenda/editar_trabajo_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:redecom_app/src/models/trabajo.dart';
import 'package:redecom_app/src/pages/mi%20agenda/editar_trabajo_controller.dart';
import 'package:redecom_app/src/utils/date_helpers.dart';

class EditarTrabajoPage extends GetView<EditarTrabajoController> {
  const EditarTrabajoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Airbag por si alguien llega sin binding (útil en desarrollo)
    if (!Get.isRegistered<EditarTrabajoController>()) {
      Get.put(EditarTrabajoController());
    }

    final Trabajo t = Get.arguments as Trabajo;
    final esInstalacion = t.tipo.toUpperCase() == 'INSTALACION';

    return Scaffold(
      appBar: AppBar(title: Text('Editar ${t.tipo.toUpperCase()}')),
      body: Stack(
        children: [
          Obx(() {
            // Campos dinámicos (canónicos + los que vengan del backend)
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
                /*   _card(
                  title: 'Resumen del trabajo',
                  children: [
                    _kv('Tipo', t.tipo),
                    //_kv('Subtipo', t.subtipo),
                    //_kv('Fecha', t.fecha),
                    _kv('Fecha', Fmt.date(t.fecha)),
                    _kv('Hora', '${t.horaInicio} - ${t.horaFin}'),
                    _kv('Vehículo', t.vehiculo),
                    //_kv('Técnico', t.tecnico),
                    if ((t.observaciones).trim().isNotEmpty)
                      _kv('Observaciones', t.observaciones),
                  ],
                ),
                const SizedBox(height: 12),
                */
                // ---- GALERÍA INSTALACIÓN ----
                _card(
                  title: 'Imagenes Instalación',
                  // trailing: Text(
                  //  'ORD_INS: ${t.ordenInstalacion == 0 ? '—' : t.ordenInstalacion}',
                  //  style: const TextStyle(fontSize: 12, color: Colors.black54),
                  //),
                  children: [
                    if (t.ordenInstalacion == 0)
                      const Text('Este trabajo no tiene ORD_INS asignado.')
                    else
                      _gridCampos(
                        context: context,
                        campos: camposInst,
                        obtenerUrl:
                            (campo) =>
                                controller.imagenesInstalacion[campo]?.url,
                        onAddOrReplace:
                            (campo) =>
                                controller.seleccionarImagenInstalacion(campo),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // ---- GALERÍA VIS/LOS ----
                _card(
                  title: 'Imagenes Visita',
                  /*  trailing: Text(
                    esInstalacion
                        ? 'No aplica'
                        : (t.ageIdTipo == 0
                            ? 'Sin ID VIS/LOS'
                            : 'ID VIS/LOS: ${t.ageIdTipo}'),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),*/
                  children: [
                    if (esInstalacion)
                      const Text('Este trabajo es una instalación, no VIS/LOS.')
                    else
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
                _card(
                  title: 'Solución',
                  children: [
                    TextFormField(
                      controller: controller.solucionController,
                      minLines: 3,
                      maxLines: 6,
                      textCapitalization:
                          TextCapitalization.characters, // UX del teclado

                      decoration: const InputDecoration(
                        hintText: 'Describe la solución aplicada…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    /* const Text(
                      'Al guardar, el estado pasará a CONCLUIDO. '
                      'Si tomas/subes fotos, se incluirán datos de técnico/fecha/hora/ubicación sobre la imagen.',
                      style: TextStyle(fontSize: 12, color: Colors.black54),
                    ),*/
                  ],
                ),
                const SizedBox(height: 12),
                // ---- GUARDAR ----
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        controller.isSaving.value
                            ? null
                            : controller.guardarSolucion,
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),

          // Overlay de guardado
          Obx(() {
            if (!controller.isSaving.value) return const SizedBox.shrink();
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

  // ---------- Helpers UI locales ----------

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

  Widget _kv(String label, String? value) {
    final v = (value ?? '').trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(v.isEmpty ? '—' : v)),
        ],
      ),
    );
  }

  /// Grilla de campos con miniaturas (si hay) y botón para añadir/reemplazar.
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

        // Sanitize URL (evita /null /undefined y vacíos)
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
                        // Botón de acción (añadir / reemplazar)
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
