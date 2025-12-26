import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:redecom_app/src/models/dia_horario_semana.dart';
import 'package:redecom_app/src/providers/mi_horario_provider.dart';
import 'package:redecom_app/src/utils/snackbar_service.dart';

class MiHorarioController extends GetxController {
  final MiHorarioProvider provider;

  MiHorarioController({required this.provider});

  final cargando = false.obs;

  /// Rango semanal (SIEMPRE Lun-Dom) devuelto por backend
  final desde = DateTime.now().obs; // lunes
  final hasta = DateTime.now().obs; // domingo

  /// 7 items exactos del backend
  final dias = <DiaHorarioSemana>[].obs;

  String _ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);
  DateTime _onlyDate(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _parseYmdLocal(String ymd) {
    final p = ymd.split('-');
    return DateTime(int.parse(p[0]), int.parse(p[1]), int.parse(p[2]));
  }

  @override
  void onInit() {
    super.onInit();
    cargarSemanaPorFecha(DateTime.now());
  }

  // ==========================
  // Navegación semanal
  // ==========================
  Future<void> cargarSemanaPorFecha(DateTime anyDay) async {
    try {
      cargando.value = true;

      final resp = await provider.getMiHorarioSemana(fecha: _ymd(anyDay));

      desde.value = _parseYmdLocal(resp.desde);
      hasta.value = _parseYmdLocal(resp.hasta);

      dias.assignAll(resp.data);
    } catch (e) {
      SnackbarService.error('No se pudo cargar la semana: $e');
    } finally {
      cargando.value = false;
    }
  }

  Future<void> prevWeek() async {
    final monday = _onlyDate(desde.value);
    await cargarSemanaPorFecha(monday.subtract(const Duration(days: 7)));
  }

  Future<void> nextWeek() async {
    final monday = _onlyDate(desde.value);
    await cargarSemanaPorFecha(monday.add(const Duration(days: 7)));
  }

  // ==========================
  // Helpers de día
  // ==========================
  bool isPastDay(DateTime day) {
    final d = _onlyDate(day);
    final today = _onlyDate(DateTime.now());
    return d.isBefore(today);
  }

  bool isToday(DateTime day) {
    final d = _onlyDate(day);
    final today = _onlyDate(DateTime.now());
    return d == today;
  }

  bool isFutureDay(DateTime day) {
    final d = _onlyDate(day);
    final today = _onlyDate(DateTime.now());
    return d.isAfter(today);
  }

  // ==========================
  // ✅ Helpers hora programada (para HOY)
  // ==========================
  int? _hhmmToMinutes(String? hhmm) {
    if (hhmm == null) return null;
    final s = hhmm.trim();
    if (s.isEmpty) return null;

    final parts = s.split(':'); // "HH:mm" o "HH:mm:ss"
    if (parts.length < 2) return null;

    final hh = int.tryParse(parts[0]);
    final mm = int.tryParse(parts[1]);
    if (hh == null || mm == null) return null;

    return hh * 60 + mm;
  }

  bool _isBeforeHoraEntradaProgHoy(DiaHorarioSemana d) {
    if (!isToday(d.fecha)) return false;

    final progMin = _hhmmToMinutes(d.horaEntradaProg);
    if (progMin == null) return false;

    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    return nowMin < progMin;
  }

  // ==========================
  // ✅ Estado UI (ASISTENCIA) - LÓGICA OFICIAL
  // ==========================
  String estadoUI(DiaHorarioSemana d) {
    if (!d.tieneTurno) return 'SIN TURNO';

    // tipo_dia pisa el estado
    final tipo = d.tipoDia.toString().trim().toUpperCase();
    if (tipo.isNotEmpty && tipo != 'NORMAL') {
      if (tipo == 'DEVOLUCION') return 'DEVOLUCIÓN';
      if (tipo == 'VACACIONES') return 'VACACIONES';
      if (tipo == 'PERMISO') return 'PERMISO';
      return tipo;
    }

    final base = d.estadoAsistencia.toString().trim().toUpperCase();

    final tieneEntrada = d.horaEntradaReal != null;
    final tieneSalida = d.horaSalidaReal != null;

    // Futuro => PROGRAMADO
    if (isFutureDay(d.fecha)) return 'PROGRAMADO';

    // Hoy
    if (isToday(d.fecha)) {
      if (tieneEntrada && !tieneSalida) return 'EN CURSO';

      if (base.isEmpty || base == 'SIN_MARCA' || base == 'SIN MARCA') {
        return _isBeforeHoraEntradaProgHoy(d) ? 'PROGRAMADO' : 'SIN MARCA';
      }

      if (base == 'SOLO_ENTRADA') return 'SOLO ENTRADA';
      if (base == 'SOLO_SALIDA') return 'SOLO SALIDA';
      if (base == 'OK') return 'COMPLETO';

      return base;
    }

    // Pasado
    if (isPastDay(d.fecha)) {
      if (base.isEmpty || base == 'SIN_MARCA' || base == 'SIN MARCA') {
        return 'FALTA';
      }
      if (base == 'OK') return 'COMPLETO';
      return base;
    }

    return base.isEmpty ? 'SIN ESTADO' : base;
  }

  // ==========================
  // Horas acumuladas (helpers)
  // ==========================
  bool horaAcumuladaVisible(DiaHorarioSemana d) {
    final st = d.estadoHoraAcumulada.toUpperCase().trim();
    return st != 'NO';
  }

  String horaAcumuladaLabel(DiaHorarioSemana d) {
    final st = d.estadoHoraAcumulada.toUpperCase().trim();
    final h = d.numHorasAcumuladas;

    if (st == 'SOLICITUD')
      return 'H.A. SOLICITUD${h != null ? ' · ${h}h' : ''}';
    if (st == 'APROBADO') return 'H.A. APROBADO${h != null ? ' · ${h}h' : ''}';
    if (st == 'RECHAZADO')
      return 'H.A. RECHAZADO${h != null ? ' · ${h}h' : ''}';
    return 'H.A. $st${h != null ? ' · ${h}h' : ''}';
  }

  // ==========================
  // ✅ Permisos UI (editar / solicitar)
  // ==========================
  bool puedeEditarDia(DiaHorarioSemana d) {
    if (!d.tieneTurno) return false;
    final tipo = d.tipoDia.toUpperCase().trim();
    if (tipo != 'NORMAL') return false;
    // si HA APROBADO, backend bloquea observación HOY
    // pero igual podría permitir justificaciones en otros días;
    // el page decide qué mostrar según HOY/PASADO.
    return true;
  }

  bool puedeSolicitarJustAtraso(DiaHorarioSemana d) {
    if (!d.tieneTurno || d.id == null) return false;

    // ✅ Regla: solo el mismo día
    if (!isToday(d.fecha)) return false;

    final tipo = d.tipoDia.toUpperCase().trim();
    if (tipo != 'NORMAL') return false;

    final st =
        d.justAtrasoEstado
            .toUpperCase()
            .trim(); // NO | PENDIENTE | APROBADA | RECHAZADA
    return st == 'NO' || st == 'RECHAZADA';
  }

  bool puedeSolicitarJustSalida(DiaHorarioSemana d) {
    if (!d.tieneTurno || d.id == null) return false;

    // ✅ Regla: solo el mismo día
    if (!isToday(d.fecha)) return false;

    final tipo = d.tipoDia.toUpperCase().trim();
    if (tipo != 'NORMAL') return false;

    final st = d.justSalidaEstado.toUpperCase().trim();
    return st == 'NO' || st == 'RECHAZADA';
  }

  // ==========================
  // ✅ Guardar edición (HOY + JUSTIFICACIONES)
  // ==========================
  Future<void> guardarEdicionDia({
    required DiaHorarioSemana dia,
    String? obsHorasAcum, // observación (motivo HA)
    required bool solicitarHoraAcumulada,
    int? numHorasAcumuladas,
    String? motivoAtraso,
    String? motivoSalida,
  }) async {
    try {
      cargando.value = true;

      final tipoDia = dia.tipoDia.toUpperCase().trim();
      if (tipoDia != 'NORMAL') {
        throw Exception('No se puede modificar: el día es $tipoDia');
      }

      // 1) Observación + solicitud HA (solo HOY)
      if (isToday(dia.fecha)) {
        final stHA = dia.estadoHoraAcumulada.toUpperCase().trim();
        if (stHA == 'APROBADO') {
          throw Exception(
            'No se puede modificar: la solicitud ya está APROBADA',
          );
        }

        if (solicitarHoraAcumulada) {
          final n = numHorasAcumuladas ?? 0;
          if (n < 1 || n > 15) {
            SnackbarService.warning('Horas acumuladas debe ser 1 a 15');
            return;
          }
        }

        await provider.putObservacionHoy(
          observacion: (obsHorasAcum ?? '').trim(),
          solicitarHoraAcumulada: solicitarHoraAcumulada,
          numHorasAcumuladas:
              solicitarHoraAcumulada ? numHorasAcumuladas : null,
        );
      }

      // ✅ AQUÍ MISMO (ANTES de justificaciones)
      final motA = (motivoAtraso ?? '').trim();
      final motS = (motivoSalida ?? '').trim();

      if (!isToday(dia.fecha) && (motA.isNotEmpty || motS.isNotEmpty)) {
        throw Exception(
          'Las justificaciones solo se pueden solicitar el mismo día.',
        );
      }

      // 2) Justificación atraso
      if (motA.isNotEmpty) {
        if (!puedeSolicitarJustAtraso(dia)) {
          throw Exception('No se puede solicitar atraso...');
        }
        await provider.postJustificacionAtraso(turnoId: dia.id!, motivo: motA);
      }

      // 3) Justificación salida
      if (motS.isNotEmpty) {
        if (!puedeSolicitarJustSalida(dia)) {
          throw Exception('No se puede solicitar salida...');
        }
        await provider.postJustificacionSalida(turnoId: dia.id!, motivo: motS);
      }

      await cargarSemanaPorFecha(dia.fecha);
      SnackbarService.success('Guardado');
    } catch (e) {
      SnackbarService.error('No se pudo guardar: $e');
    } finally {
      cargando.value = false;
    }
  }
}
