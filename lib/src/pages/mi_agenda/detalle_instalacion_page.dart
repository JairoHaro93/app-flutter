import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'detalle_instalacion_controller.dart';

class DetalleInstalacionPage extends GetView<DetalleInstalacionController> {
  const DetalleInstalacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Instalación')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.edit),
        label: const Text('Editar'),
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
      body: Obx(() {
        final inst = controller.instalacionMysql.value;

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
              _card(
                title: 'Instalación (MySQL)',
                trailing:
                    controller.isLoadingInst.value
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
                children: [
                  _kv('ORD_INS', inst.ordIns),
                  _kv('Teléfonos', inst.instTelefonos),
                  _kv('Coordenadas', inst.instCoordenadas),
                  _kv('Observación', inst.instObservacion),
                ],
              ),
              const SizedBox(height: 12),

              _card(
                title: 'Cliente (SQL Server)',
                trailing:
                    controller.isLoadingCliente.value
                        ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : null,
                children: [
                  _kv('Cédula', controller.clienteCedula.value),
                  _kv('Nombre', controller.clienteNombre.value),
                  _kv('Dirección', controller.clienteDireccion.value),
                  _kv('Referencia', controller.clienteReferencia.value),
                  _kv('Teléfonos', controller.clienteTelefonos.value),
                  _kv('Plan', controller.clientePlan.value),
                  _kv('Estado', controller.clienteEstado.value),
                  _kv('Instalado por', controller.clienteInstaladoPor.value),
                  _kv('IP', controller.clienteIp.value),
                  _kv('Servicio', controller.clienteServicio.value),
                  _kv(
                    'Tipo instalación',
                    controller.clienteTipoInstalacion.value,
                  ),
                  _kv(
                    'Estado instalación',
                    controller.clienteEstadoInstalacion.value,
                  ),
                  _kv('Cortado', controller.clienteCortado.value),
                  _kv(
                    'Fecha instalación',
                    _fmtDateTime(controller.clienteFechaInstalacion.value),
                  ),
                  _kv('Coordenadas', controller.clienteCoordenadas.value),
                ],
              ),
              const SizedBox(height: 12),

              // ======= GALERÍA =======
              _card(
                title: 'Galería de imágenes',
                trailing:
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

  Widget _gridImagenes() {
    final entries = controller.imagenesInstalacion.entries.toList();

    // (opcional) orden sugerido
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
        final url = (img.url ?? '').trim();
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
                  loadingBuilder: (c, w, p) {
                    if (p == null) return w;
                    return const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    );
                  },
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
                  loadingBuilder: (c, w, p) {
                    if (p == null) return w;
                    return const Center(child: CircularProgressIndicator());
                  },
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

  String _fmtDateTime(DateTime? dt) {
    if (dt == null) return '—';
    final dd = dt.day.toString().padLeft(2, '0');
    final mm = dt.month.toString().padLeft(2, '0');
    final yyyy = dt.year.toString();
    final hh = dt.hour.toString().padLeft(2, '0');
    final nn = dt.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yyyy $hh:$nn';
  }
}
