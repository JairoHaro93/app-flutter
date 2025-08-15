// lib/src/utils/date_helpers.dart
import 'package:intl/intl.dart';

class Fmt {
  /// dd/MM/yyyy
  static String date(String? raw, {bool toLocal = true}) {
    final dt = _parse(raw, toLocal: toLocal);
    if (dt == null) return '—';
    return DateFormat('dd/MM/yyyy').format(dt);
  }

  /// dd/MM/yyyy HH:mm
  static String dateTime(String? raw, {bool toLocal = true}) {
    final dt = _parse(raw, toLocal: toLocal);
    if (dt == null) return '—';
    return DateFormat('dd/MM/yyyy HH:mm').format(dt);
  }

  /// Patron custom, ej: 'EEE d MMM, HH:mm'
  static String custom(String? raw, String pattern, {bool toLocal = true}) {
    final dt = _parse(raw, toLocal: toLocal);
    if (dt == null) return '—';
    return DateFormat(pattern).format(dt);
  }

  static DateTime? _parse(String? raw, {bool toLocal = true}) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;

    try {
      var dt = DateTime.parse(s); // ISO-8601 friendly
      if (toLocal && dt.isUtc) dt = dt.toLocal();
      return dt;
    } catch (_) {
      return null; // si no parsea, devolvemos null y mostramos "—"
    }
  }
}

/// Azúcar sintáctico
extension DateFmtX on String? {
  String asDate() => Fmt.date(this);
  String asDateTime() => Fmt.dateTime(this);
}
