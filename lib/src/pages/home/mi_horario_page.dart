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
    final dfTime = DateFormat('HH:mm', 'es_EC');

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
                    children: [_listaSemana(context, dfDay, dfTime)],
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
  // HEADER SEMANA
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
  // LISTA SEMANA
  // =========================
  Widget _listaSemana(
    BuildContext context,
    DateFormat dfDay,
    DateFormat dfTime,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Obx(() {
          final items = controller.dias;
          if (items.isEmpty) return const Text('Sin datos para esta semana.');

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
                              const SizedBox(height: 4),
                              Text(
                                'Marcado: ${_fmtHora(d.horaEntradaReal, dfTime)} - ${_fmtHora(d.horaSalidaReal, dfTime)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

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
  // TRAILING EN COLUMNAS
  // =========================
  Widget _trailingEnColumnas(
    BuildContext context,
    DiaHorarioSemana d,
    bool isPast,
    bool isToday,
    String estadoUI,
  ) {
    final chipAsistencia = _chipAsistencia(
      tieneTurno: d.tieneTurno,
      isPast: isPast,
      isToday: isToday,
      estadoUI: estadoUI,
    );

    final chipHoraAcum = _chipHoraAcumulada(d);
    final chipJustA = _chipJustificacion(
      labelPrefix: 'ATR',
      estado: d.justAtrasoEstado,
    );
    final chipJustS = _chipJustificacion(
      labelPrefix: 'SAL',
      estado: d.justSalidaEstado,
    );

    final stHA = d.estadoHoraAcumulada.toUpperCase().trim();
    final tipoDia = d.tipoDia.toUpperCase().trim();

    // Mostrar botón si el día es NORMAL y tiene turno.

    final mostrarBoton = isToday && d.tieneTurno && tipoDia == 'NORMAL';

    // Si está APROBADO, igual puedes permitir justificaciones, pero no obs/HA.
    // El controller backend ya bloquea obs/HA, y nosotros lo manejamos en el diálogo.
    // (No ocultamos el botón por APROBADO)

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        chipAsistencia,
        if (chipHoraAcum != null) ...[const SizedBox(height: 6), chipHoraAcum],
        if (chipJustA != null) ...[const SizedBox(height: 6), chipJustA],
        if (chipJustS != null) ...[const SizedBox(height: 6), chipJustS],
        if (mostrarBoton) ...[
          const SizedBox(height: 6),
          IconButton(
            onPressed: () => _dialogEditarDia(context, d),
            tooltip: 'Editar día',
            icon: const Icon(Icons.edit_note, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }

  // =========================
  // CHIPS
  // =========================
  Widget _chipAsistencia({
    required bool tieneTurno,
    required bool isPast,
    required bool isToday,
    required String estadoUI,
  }) {
    if (!tieneTurno) return _chip('SIN TURNO', Colors.grey);

    // tipo_dia pisa
    if (estadoUI == 'DEVOLUCIÓN') return _chip('DEVOLUCIÓN', Colors.purple);
    if (estadoUI == 'VACACIONES') return _chip('VACACIONES', Colors.indigo);
    if (estadoUI == 'PERMISO') return _chip('PERMISO', Colors.teal);

    if (estadoUI == 'PROGRAMADO') return _chip('PROGRAMADO', Colors.blue);

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

    return _chip('PROGRAMADO', Colors.blue);
  }

  Widget? _chipHoraAcumulada(DiaHorarioSemana d) {
    final st = d.estadoHoraAcumulada.toString().trim().toUpperCase();
    if (st.isEmpty || st == 'NO') return null;

    final h = d.numHorasAcumuladas;
    final label = 'H.A. ${_shortEstado(st)}${h != null ? ' ${h}h' : ''}';

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

  Widget? _chipJustificacion({
    required String labelPrefix,
    required String estado,
  }) {
    final st =
        (estado).toUpperCase().trim(); // NO | PENDIENTE | APROBADA | RECHAZADA
    if (st.isEmpty || st == 'NO') return null;

    final label = '$labelPrefix ${_shortEstado(st)}';
    final color =
        st == 'PENDIENTE'
            ? Colors.orange
            : st == 'APROBADA'
            ? Colors.green
            : Colors.red;

    return Tooltip(
      message: 'Justificación $labelPrefix: $st',
      child: _chip(label, color),
    );
  }

  String _shortEstado(String st) {
    switch (st) {
      case 'SOLICITUD':
        return 'SOL';
      case 'APROBADO':
      case 'APROBADA':
        return 'OK';
      case 'RECHAZADO':
      case 'RECHAZADA':
        return 'RECH';
      case 'PENDIENTE':
        return 'PEN';
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
  // DIALOG: EDITAR DÍA
  // =========================
  Future<void> _dialogEditarDia(
    BuildContext context,
    DiaHorarioSemana dia,
  ) async {
    final isToday = controller.isToday(dia.fecha);
    final tipoDia = dia.tipoDia.toUpperCase().trim();

    // Observación (motivo HA)
    final teObs = TextEditingController(text: (dia.observacion ?? '').trim());

    // HA
    final stHA = dia.estadoHoraAcumulada.toUpperCase().trim();
    bool solicitaHA = stHA == 'SOLICITUD';
    final baseH = dia.numHorasAcumuladas ?? 1;
    int horasHA = baseH < 1 ? 1 : (baseH > 15 ? 15 : baseH);

    // Justificaciones
    final teAtraso = TextEditingController(
      text: (dia.justAtrasoMotivo ?? '').trim(),
    );
    final teSalida = TextEditingController(
      text: (dia.justSalidaMotivo ?? '').trim(),
    );

    final puedeObsHA =
        isToday && dia.tieneTurno && tipoDia == 'NORMAL' && stHA != 'APROBADO';
    final puedeJustA = controller.puedeSolicitarJustAtraso(dia);
    final puedeJustS = controller.puedeSolicitarJustSalida(dia);

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                _capitalize(
                  DateFormat('EEEE dd/MM', 'es_EC').format(dia.fecha),
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // =====================
                    // OBS + HA (solo HOY)
                    // =====================
                    if (puedeObsHA) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Novedad',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: teObs,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Escribe un motivo...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      CheckboxListTile(
                        value: solicitaHA,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Solicitar horas acumuladas'),
                        onChanged: (v) {
                          setState(() {
                            solicitaHA = v ?? false;
                            if (!solicitaHA) horasHA = 1;
                          });
                        },
                      ),
                      if (solicitaHA) ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int>(
                          value: horasHA,
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
                          onChanged: (v) => setState(() => horasHA = v ?? 1),
                        ),
                      ],
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 8),
                    ] else ...[
                      // Si no puede editar obs/HA, igual mostramos info
                      if (isToday)
                        Text(
                          stHA == 'APROBADO'
                              ? '⚠️ No se puede editar observación/HA: ya está APROBADO'
                              : 'ℹ️ Observación/HA solo se edita HOY y en día NORMAL.',
                          style: const TextStyle(color: Colors.black54),
                        ),
                      if (isToday) const SizedBox(height: 12),
                    ],

                    // =====================
                    // JUSTIFICACIÓN ATRASO
                    // =====================
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Motivo atraso',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: teAtraso,
                      enabled: puedeJustA,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText:
                            puedeJustA
                                ? 'Describe el motivo del atraso...'
                                : 'No disponible (pendiente/aprobada o no aplica)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // =====================
                    // JUSTIFICACIÓN SALIDA
                    // =====================
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Motivo salida temprana',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: teSalida,
                      enabled: puedeJustS,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText:
                            puedeJustS
                                ? 'Describe el motivo de la salida...'
                                : 'No disponible (pendiente/aprobada o no aplica)',
                        border: const OutlineInputBorder(),
                      ),
                    ),
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

                    await controller.guardarEdicionDia(
                      dia: dia,
                      obsHorasAcum: teObs.text,
                      solicitarHoraAcumulada: puedeObsHA ? solicitaHA : false,
                      numHorasAcumuladas:
                          (puedeObsHA && solicitaHA) ? horasHA : null,
                      motivoAtraso: teAtraso.text,
                      motivoSalida: teSalida.text,
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

  String _fmtHora(DateTime? dt, DateFormat dfTime) {
    if (dt == null) return '-';
    return dfTime.format(dt.toLocal());
  }
}
