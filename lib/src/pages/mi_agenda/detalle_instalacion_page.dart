// lib/src/pages/mi_agenda/detalle_instalacion_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'detalle_instalacion_controller.dart';
import 'package:redecom_app/src/utils/phone_helper.dart';
import 'package:redecom_app/src/utils/date_helpers.dart';
import 'package:redecom_app/src/utils/maps_helpers.dart';

class DetalleInstalacionPage extends GetView<DetalleInstalacionController> {
  const DetalleInstalacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle Instalación'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Editar',
            onPressed: () async {
              final ok = await Get.toNamed(
                '/editar-trabajo',
                arguments: controller.trabajo,
              );
              if (ok == true) {
                await controller.cargarInstalacionYCliente(force: true);
              }
            },
          ),
        ],
      ),

      body: Obx(() {
        final inst = controller.instalacion.value;
        final t = controller.trabajo;

        if (controller.isLoadingInst.value && inst == null) {
          return const Center(child: CircularProgressIndicator());
        }
        if (inst == null) {
          return const Center(child: Text('No se pudo cargar la instalación'));
        }

        return RefreshIndicator(
          onRefresh: () => controller.cargarInstalacionYCliente(force: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ======= DATOS INSTALACIÓN =======
              _card(
                title: 'Datos Instalación',
                trailing: Obx(
                  () =>
                      controller.isLoadingInst.value
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const SizedBox.shrink(),
                ),
                children: [
                  _kvW('Teléfonos', telefonosTappable(inst.instTelefonos)),
                  _kv('Fecha', Fmt.date(t.fecha)),
                  _kv('Hora', '${t.horaInicio} - ${t.horaFin}'),
                  _kv('Vehículo', t.vehiculo),
                  _kv('Observación', inst.instObservacion ?? '—'),
                  kvLinkCoords(
                    context: context,
                    label: 'Coordenadas Ref',
                    value: inst.instCoordenadas,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ======= DATOS CLIENTE =======
              _card(
                title: 'Datos Cliente',
                trailing: Obx(
                  () =>
                      controller.isLoadingCliente.value
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const SizedBox.shrink(),
                ),
                children: [
                  _kv('Cédula', controller.clienteCedula.value),
                  _kv('Nombre', controller.clienteNombre.value),
                  _kv('Dirección', controller.clienteDireccion.value),
                  _kv('Referencia', controller.clienteReferencia.value),
                  _kv('Teléfonos', controller.clienteTelefonos.value),
                  _kv('Plan', controller.clientePlan.value),
                  _kv('Servicio', controller.clienteServicio.value),
                ],
              ),

              const SizedBox(height: 12),

              // ======= GALERÍA =======
              _card(
                title: 'Galería de imágenes',
                trailing: Obx(
                  () =>
                      controller.isLoadingImgs.value
                          ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : IconButton(
                            icon: const Icon(Icons.refresh),
                            tooltip: 'Recargar imágenes',
                            onPressed:
                                () => controller.cargarImagenesInstalacion(
                                  force: true,
                                ),
                          ),
                ),
                children: [
                  if (controller.imagenesInstalacion.isEmpty &&
                      !controller.isLoadingImgs.value)
                    const Text('Sin imágenes registradas')
                  else
                    _gridImagenes(),
                ],
              ),
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  /// Par "clave: valor" donde el valor es un **String?**
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

  /// Par "clave: valor" donde el valor es un **Widget** (por ejemplo chips, enlaces, etc.)
  Widget _kvW(String label, Widget child) {
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
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _gridImagenes() {
    final entries = controller.imagenesInstalacion.entries.toList();

    const orden = [
      'fachada',
      'router',
      'ont',
      'potencia',
      'speedtest',
      'cable_1',
      'cable_2',
      'equipo_1',
      'equipo_2',
      'equipo_3',
    ];
    entries.sort((a, b) {
      final ia = orden.indexOf(a.key);
      final ib = orden.indexOf(b.key);
      final va = ia == -1 ? 999 : ia;
      final vb = ib == -1 ? 999 : ib;
      return va.compareTo(vb);
    });

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (_, idx) {
        final campo = entries[idx].key;
        final img = entries[idx].value;
        final url = img.url.trim(); // <- url no-nullable

        if (url.isEmpty) {
          return _imgPlaceholder(campo);
        }

        return InkWell(
          onTap: () => _verImagen(url, campo),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  url,
                  fit: BoxFit.cover,
                  loadingBuilder:
                      (c, w, p) =>
                          p == null
                              ? w
                              : const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                  errorBuilder: (_, __, ___) => _imgPlaceholder(campo),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Colors.black54,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    child: Text(
                      campo,
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                      overflow: TextOverflow.ellipsis,
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

  Widget _imgPlaceholder(String campo) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: Colors.black12,
        child: Center(
          child: Text(
            campo,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ),
      ),
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
              padding: const EdgeInsets.all(8.0),
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

  // ---------- Teléfonos “tappeables” ----------
  Widget telefonosTappable(String? telefonosCsv) {
    final nums = PhoneHelper.parsePhones(
      telefonosCsv,
    ); // ✅ usa el parser correcto

    if (nums.isEmpty) return const Text('—');

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children:
          nums.map((n) {
            return InkWell(
              onTap: () => PhoneHelper.llamar(n),
              onLongPress: () => Clipboard.setData(ClipboardData(text: n)),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone, size: 16),
                    const SizedBox(width: 6),
                    Text(n),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
