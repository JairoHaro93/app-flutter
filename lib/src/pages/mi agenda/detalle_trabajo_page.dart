import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:redecom_app/src/models/trabajo.dart';
import 'package:redecom_app/src/pages/mi%20agenda/editar_trabajo_page.dart';
import 'package:redecom_app/src/pages/mi%20agenda/detalle_trabajo_controller.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';

class DetalleTrabajoPage extends StatefulWidget {
  final Trabajo trabajo;

  const DetalleTrabajoPage({super.key, required this.trabajo});

  @override
  State<DetalleTrabajoPage> createState() => _DetalleTrabajoPageState();
}

class _DetalleTrabajoPageState extends State<DetalleTrabajoPage> {
  late final DetalleTrabajoController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(DetalleTrabajoController());
    controller.verDetalle(widget.trabajo);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Trabajo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed('/tecnico/mi-agenda'),
        ),
      ),
      body: Obx(() {
        if (controller.trabajoDetalle.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final detalle = controller.trabajoDetalle.value!;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _sectionHeader('Información General'),

                    _info(Icons.person, 'Cliente', detalle.clienteNombre),
                    _info(Icons.phone, 'Teléfono', detalle.telefono),
                    _info(Icons.info, 'Estado', detalle.estado),

                    const Divider(),

                    _sectionHeader('Observaciones y Diagnóstico'),
                    _info(
                      Icons.comment,
                      'Observaciones',
                      detalle.observaciones,
                    ),
                    _info(
                      Icons.check_circle,
                      'Diagnóstico',
                      detalle.solucionDetalle.isNotEmpty
                          ? detalle.solucionDetalle
                          : 'Sin Diagnóstoico',
                    ),

                    const Divider(),
                    _sectionHeader('Ubicación'),
                    ListTile(
                      leading: const Icon(Icons.map),
                      title: const Text('Coordenadas del trabajo'),
                      subtitle: GestureDetector(
                        onTap:
                            () =>
                                _abrirEnGoogleMaps(widget.trabajo.coordenadas),
                        child: Text(
                          widget.trabajo.coordenadas,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                    if (controller.imagenesInstalacion.isNotEmpty) ...[
                      const Divider(),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'Imágenes de Instalación',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        children:
                            controller.imagenesInstalacion.entries.map((entry) {
                              final campo = entry.key;
                              final imagen = entry.value;

                              return GestureDetector(
                                onTap: () => _verImagenModal(imagen.url),
                                child: Column(
                                  children: [
                                    Text(
                                      campo,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imagen.url,
                                        height: 120,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, _, __) =>
                                                const Icon(Icons.broken_image),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ],
                  ],
                ),
              ),

              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Get.to(
                    () => const EditarTrabajoPage(),
                    arguments: widget.trabajo,
                  );
                  if (result == true) {
                    controller.verDetalle(widget.trabajo);
                    SnackbarService.success(
                      '✅ Trabajo actualizado correctamente',
                    );
                  }
                },
                icon: const Icon(Icons.edit),
                label: const Text('EDITAR'),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _info(IconData icon, String label, String value) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  String formatFecha(String rawFecha) {
    final date = DateTime.tryParse(rawFecha);
    if (date == null) return rawFecha;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _abrirEnGoogleMaps(String coordenadas) async {
    final parts = coordenadas.split(',');
    if (parts.length >= 2) {
      final lat = parts[0].trim();
      final lng = parts[1].trim();
      final uri = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        final webUri = Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
        );
        if (await canLaunchUrl(webUri)) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } else {
          SnackbarService.error('No se pudo abrir Google Maps');
        }
      }
    } else {
      SnackbarService.error('Coordenadas no válidas');
    }
  }

  void _verImagenModal(String url) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            insetPadding: const EdgeInsets.all(10),
            child: InteractiveViewer(child: Image.network(url)),
          ),
    );
  }
}
