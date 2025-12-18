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

      // ✅ Usar el rango real del backend para pintar el header
      desde.value = _parseYmdLocal(resp.desde);
      hasta.value = _parseYmdLocal(resp.hasta);

      // ✅ 7 días exactos
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

    // acepta "HH:mm" o "HH:mm:ss"
    final parts = s.split(':');
    if (parts.length < 2) return null;

    final hh = int.tryParse(parts[0]);
    final mm = int.tryParse(parts[1]);
    if (hh == null || mm == null) return null;

    return hh * 60 + mm;
  }

  bool _isBeforeHoraEntradaProgHoy(DiaHorarioSemana d) {
    if (!isToday(d.fecha)) return false;

    // ⚠️ usa el campo real de tu modelo: horaEntradaProg
    final progMin = _hhmmToMinutes(d.horaEntradaProg);
    if (progMin == null) return false;

    final now = DateTime.now();
    final nowMin = now.hour * 60 + now.minute;
    return nowMin < progMin;
  }

  // ==========================
  // ✅ Estado UI (ASISTENCIA) - LÓGICA OFICIAL
  // ==========================
  //
  // Importante:
  // - En DB normalmente guardas "SIN_MARCA"
  // - En UI:
  //     * Futuro => PROGRAMADO
  //     * Hoy ANTES de hora_entrada_prog y SIN_MARCA => PROGRAMADO
  //     * Hoy DESPUÉS de hora_entrada_prog y SIN_MARCA => SIN MARCA
  //     * Pasado y SIN_MARCA => FALTA
  //
  // - tipo_dia (DEVOLUCION/VACACIONES/PERMISO) PISA el estado.
  //
  String estadoUI(DiaHorarioSemana d) {
    if (!d.tieneTurno) return 'SIN TURNO';

    // 1) ✅ tipo_dia pisa el estado
    // ⚠️ SI tu modelo NO se llama tipoDia, cambia SOLO ESTA LÍNEA por el nombre real.
    final tipo = d.tipoDia.toString().trim().toUpperCase();

    if (tipo.isNotEmpty && tipo != 'NORMAL') {
      if (tipo == 'DEVOLUCION') return 'DEVOLUCIÓN';
      if (tipo == 'VACACIONES') return 'VACACIONES';
      if (tipo == 'PERMISO') return 'PERMISO';
      return tipo;
    }

    final base = (d.estadoAsistencia).toString().trim().toUpperCase();

    final tieneEntrada = d.horaEntradaReal != null;
    final tieneSalida = d.horaSalidaReal != null;

    // 2) ✅ Futuro => PROGRAMADO
    if (isFutureDay(d.fecha)) return 'PROGRAMADO';

    // 3) ✅ Hoy
    if (isToday(d.fecha)) {
      if (tieneEntrada && !tieneSalida) return 'EN CURSO';

      // SIN_MARCA hoy:
      // - antes de la hora prog => PROGRAMADO
      // - después => SIN MARCA
      if (base.isEmpty || base == 'SIN_MARCA' || base == 'SIN MARCA') {
        return _isBeforeHoraEntradaProgHoy(d) ? 'PROGRAMADO' : 'SIN MARCA';
      }

      if (base == 'SOLO_ENTRADA') return 'SOLO ENTRADA';
      if (base == 'SOLO_SALIDA') return 'SOLO SALIDA';
      if (base == 'OK') return 'COMPLETO';

      return base;
    }

    // 4) ✅ Pasado
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
    final st = (d.estadoHoraAcumulada ?? 'NO').toString().toUpperCase().trim();
    return st != 'NO';
  }

  String horaAcumuladaLabel(DiaHorarioSemana d) {
    final st = (d.estadoHoraAcumulada ?? 'NO').toString().toUpperCase().trim();
    final h = d.numHorasAcumuladas;

    if (st == 'SOLICITUD') {
      return 'H.A. SOLICITUD${h != null ? ' · ${h}h' : ''}';
    }
    if (st == 'APROBADO') {
      return 'H.A. APROBADO${h != null ? ' · ${h}h' : ''}';
    }
    if (st == 'RECHAZADO') {
      return 'H.A. RECHAZADO${h != null ? ' · ${h}h' : ''}';
    }
    return 'H.A. $st${h != null ? ' · ${h}h' : ''}';
  }

  String horaAcumuladaColorKey(DiaHorarioSemana d) {
    final st = (d.estadoHoraAcumulada ?? 'NO').toString().toUpperCase().trim();
    if (st == 'SOLICITUD') return 'sol';
    if (st == 'APROBADO') return 'ok';
    if (st == 'RECHAZADO') return 'rech';
    return 'none';
  }

  // ==========================
  // Guardar observación (HOY)
  // ==========================

  Future<void> guardarObservacionHoy({
    required DiaHorarioSemana dia,
    required String texto,
    required bool solicitarHoraAcumulada,
    int? numHorasAcumuladas,
  }) async {
    try {
      cargando.value = true;

      if (solicitarHoraAcumulada &&
          (numHorasAcumuladas == null || numHorasAcumuladas < 1)) {
        SnackbarService.warning('Ingrese cuántas horas acumuladas solicita');
        return;
      }

      await provider.putObservacionHoy(
        observacion: texto.trim(),
        solicitarHoraAcumulada: solicitarHoraAcumulada,
        numHorasAcumuladas: solicitarHoraAcumulada ? numHorasAcumuladas : null,
      );

      // ✅ recargar la semana para reflejar estado actualizado
      await cargarSemanaPorFecha(dia.fecha);

      SnackbarService.success('Guardado');
    } catch (e) {
      SnackbarService.error('No se pudo guardar: $e');
    } finally {
      cargando.value = false;
    }
  }

  bool puedeEditarObservacion(DiaHorarioSemana d) {
    final st = d.estadoHoraAcumulada.toString().trim().toUpperCase();
    return st != 'APROBADO';
  }
}
