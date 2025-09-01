import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'detalle_soporte_controller.dart';
import 'package:redecom_app/src/models/agenda.dart';
import 'package:redecom_app/src/models/imagen_instalacion.dart';
import 'package:redecom_app/src/utils/maps_helpers.dart';
import 'package:redecom_app/src/utils/date_helpers.dart';

class DetalleSoportePage extends GetView<DetalleSoporteController> {
  const DetalleSoportePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ⚠️ No registres el controller aquí: el Binding ya lo provee
    final Agenda t = controller.agenda;

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle ${t.tipo.toUpperCase()}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final ok = await Get.toNamed('/editar-trabajo', arguments: t);
              if (ok == true) await controller.cargarTodo(force: true);
            },
          ),
        ],
      ),

      body: Obx(() {
        return RefreshIndicator(
          onRefresh: () => controller.cargarTodo(force: true),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _card(
                title: 'Agenda',
                children: [
                  _kv('Tipo', t.tipo),
                  _kv('Fecha', Fmt.date(t.fecha)),
                  _kv('Hora', '${t.horaInicio} - ${t.horaFin}'),
                  _kv('Vehículo', t.vehiculo),
                  if (t.tipo == "LOS" || t.tipo == "VISITA")
                    _kv(
                      'Comentario cliente',
                      controller.soporteComentario.value,
                    ),
                  _kv('Diagnóstico', t.diagnostico),
                  if (t.tipo == "TRASLADO EXT")
                    kvLinkCoords(
                      context: context,
                      label: 'Coordenadas Ref',
                      value: t.coordenadas,
                    ),
                  //
                ],
              ),
              const SizedBox(height: 12),

              _card(
                title: 'Servicio',
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
                  _kv('Estado de Pago', controller.clienteEstado.value),
                  _kv('IP', controller.clienteIp.value),
                  _kv('Servicio', controller.clienteServicio.value),
                  _kv('Cortado', controller.clienteCortado.value),
                  _kv(
                    'Fecha instalación',
                    Fmt.date(controller.clienteFechaInstalacion.value),
                  ),
                  kvLinkCoords(
                    context: context,
                    label: 'Coordenadas',
                    value: controller.clienteCoordenadas.value,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ======= GALERÍA VIS/LOS =======
              _card(
                title: 'Visita',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.isLoadingImgsVis.value)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    IconButton(
                      onPressed: controller.recargarImagenesVis,
                      tooltip: 'Recargar imágenes VIS/LOS',
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                children: [
                  if (t.idTipo == 0) ...[
                    const Text('Sin ID de VIS/LOS (idTipo = 0)'),
                  ] else if (controller.imagenesVis.isEmpty &&
                      !controller.isLoadingImgsVis.value) ...[
                    const Text('Sin imágenes registradas'),
                  ] else ...[
                    _gridImagenes(controller.imagenesVis.entries.toList()),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // ======= GALERÍA INSTALACIÓN =======
              _card(
                title: 'Instalación',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.isLoadingImgsInst.value)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    IconButton(
                      onPressed: controller.recargarImagenesInst,
                      tooltip: 'Recargar imágenes de instalación',
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                children: [
                  if (t.ordIns == 0) ...[
                    const Text('Sin ORD_INS'),
                  ] else if (controller.imagenesInstalacion.isEmpty &&
                      !controller.isLoadingImgsInst.value) ...[
                    const Text('Sin imágenes registradas'),
                  ] else ...[
                    _gridImagenes(
                      controller.imagenesInstalacion.entries.toList(),
                    ),
                  ],
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

  Widget _gridImagenes(List<MapEntry<String, ImagenInstalacion>> entries) {
    // Orden sugerido común
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
      'evidencia_1',
      'evidencia_2',
      'evidencia_3',
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
        final url = img.url.trim();

        if (url.isEmpty) return _imgPlaceholder(campo);

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
}
