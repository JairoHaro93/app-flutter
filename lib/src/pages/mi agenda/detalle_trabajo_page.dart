import 'package:flutter/material.dart';
import 'package:redecom_app/src/models/trabajo.dart';

class DetalleTrabajoPage extends StatelessWidget {
  final Trabajo trabajo;

  const DetalleTrabajoPage({super.key, required this.trabajo});

  String formatFecha(String rawFecha) {
    final date = DateTime.tryParse(rawFecha);
    if (date == null) return rawFecha;
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Trabajo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(title: const Text('ID:'), subtitle: Text('${trabajo.id}')),
            ListTile(title: const Text('Tipo:'), subtitle: Text(trabajo.tipo)),
            ListTile(
              title: const Text('Subtipo:'),
              subtitle: Text(trabajo.subtipo),
            ),
            ListTile(
              title: const Text('Estado:'),
              subtitle: Text(trabajo.estado),
            ),
            ListTile(
              title: const Text('Orden instalación:'),
              subtitle: Text(trabajo.ordenInstalacion),
            ),
            ListTile(
              title: const Text('Soporte ID:'),
              subtitle: Text(trabajo.soporteId),
            ),
            ListTile(
              title: const Text('Fecha y Hora:'),
              subtitle: Text(
                '${formatFecha(trabajo.fecha)} de ${trabajo.horaInicio} a ${trabajo.horaFin}',
              ),
            ),
            ListTile(
              title: const Text('Vehículo:'),
              subtitle: Text(trabajo.vehiculo),
            ),
            ListTile(
              title: const Text('Técnico:'),
              subtitle: Text(trabajo.tecnico),
            ),
            ListTile(
              title: const Text('Teléfono:'),
              subtitle: Text(trabajo.telefono),
            ),
            ListTile(
              title: const Text('Coordenadas:'),
              subtitle: Text(trabajo.coordenadas),
            ),
            ListTile(
              title: const Text('Observaciones:'),
              subtitle: Text(trabajo.observaciones),
            ),
            ListTile(
              title: const Text('Solución:'),
              subtitle: Text(trabajo.solucion ?? 'Sin registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
