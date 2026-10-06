import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:nueve_platos_cestari/models/calibracion/calibracion_clasica_model.dart';
import 'package:nueve_platos_cestari/models/calibracion/calibracion_esp32_model.dart';
import 'package:nueve_platos_cestari/models/calibracion/calibracion_model.dart';

/// Lee y envia la calibracion de un plato por HTTP (docs/CALIBRACION_WIFI.md).
///
/// Todas las peticiones tienen timeout y los errores de red se capturan: un
/// plato apagado devuelve null / false, nunca una excepcion.
class CalibracionWifi {
  CalibracionWifi({http.Client? cliente, this.timeout = const Duration(seconds: 5)})
      : _cliente = cliente ?? http.Client();

  final http.Client _cliente;
  final Duration timeout;

  /// Prueba `/config?json=1` (firmware clasico) y, si falla por cualquier
  /// motivo (tambien un codigo distinto de 200), `/configjson?json=1` (ESP32).
  /// null si no se pudo leer de ninguno.
  Future<CalibracionModel?> leer(String ip) async {
    final clasica = await _leerJson(Uri.http(ip, '/config', {'json': '1'}));
    if (clasica != null) {
      return CalibracionClasicaModel.fromJson(clasica).toCalibracion();
    }

    final esp32 = await _leerJson(Uri.http(ip, '/configjson', {'json': '1'}));
    if (esp32 == null) return null;
    try {
      return CalibracionEsp32Model.fromJson(esp32).toCalibracion();
    } on FormatException {
      return null;
    }
  }

  /// Manda los 10 parametros con `/save` y, si responde 200, reinicia el
  /// indicador con `/save?reset=1` (sin revisar su respuesta). Con una
  /// calibracion incompleta no manda nada. Devuelve si se guardo.
  Future<bool> enviar(String ip, CalibracionModel calibracion) async {
    if (!calibracion.completa) return false;

    final guardado = await _get(Uri.http(ip, '/save', calibracion.toSaveQuery()));
    if (guardado?.statusCode != 200) return false;

    await _get(Uri.http(ip, '/save', {'reset': '1'}));
    return true;
  }

  void cerrar() => _cliente.close();

  /// El JSON de [uri] si responde 200 con un objeto; si no, null.
  Future<Map<String, dynamic>?> _leerJson(Uri uri) async {
    final respuesta = await _get(uri);
    if (respuesta?.statusCode != 200) return null;
    try {
      final json = jsonDecode(respuesta!.body);
      return json is Map<String, dynamic> ? json : null;
    } on FormatException {
      return null;
    }
  }

  /// null si falla la conexion o se agota el tiempo.
  Future<http.Response?> _get(Uri uri) async {
    try {
      return await _cliente.get(uri).timeout(timeout);
    } on Exception {
      return null;
    }
  }
}
