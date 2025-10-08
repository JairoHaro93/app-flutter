import 'package:url_launcher/url_launcher.dart';

class PhoneHelper {
  /// Extrae teléfonos y respeta:
  /// - "0981159354 0981159354"  -> 2 números
  /// - "+593 98 700 2351 , 0987107129"
  /// - "+593 98 700 2351  0987107129" (doble espacio)
  /// - "0987107123 - 0998546796", "0987107123 -0998546796", "0987107123- 0998546796"
  static List<String> parsePhones(String? src) {
    final s0 = (src ?? '').trim();
    if (s0.isEmpty) return [];

    // 1) Normaliza guiones tipográficos (– — ‒ ―)
    var s = s0.replaceAll(RegExp(r'[\u2012-\u2015]'), '-');

    // 2) Unifica guiones con espacio a un lado como separador
    s = s.replaceAll(RegExp(r'\s+-\s*|\s*-\s+'), ',');

    // 3) Doble (o más) espacios => separador
    s = s.replaceAll(RegExp(r'\s{2,}'), ',');

    // 4) Espacio entre dos grupos LARGOS (>=7 dígitos) => separador
    //    Ej: "0981159354 0981159354" -> "0981159354,0981159354"
    s = s.replaceAllMapped(
      RegExp(r'(\d{7,})\s+(?=\+?\d{7,})'),
      (m) => '${m.group(1)},',
    );

    // 5) Corta por separadores fuertes
    final chunks = s.split(RegExp(r'[;,|/]+'));

    // 6) De cada chunk, extrae teléfonos permitiendo espacios, -, ()
    final numRegex = RegExp(r'\+?\d[\d\-\s\(\)]*\d');
    final out = <String>[];
    for (final c in chunks) {
      final t = c.trim();
      if (t.isEmpty) continue;
      for (final m in numRegex.allMatches(t)) {
        final cand = m.group(0)!.trim();
        final digits = cand.replaceAll(RegExp(r'\D'), '');
        if (digits.length >= 7) out.add(cand);
      }
    }

    // 7) Opcional: deduplicar por dígitos
    final seen = <String>{};
    return out.where((p) => seen.add(p.replaceAll(RegExp(r'\D'), ''))).toList();
  }

  static Future<void> llamar(String numero) async {
    final limpio = numero.replaceAll(RegExp(r'[^0-9+]'), '');
    if (limpio.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: limpio);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) throw 'No se pudo abrir el marcador para $numero';
  }
}
