import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:redecom_app/src/environments/environment.dart';
import 'package:redecom_app/src/models/dia_horario_semana.dart';

class MiHorarioSemanaResponse {
  final bool success;
  final String desde; // YYYY-MM-DD
  final String hasta; // YYYY-MM-DD
  final List<DiaHorarioSemana> data;

  MiHorarioSemanaResponse({
    required this.success,
    required this.desde,
    required this.hasta,
    required this.data,
  });

  static bool _parseBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v.toString().trim().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes' || s == 'si';
  }

  factory MiHorarioSemanaResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['data'];
    final list = (raw is List) ? raw : const [];

    return MiHorarioSemanaResponse(
      success: _parseBool(json['success']),
      desde: (json['desde'] ?? '').toString(),
      hasta: (json['hasta'] ?? '').toString(),
      data:
          list
              .map(
                (e) => DiaHorarioSemana.fromJson(Map<String, dynamic>.from(e)),
              )
              .toList(),
    );
  }
}

class MiHorarioProvider extends GetConnect {
  final _box = GetStorage();

  String get _base =>
      Environment.API_URL.endsWith('/')
          ? Environment.API_URL
          : '${Environment.API_URL}/';

  String get _token => (_box.read('token') ?? '').toString();

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  Future<MiHorarioSemanaResponse> getMiHorarioSemana({
    required String fecha,
  }) async {
    // ✅ usa Uri para no romper query params
    final uri = Uri.parse(
      '${_base}turnos/mi-horario',
    ).replace(queryParameters: {'fecha': fecha});

    final res = await get(uri.toString(), headers: _headers);

    if (res.status.hasError) {
      throw Exception(res.bodyString ?? 'Error al obtener mi horario semanal');
    }

    return MiHorarioSemanaResponse.fromJson(
      Map<String, dynamic>.from(res.body),
    );
  }

  /// Guardar observación + solicitud horas acumuladas (HOY)
  Future<void> putObservacionHoy({
    required String observacion,
    required bool solicitarHoraAcumulada,
    int? numHorasAcumuladas,
  }) async {
    final url = '${_base}turnos/mi-horario/observacion';

    final body = <String, dynamic>{
      'observacion': observacion,
      'solicitar_hora_acumulada': solicitarHoraAcumulada,
      'num_horas_acumuladas':
          solicitarHoraAcumulada ? numHorasAcumuladas : null,
    };

    final res = await put(url, body, headers: _headers);

    if (res.status.hasError) {
      throw Exception(res.bodyString ?? 'Error al guardar');
    }
  }
}
