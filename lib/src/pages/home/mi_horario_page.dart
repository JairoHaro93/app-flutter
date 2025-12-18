import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:redecom_app/src/pages/home/mi_horario_controller.dart';
import 'package:redecom_app/src/models/dia_horario_semana.dart';

class MiHorarioPage extends GetView<MiHorarioController> {
  const MiHorarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dfRange = DateFormat('dd/MM/yyyy', 'es_EC');
    final dfDay = DateFormat('EEEE dd/MM', 'es_EC');

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Horario')),
      body: SafeArea(
        child: Obx(() {
          return Column(
            children: [
              _headerSemana(context, dfRange),
              if (controller.cargando.value) const LinearProgressIndicator(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh:
                      () => controller.cargarSemanaPorFecha(
                        controller.desde.value,
                      ),
                  child: ListView(
                    padding: const EdgeInsets.all(12),
                    children: [_listaSemana(context, dfDay)],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // =========================
  //   HEADER SEMANA
  // =========================
  Widget _headerSemana(BuildContext context, DateFormat dfRange) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            IconButton(
              onPressed: controller.prevWeek,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Semana anterior',
            ),
            Expanded(
              child: Column(
                children: [
                  const Text(
                    'Semana (Lun - Dom)',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _rangeBox(
                          'Desde',
                          dfRange.format(controller.desde.value),
                        ),
                        const Text('→', style: TextStyle(fontSize: 18)),
                        _rangeBox(
                          'Hasta',
                          dfRange.format(controller.hasta.value),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            IconButton(
              onPressed: controller.nextWeek,
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Semana siguiente',
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Elegir semana',
              icon: const Icon(Icons.calendar_month),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: controller.desde.value,
                  firstDate: DateTime(2024, 1, 1),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  helpText: 'Elige un día (se carga su semana Lun-Dom)',
                );
                if (picked != null) {
                  await controller.cargarSemanaPorFecha(picked);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _rangeBox(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  // =========================
  //   LISTA SEMANA
  // =========================
  Widget _listaSemana(BuildContext context, DateFormat dfDay) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Obx(() {
          final items = controller.dias;

          if (items.isEmpty) {
            return const Text('Sin datos para esta semana.');
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lunes a Domingo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...items.map((d) {
                final isPast = controller.isPastDay(d.fecha);
                final isToday = controller.isToday(d.fecha);

                // ✅ IMPORTANTE: ya NO hacemos “parches” aquí.
                // El estado UI oficial sale SOLO del controller.estadoUI(d)
                final estado = controller.estadoUI(d);

                final subtitleBase =
                    d.tieneTurno
                        ? 'Prog: ${d.horaEntradaProg ?? '-'} - ${d.horaSalidaProg ?? '-'}'
                        : 'Sin turno';

                final obs = (d.observacion ?? '').trim();

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(width: 10),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _capitalize(dfDay.format(d.fecha)),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(subtitleBase),

                              if (obs.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Obs: $obs',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        _trailingEnColumnas(
                          context,
                          d,
                          isPast,
                          isToday,
                          estado,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        }),
      ),
    );
  }

  // =========================
  //   TRAILING EN COLUMNAS
  // =========================
  Widget _trailingEnColumnas(
    BuildContext context,
    DiaHorarioSemana d,
    bool isPast,
    bool isToday,
    String estadoUI,
  ) {
    final chipAsistencia = _chipFor(
      tieneTurno: d.tieneTurno,
      isPast: isPast,
      isToday: isToday,
      estadoUI: estadoUI,
    );

    final chipHoraAcum = _chipHoraAcumulada(d);
    final stHA = d.estadoHoraAcumulada.toString().trim().toUpperCase();

    // ✅ Si está APROBADO, NO se puede editar ni mostrar botón
    final mostrarBotonObs = isToday && d.tieneTurno && stHA != 'APROBADO';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        chipAsistencia,
        if (chipHoraAcum != null) ...[const SizedBox(height: 6), chipHoraAcum],
        if (mostrarBotonObs) ...[
          const SizedBox(height: 4),
          IconButton(
            onPressed: () => _dialogObservacion(context, d),
            tooltip: 'Observación',
            icon: const Icon(Icons.edit_note, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }

  // =========================
  //   CHIPS / ESTADOS
  // =========================
  Widget _chipFor({
    required bool tieneTurno,
    required bool isPast,
    required bool isToday,
    required String estadoUI,
  }) {
    if (!tieneTurno) return _chip('SIN TURNO', Colors.grey);

    // ✅ Estados especiales por tipo_dia (pisan todo)
    if (estadoUI == 'DEVOLUCIÓN') return _chip('DEVOLUCIÓN', Colors.purple);
    if (estadoUI == 'VACACIONES') return _chip('VACACIONES', Colors.indigo);
    if (estadoUI == 'PERMISO') return _chip('PERMISO', Colors.teal);

    // ✅ Si controller devuelve PROGRAMADO, pintamos PROGRAMADO siempre
    if (estadoUI == 'PROGRAMADO') return _chip('PROGRAMADO', Colors.blue);

    // PASADO
    if (isPast) {
      switch (estadoUI) {
        case 'COMPLETO':
        case 'OK':
          return _chip('COMPLETO', Colors.green);
        case 'ATRASO':
          return _chip('ATRASO', Colors.orange);
        case 'INCOMPLETO':
          return _chip('INCOMPLETO', Colors.red);
        case 'FALTA':
          return _chip('FALTA', Colors.redAccent);
        case 'SIN MARCA':
          return _chip('SIN MARCA', Colors.grey);
        case 'SOLO ENTRADA':
          return _chip('SOLO ENTRADA', Colors.deepOrange);
        case 'SOLO SALIDA':
          return _chip('SOLO SALIDA', Colors.deepOrange);
        default:
          return _chip(estadoUI.isEmpty ? 'SIN ESTADO' : estadoUI, Colors.grey);
      }
    }

    // HOY
    if (isToday) {
      if (estadoUI == 'EN CURSO') return _chip('EN CURSO', Colors.blue);
      if (estadoUI == 'COMPLETO') return _chip('COMPLETO', Colors.green);
      if (estadoUI == 'SIN MARCA') return _chip('SIN MARCA', Colors.orange);
      if (estadoUI == 'ATRASO') return _chip('ATRASO', Colors.orange);
      if (estadoUI == 'INCOMPLETO') return _chip('INCOMPLETO', Colors.red);
      if (estadoUI == 'SOLO ENTRADA')
        return _chip('SOLO ENTRADA', Colors.deepOrange);
      if (estadoUI == 'SOLO SALIDA')
        return _chip('SOLO SALIDA', Colors.deepOrange);
      return _chip(estadoUI.isEmpty ? 'SIN ESTADO' : estadoUI, Colors.grey);
    }

    // FUTURO (por seguridad)
    return _chip('PROGRAMADO', Colors.blue);
  }

  Widget? _chipHoraAcumulada(DiaHorarioSemana d) {
    final st = (d.estadoHoraAcumulada ?? 'NO').toString().trim().toUpperCase();
    if (st.isEmpty || st == 'NO') return null;

    final h = d.numHorasAcumuladas;
    final label = 'H.A. ${_shortEstadoHA(st)}${h != null ? ' ${h}h' : ''}';

    final color =
        st == 'SOLICITUD'
            ? Colors.orange
            : st == 'APROBADO'
            ? Colors.green
            : Colors.red;

    return Tooltip(
      message: 'Horas acumuladas: $st${h != null ? ' ($h h)' : ''}',
      child: _chip(label, color),
    );
  }

  String _shortEstadoHA(String st) {
    switch (st) {
      case 'SOLICITUD':
        return 'SOL';
      case 'APROBADO':
        return 'OK';
      case 'RECHAZADO':
        return 'RECH';
      default:
        return st.length > 4 ? st.substring(0, 4) : st;
    }
  }

  Widget _chip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }

  // =========================
  //   DIALOG OBSERVACION
  // =========================
  Future<void> _dialogObservacion(
    BuildContext context,
    DiaHorarioSemana dia,
  ) async {
    final tec = TextEditingController(text: (dia.observacion ?? '').trim());

    final st =
        (dia.estadoHoraAcumulada ?? 'NO').toString().trim().toUpperCase();
    bool solicita = st == 'SOLICITUD';

    final baseH = dia.numHorasAcumuladas ?? 1;
    int horas = baseH < 1 ? 1 : (baseH > 15 ? 15 : baseH);

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Observación'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tec,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Escribe una novedad...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: solicita,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Solicitud horas acumuladas'),
                      onChanged: (v) {
                        setState(() {
                          solicita = v ?? false;
                          if (!solicita) horas = 1;
                        });
                      },
                    ),
                    if (solicita) ...[
                      const SizedBox(height: 8),
                      DropdownButtonFormField<int>(
                        value: horas,
                        decoration: const InputDecoration(
                          labelText: 'Número de horas (1-15)',
                          border: OutlineInputBorder(),
                        ),
                        items: List.generate(
                          15,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('${i + 1}'),
                          ),
                        ),
                        onChanged: (v) => setState(() => horas = v ?? 1),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await controller.guardarObservacionHoy(
                      dia: dia,
                      texto: tec.text,
                      solicitarHoraAcumulada: solicita,
                      numHorasAcumuladas: solicita ? horas : null,
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
