import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// Fila "label: valor" donde el valor (coordenadas) es clicable
/// y abre la ubicación en la app de mapas / navegador.
Widget kvLinkCoords({
  required BuildContext context,
  required String label,
  String? value,
  double labelWidth = 150,
  TextStyle? labelStyle,
  TextStyle? valueStyle,
  String? placeLabel, // etiqueta opcional para el pin
}) {
  final raw0 = (value ?? '').trim();
  final isEmpty = raw0.isEmpty || raw0.toLowerCase() == 'null';

  // Mostrar tal cual, pero intentar parsear para habilitar click
  final parsed = isEmpty ? null : parseLatLng(raw0);
  final clickable = parsed != null;

  final effectiveLabelStyle =
      labelStyle ?? const TextStyle(fontWeight: FontWeight.w600);

  final effectiveValueStyle =
      valueStyle ??
      TextStyle(
        color:
            clickable ? const Color.fromARGB(255, 255, 0, 0) : Colors.black87,
        //decoration: clickable ? TextDecoration.underline : TextDecoration.none,
      );

  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: labelWidth,
          child: Text('$label:', style: effectiveLabelStyle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child:
                    isEmpty
                        ? const Text('—')
                        : InkWell(
                          onTap:
                              !clickable
                                  ? null
                                  : () => openMapsFromCoords(
                                    context,
                                    raw0,
                                    label: placeLabel,
                                  ),
                          child: Text(raw0, style: effectiveValueStyle),
                        ),
              ),
              if (!isEmpty)
                IconButton(
                  tooltip: 'Abrir en Google Maps',
                  icon: const Icon(Icons.map),
                  onPressed:
                      !clickable
                          ? null
                          : () => openMapsFromCoords(
                            context,
                            raw0,
                            label: placeLabel,
                          ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

/// Abre la ubicación en app de mapas (si existe) o navegador.
/// - Android: intenta `geo:` y cae a URL web.
/// - iOS: intenta `comgooglemaps://`, luego Apple Maps, luego URL web.
/// - Web/desktop: URL web.
Future<void> openMapsFromCoords(
  BuildContext context,
  String coords, {
  String? label,
}) async {
  final parsed = parseLatLng(coords);
  if (parsed == null) {
    _toast(context, 'Coordenadas inválidas: $coords');
    return;
  }

  final lat = parsed.lat;
  final lng = parsed.lng;

  final pinLabel = (label ?? 'Ubicación').trim();
  final encodedLabel = Uri.encodeComponent(pinLabel);

  // URL universal de Google Maps (web)
  final googleWeb = Uri.parse(
    'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
  );

  if (kIsWeb) {
    await launchUrl(googleWeb, mode: LaunchMode.externalApplication);
    return;
  }

  try {
    if (GetPlatform.isIOS) {
      // Google Maps iOS: etiqueta@lat,lng
      final googleIOS = Uri.parse(
        'comgooglemaps://?q=$encodedLabel@$lat,$lng&zoom=14',
      );
      // Apple Maps
      final apple = Uri.parse(
        'http://maps.apple.com/?ll=$lat,$lng&q=$encodedLabel',
      );

      if (await canLaunchUrl(googleIOS)) {
        await launchUrl(googleIOS, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(apple)) {
        await launchUrl(apple, mode: LaunchMode.externalApplication);
        return;
      }
      await launchUrl(googleWeb, mode: LaunchMode.externalApplication);
      return;
    }

    if (GetPlatform.isAndroid) {
      // Android geo: etiqueta dentro de ( )
      final geo = Uri.parse('geo:$lat,$lng?q=$lat,$lng($encodedLabel)');
      if (await canLaunchUrl(geo)) {
        await launchUrl(geo, mode: LaunchMode.externalApplication);
        return;
      }
      await launchUrl(googleWeb, mode: LaunchMode.externalApplication);
      return;
    }
  } catch (_) {
    // cae a web
  }

  // Desktop u otras plataformas
  await launchUrl(googleWeb, mode: LaunchMode.externalApplication);
}

/// Parser robusto para coordenadas:
/// - Soporta "lat, lng", "lat,,lng", "lat ; lng", espacios extra, etc.
/// - Devuelve null si no puede parsear 2 números.
/// - Si tu backend a veces manda decimales con coma, habilita la línea marcada.
LatLng? parseLatLng(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return null;

  // Normaliza separadores
  s = s.replaceAll(';', ',');
  s = s.replaceAll(',,', ',');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();

  // Split por coma o espacio
  final parts = s.split(RegExp(r'[,\s]+')).where((e) => e.isNotEmpty).toList();
  if (parts.length < 2) return null;

  double? _toDouble(String x) {
    // Habilita si te llegan decimales con coma (Ecuador/ES):
    // x = x.replaceAll(',', '.');
    return double.tryParse(x);
  }

  final nums = <double>[];
  for (final p in parts) {
    final n = _toDouble(p);
    if (n != null) nums.add(n);
    if (nums.length == 2) break;
  }
  if (nums.length != 2) return null;

  return LatLng(nums[0], nums[1]);
}

/// Modelo simple (Dart 2/3)
class LatLng {
  final double lat;
  final double lng;
  const LatLng(this.lat, this.lng);
}

void _toast(BuildContext context, String msg) {
  // Helper sin depender de Get para mostrar el aviso
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
}
