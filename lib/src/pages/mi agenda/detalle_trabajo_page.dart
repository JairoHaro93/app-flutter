import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redecom_app/src/pages/mi%20agenda/detalle_trabajo_controller.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:redecom_app/src/models/trabajo.dart';
import 'package:redecom_app/src/pages/mi%20agenda/editar_trabajo_page.dart';

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
      appBar: AppBar(title: const Text('Detalle del Trabajo')),
      body: Obx(() {
        if (controller.trabajoDetalle.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final detalle = controller.trabajoDetalle.value!;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    _info('ID', '${detalle.id}'),
                    _info('Cliente', detalle.clienteNombre),
                    _info('Teléfono', detalle.telefono),
                    _info('Registrado por', detalle.registradoPorNombre),
                    _info('Estado', detalle.estado),
                    _info(
                      'Fecha de Registro',
                      formatFecha(detalle.fechaRegistro),
                    ),
                    _info(
                      'Fecha de Aceptación',
                      formatFecha(detalle.fechaAcepta),
                    ),
                    _info('Observaciones', detalle.observaciones),
                    _info('Solución', detalle.solucionDetalle),
                    ListTile(
                      title: const Text('Coordenadas del trabajo:'),
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
                    controller.verDetalle(widget.trabajo); // recarga
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

  Widget _info(String label, String value) {
    return ListTile(title: Text('$label:'), subtitle: Text(value));
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
}
