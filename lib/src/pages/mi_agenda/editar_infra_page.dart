import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redecom_app/src/utils/date_helpers.dart';
import 'package:redecom_app/src/utils/maps_helpers.dart';

import 'editar_infra_controller.dart';

class EditarInfraestructuraPage
    extends GetView<EditarInfraestructuraController> {
  const EditarInfraestructuraPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = controller.trabajo;

    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${t.tipo.toUpperCase()}'),
        actions: [
          IconButton(
            tooltip: 'Recargar',
            icon: const Icon(Icons.refresh),
            onPressed: controller.recargar,
          ),
        ],
      ),

      floatingActionButton: Obx(() {
        final disabled =
            controller.isLoadingImgs.value || controller.isSaving.value;
        return FloatingActionButton.extended(
          onPressed: disabled ? null : controller.agregarEvidencia,
          icon: const Icon(Icons.add_a_photo),
          label: Text(disabled ? 'Cargando…' : 'Agregar evidencia'),
        );
      }),

      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () => controller.recargar(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _card(
                title: 'Trabajo',
                children: [
                  _kv('Nombre', t.tipo),
                  _kv('Fecha', Fmt.date(t.fecha)),
                  _kv('Hora', '${t.horaInicio} - ${t.horaFin}'),
                  _kv('Diagnóstico', t.diagnostico),
                  kvLinkCoords(
                    context: context,
                    label: 'Coordenadas',
                    value: t.coordenadas,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Referencias (solo lectura)
              _card(
                title: 'Referencias (no editables)',
                trailing:
                    controller.isLoadingImgs.value
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
                children: [
                  if (controller.referencias.isEmpty &&
                      !controller.isLoadingImgs.value)
                    const Text('Sin imágenes de referencia')
                  else
                    _gridReferencias(),
                ],
              ),
              const SizedBox(height: 12),

              // Evidencias (dinámicas)
              _card(
                title: 'Imagenes',
                trailing:
                    controller.isLoadingImgs.value
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
                children: [
                  if (controller.evidencias.isEmpty &&
                      !controller.isLoadingImgs.value)
                    const Text('Aún no hay evidencias.')
                  else
                    _gridEvidencias(),
                ],
              ),
              const SizedBox(height: 12),

              // Solución + Concluir
              _card(
                title: 'Solución',
                children: [
                  Obx(
                    () => TextField(
                      controller: controller.solucionCtrl,
                      onChanged:
                          controller
                              .onSolucionChanged, // <- necesario para reactividad
                      enabled:
                          !controller
                              .isSaving
                              .value, // <- opcional: bloquear mientras guarda
                      maxLines: 4,
                      minLines: 3,
                      textInputAction: TextInputAction.newline,
                      decoration: const InputDecoration(
                        hintText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final canConclude =
                        controller.puedeConcluir; // true si no está vacía
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed:
                            (canConclude && !controller.isSaving.value)
                                ? controller.concluir
                                : null,
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          controller.isSaving.value ? 'Guardando…' : 'Concluir',
                        ),
                      ),
                    );
                  }),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  // ---------- helpers UI ----------

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
    final v = (value == null || value.trim().isEmpty) ? '—' : value.trim();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
          Expanded(child: Text(v)),
        ],
      ),
    );
  }

  // --- grid de referencias (solo ver) ---
  Widget _gridReferencias() {
    final entries = controller.referencias.entries.toList();
    entries.sort(_sortByNumericSuffix); // ref_1, ref_2, ...

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (_, i) {
        final campo = entries[i].key;
        final url = entries[i].value.url.trim();
        final label = campo; // muestra "ref_1", "ref_2"

        return InkWell(
          onTap: url.isEmpty ? null : () => _verImagen(url, label),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Text(
                  label,
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
                    child: _tileImage(url, showEditPill: false),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- grid de evidencias (dinámico: reemplazar) ---
  Widget _gridEvidencias() {
    final entries = controller.evidencias.entries.toList();
    entries.sort(_sortByNumericSuffix); // infra_1, infra_2, ...

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (_, i) {
        final campo = entries[i].key;
        final url = entries[i].value.url.trim();
        final label = campo; // muestra "infra_1", etc.

        return InkWell(
          onTap: url.isEmpty ? null : () => _verImagen(url, label),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black12),
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(6),
            child: Column(
              children: [
                Text(
                  label,
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
                        _tileImage(url, showEditPill: false),
                        Positioned(
                          right: 4,
                          bottom: 4,
                          child: Material(
                            color: Colors.black.withOpacity(0.35),
                            shape: const CircleBorder(),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                              tooltip: 'Reemplazar foto',
                              onPressed: () => controller.onTapSlot(campo),
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

  // --- imagen de celda con placeholders / loading ---
  Widget _tileImage(String url, {bool showEditPill = false}) {
    if (url.isEmpty) {
      return Container(
        color: Colors.black12,
        child: const Center(child: Icon(Icons.image, color: Colors.black45)),
      );
    }
    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder:
          (_, __, ___) => Container(
            color: Colors.black12,
            child: const Center(
              child: Icon(Icons.broken_image, color: Colors.black45),
            ),
          ),
      loadingBuilder: (c, w, p) {
        if (p == null) return w;
        return const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  // --- orden por sufijo numérico ---
  int _sortByNumericSuffix(
    MapEntry<String, dynamic> a,
    MapEntry<String, dynamic> b,
  ) {
    int numOf(String k) {
      final m = RegExp(r'_(\d+)$').firstMatch(k.toLowerCase());
      return m == null ? 9999 : int.tryParse(m.group(1)!) ?? 9999;
    }

    final na = numOf(a.key);
    final nb = numOf(b.key);
    return na.compareTo(nb);
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
