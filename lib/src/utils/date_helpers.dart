// lib/src/utils/date_helpers.dart
import 'package:intl/intl.dart';

class Fmt {
  /// Fecha “de calendario” (dd/MM/yyyy)
  /// - Si la cadena es ISO con 'Z' y hora 00:00:00, preserva el día tal cual.
  /// - En otros casos, parsea normal y (opcionalmente) convierte a local.
  static String date(String? raw, {bool toLocal = true}) {
    final dt = _parsePreservingDayForMidnightUTC(raw, toLocal: toLocal);
    if (dt == null) return '—';
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  /// Fecha y hora (dd/MM/yyyy HH:mm)
  /// - No “preserva día”; es para eventos con hora real.
  /// - Convierte a local por defecto para mostrar la hora del dispositivo.
  static String dateTime(String? raw, {bool toLocal = true}) {
    final dt = _parse(raw, toLocal: toLocal);
    if (dt == null) return '—';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  /// Formato personalizado
  static String custom(String? raw, String pattern, {bool toLocal = true}) {
    final dt = _parse(raw, toLocal: toLocal);
    if (dt == null) return '—';
    return DateFormat(pattern).format(dt);
  }

  // ----------------- Parsers internos -----------------

  /// Parser general
  static DateTime? _parse(String? raw, {bool toLocal = true}) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;

    try {
      var dt = DateTime.parse(s); // ISO friendly
      if (toLocal && dt.isUtc) dt = dt.toLocal();
      return dt;
    } catch (_) {
      return null;
    }
  }

  /// Si viene ISO con 'Z' y hora 00:00:00, preserva la parte de fecha.
  /// Útil para “fechas de calendario” que el backend serializa como medianoche UTC.
  static DateTime? _parsePreservingDayForMidnightUTC(
    String? raw, {
    bool toLocal = true,
  }) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;

    // Detecta: YYYY-MM-DDT00:00:00(.000)?Z
    final m = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})T00:00:00(\.\d{3})?Z$',
    ).firstMatch(s);
    if (m != null) {
      final y = int.parse(m.group(1)!);
      final mo = int.parse(m.group(2)!);
      final d = int.parse(m.group(3)!);
      // DateTime “naive” local (sin conversión de TZ) => no hay corrimiento.
      return DateTime(y, mo, d);
    }

    // En cualquier otro caso, comportamiento normal
    return _parse(s, toLocal: toLocal);
  }
}

/// Azúcar sintáctico
extension DateFmtX on String? {
  String asDate({bool toLocal = true}) => Fmt.date(this, toLocal: toLocal);
  String asDateTime({bool toLocal = true}) =>
      Fmt.dateTime(this, toLocal: toLocal);
}
