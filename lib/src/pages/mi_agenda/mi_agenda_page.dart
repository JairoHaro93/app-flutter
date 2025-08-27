import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:redecom_app/src/models/agenda.dart';
import 'package:redecom_app/src/pages/mi_agenda/mi_agenda_controller.dart';

class MiAgendaPage extends GetView<MiAgendaController> {
  const MiAgendaPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Usa Bindings en la ruta; no registres el controller aquí.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Agenda'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.offAllNamed('/home'),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
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
              final tipo = t.tipo.toUpperCase();

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: _badgeTipo(tipo),
                  title: Text('${t.tipo}  ${t.subtipo}'.trim()),
                  subtitle: Text(
                    '${_formatFecha(t.fecha)} | ${t.horaInicio} - ${t.horaFin}',
                  ),
                  trailing: Text(t.vehiculo.isNotEmpty ? t.vehiculo : '-'),
                  onTap: () {
                    switch (tipo) {
                      case 'LOS':
                      case 'VISITA':
                        Get.toNamed('/detalle-soporte', arguments: t);
                        break;
                      case 'INSTALACION':
                        Get.toNamed('/detalle-instalacion', arguments: t);
                        break;
                      default:
                        Get.snackbar(
                          'Tipo desconocido',
                          'No se reconoce el tipo de trabajo: ${t.tipo}',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.orange,
                          colorText: Colors.white,
                        );
                    }
                  },
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _badgeTipo(String tipo) {
    Color bg;
    switch (tipo) {
      case 'INSTALACION':
        bg = const Color(0xFF28A745);
        break;
      case 'VISITA':
        bg = const Color(0xFF007BFF);
        break;
      case 'LOS':
        bg = const Color(0xFFFFE900);
        break;
      default:
        bg = Colors.grey;
    }
    final visible =
        tipo.isEmpty ? '—' : tipo.substring(0, math.min(3, tipo.length));
    return Container(
      width: 44,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        visible,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  String _formatFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return '—';
    try {
      final d = DateTime.parse(fecha);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return fecha; // Si el parse falla, muestra el valor original
    }
  }
}
