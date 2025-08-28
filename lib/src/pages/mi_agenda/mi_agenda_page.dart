import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:redecom_app/src/models/agenda.dart';
import 'package:redecom_app/src/pages/mi_agenda/mi_agenda_controller.dart';

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
            itemBuilder: (context, index) {
              final Agenda t = controller.trabajos[index];
              return _AgendaCard(item: t);
            },
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
    final tipoUpper = (item.tipo ?? '').trim().toUpperCase();
    final colorTipo = _colorPorTipo(tipoUpper);

    final fecha = _formatFecha(item.fecha);
    final horaIni = (item.horaInicio ?? '').trim();
    final horaFin = (item.horaFin ?? '').trim();
    final horario =
        (horaIni.isEmpty && horaFin.isEmpty) ? '—' : '$horaIni - $horaFin';

    final bool esHoy = _esHoy(item.fecha);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // mantiene tu routing original basado en TIPO
          switch (tipoUpper) {
            case 'LOS':
            case 'VISITA':
              Get.toNamed('/detalle-soporte', arguments: item);
              break;
            case 'INSTALACION':
              Get.toNamed('/detalle-instalacion', arguments: item);
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
              // ===== Recuadro de color con abreviatura del tipo (como tu original) =====
              _badgeTipo(tipoUpper, colorTipo),
              const SizedBox(width: 12),

              // ===== Contenido =====
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Primera fila: título + HOY + chevron
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            // muestra tipo + subtipo como en tu original
                            '${item.tipo ?? ''}  ${item.subtipo ?? ''}'.trim(),
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

                    // Segunda fila: fecha + horario
                    Row(
                      children: [
                        const Icon(Icons.event, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Text(fecha),
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

              // Vehículo a la derecha (como tu original)
              const SizedBox(width: 8),
              Text(
                (item.vehiculo ?? '').isNotEmpty ? item.vehiculo! : '-',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Recuadro de color con iniciales del TIPO (máx 3) =====
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
          color: _contrasteTexto(
            bg,
          ), // negro sobre amarillo, blanco sobre azul/verde
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ===== Helpers =====
  static Color _colorPorTipo(String tipoUpper) {
    switch (tipoUpper) {
      case 'INSTALACION':
        return const Color(0xFF28A745); // verde
      case 'VISITA':
        return const Color(0xFF007BFF); // azul
      case 'LOS':
        return const Color(0xFFFFE900); // amarillo
      default:
        return Colors.grey;
    }
  }

  static String _formatFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return '—';
    try {
      final d = DateTime.parse(fecha);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return fecha;
    }
  }

  static bool _esHoy(String? fecha) {
    if (fecha == null || fecha.isEmpty) return false;
    try {
      final d = DateTime.parse(fecha);
      final now = DateTime.now();
      return d.year == now.year && d.month == now.month && d.day == now.day;
    } catch (_) {
      return false;
    }
  }

  static Color _contrasteTexto(Color base) {
    final luminance = base.computeLuminance();
    return luminance > 0.6 ? Colors.black : Colors.white;
  }
}
