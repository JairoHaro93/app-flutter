// lib/src/pages/mi_agenda/mi_agenda_page.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:redecom_app/src/models/agenda.dart';
import 'package:redecom_app/src/pages/mi_agenda/mi_agenda_controller.dart';
import 'package:redecom_app/src/utils/date_helpers.dart';

class MiAgendaPage extends GetView<MiAgendaController> {
  const MiAgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Agenda'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed('/home'),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.trabajos.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.trabajos.isEmpty) {
          return const Center(child: Text('No hay trabajos agendados'));
        }

        return RefreshIndicator(
          onRefresh: controller.cargarAgenda,
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.trabajos.length,
            itemBuilder: (_, i) => _AgendaCard(item: controller.trabajos[i]),
          ),
        );
      }),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  final Agenda item;
  const _AgendaCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final tipoUpper = (item.tipo).trim().toUpperCase();
    final colorTipo = _colorPorTipo(tipoUpper);

    // Fechas/horario usando Fmt (tu helper)
    final fechaStr = Fmt.date(item.fecha); // dd/MM/yyyy
    final horario = _horario(item.horaInicio, item.horaFin);

    // Badge HOY comparando cadenas formateadas (sin tocar Fmt._parse)
    final hoyStr = Fmt.date(DateTime.now().toIso8601String());
    final esHoy = fechaStr == hoyStr;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          switch (tipoUpper) {
            case 'LOS':
            case 'TRASLADO EXT':
            case 'VISITA':
            case 'RETIRO':
            case 'MIGRACION':
              Get.toNamed('/detalle-soporte', arguments: item);
              break;
            case 'INSTALACION':
              Get.toNamed('/detalle-instalacion', arguments: item);
              break;
            case 'INFRAESTRUCTURA':
              Get.toNamed('/editar-infra', arguments: item);
              break;
            default:
              Get.snackbar(
                'Tipo desconocido',
                'No se reconoce el tipo de trabajo: ${item.tipo}',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.orange,
                colorText: Colors.white,
              );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _badgeTipo(
                tipoUpper,
                colorTipo,
              ), // recuadro de color con abreviatura
              const SizedBox(width: 12),

              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título + HOY + chevron
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ' ${item.tipo}'.trim(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (esHoy)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'HOY',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        const SizedBox(width: 6),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Fecha + Horario
                    Row(
                      children: [
                        const Icon(Icons.event, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(fechaStr),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(horario),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              Text(
                (item.vehiculo).isNotEmpty ? item.vehiculo : '-',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Recuadro de color con abreviatura (máx 3 letras)
  Widget _badgeTipo(String tipoUpper, Color bg) {
    final abbr =
        tipoUpper.isEmpty
            ? '—'
            : tipoUpper.substring(0, math.min(3, tipoUpper.length));
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        abbr,
        style: TextStyle(
          color: _contrasteTexto(bg), // blanco/negro según color de fondo
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helpers UI

  static String _horario(String? ini, String? fin) {
    final h1 = (ini ?? '').trim();
    final h2 = (fin ?? '').trim();
    if (h1.isEmpty && h2.isEmpty) return '—';
    if (h1.isNotEmpty && h2.isNotEmpty) return '$h1 - $h2';
    return h1.isNotEmpty ? h1 : h2;
  }

  static Color _colorPorTipo(String tipoUpper) {
    switch (tipoUpper) {
      case 'INSTALACION':
        return const Color(0xFF28A745); // verde
      case 'VISITA':
        return const Color(0xFF007BFF); // azul
      case 'LOS':
        return const Color(0xFFFFE900); // amarillo
      case 'TRASLADO EXT':
        return const Color.fromRGBO(228, 30, 178, 1);
      case 'MIGRACION':
        return const Color.fromRGBO(113, 17, 192, 1);
      case 'RETIRO':
        return const Color.fromRGBO(220, 53, 69, 1);
      default:
        return Colors.grey;
    }
  }

  static Color _contrasteTexto(Color base) {
    final luminance = base.computeLuminance();
    return luminance > 0.6 ? Colors.black : Colors.white;
  }
}
