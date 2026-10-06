import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nueve_platos_cestari/Providers/calibracion_wifi.dart';
import 'package:nueve_platos_cestari/models/calibracion/calibracion_model.dart';
import 'package:flutter_test/flutter_test.dart';

const _ip = '192.168.4.10';

const _jsonClasico = '{"total_celda": 4, "sensibilidad": 2000, "division": 0.5, "conversiones": 10, '
    '"recortes": 2, "ventana_movil": 8, "kg_filtro": 5, "correccion": 1, "tiempo_estable": 3, '
    '"kg_reset_hold": 10.0, "capacidad_maxima": 3000}';

const _jsonEsp32 = '{"Configuracion": {"Balanza": {'
    '"totalCelda": {"type": "u16", "value": "4"}, '
    '"sensiCelda": {"type": "u16", "value": "2000"}, '
    '"divisiones": {"type": "u64", "value": "1056964608"}, '
    '"factorCorrec": {"type": "u64", "value": "1065353216"}}}}';

/// La que muestra la URL de ejemplo de la seccion 3.1 del documento.
const _completa = CalibracionModel(
  firmware: FirmwareCalibracion.clasico,
  totalCelda: 4,
  sensibilidad: 2000,
  division: 0.5,
  conversiones: 10,
  recortes: 2,
  ventanaMovil: 8,
  kgFiltro: 5,
  correccion: 1.0,
  tiempoEstable: 3,
  kgResetHold: 10.0,
  capacidadMaxima: 3000,
);

/// Cliente falso: responde con [responder] y anota las URL pedidas.
({CalibracionWifi servicio, List<String> pedidas}) _servicio(
  FutureOr<http.Response> Function(Uri uri) responder, {
  Duration timeout = const Duration(seconds: 5),
}) {
  final pedidas = <String>[];
  final cliente = MockClient((request) async {
    pedidas.add(request.url.toString());
    return responder(request.url);
  });
  return (servicio: CalibracionWifi(cliente: cliente, timeout: timeout), pedidas: pedidas);
}

void main() {
  group('leer', () {
    test('Firmware clasico: con 200 en /config no prueba /configjson', () async {
      final s = _servicio((_) => http.Response(_jsonClasico, 200));

      final calibracion = await s.servicio.leer(_ip);

      expect(s.pedidas, ['http://$_ip/config?json=1']);
      expect(calibracion!.firmware, FirmwareCalibracion.clasico);
      expect(calibracion.totalCelda, 4);
      expect(calibracion.correccion, 1.0);
      expect(calibracion.capacidadMaxima, 3000);
      expect(calibracion.completa, true);
    });

    test('Si /config falla la conexion, lee /configjson como ESP32', () async {
      final s = _servicio((uri) {
        if (uri.path == '/config') throw const SocketException('sin conexion');
        return http.Response(_jsonEsp32, 200);
      });

      final calibracion = await s.servicio.leer(_ip);

      expect(s.pedidas, ['http://$_ip/config?json=1', 'http://$_ip/configjson?json=1']);
      expect(calibracion!.firmware, FirmwareCalibracion.esp32);
      expect(calibracion.totalCelda, 4);
      expect(calibracion.division, 0.5);
      expect(calibracion.correccion, 1.0);
    });

    test('Si /config responde 404, tambien prueba /configjson', () async {
      final s = _servicio((uri) =>
          uri.path == '/config' ? http.Response('no existe', 404) : http.Response(_jsonEsp32, 200));

      final calibracion = await s.servicio.leer(_ip);

      expect(calibracion!.firmware, FirmwareCalibracion.esp32);
    });

    test('Si /config devuelve un JSON que no se puede interpretar, prueba /configjson', () async {
      final s = _servicio((uri) =>
          uri.path == '/config' ? http.Response('<html>', 200) : http.Response(_jsonEsp32, 200));

      expect((await s.servicio.leer(_ip))!.firmware, FirmwareCalibracion.esp32);
    });

    test('Si /config no responde a tiempo, prueba /configjson', () async {
      final s = _servicio(
        (uri) async {
          if (uri.path == '/config') {
            await Future<void>.delayed(const Duration(milliseconds: 200));
            return http.Response(_jsonClasico, 200);
          }
          return http.Response(_jsonEsp32, 200);
        },
        timeout: const Duration(milliseconds: 20),
      );

      expect((await s.servicio.leer(_ip))!.firmware, FirmwareCalibracion.esp32);
    });

    test('ESP32 sin Configuracion.Balanza -> null', () async {
      final s = _servicio((uri) => uri.path == '/config'
          ? http.Response('', 404)
          : http.Response('{"Configuracion": {}}', 200));

      expect(await s.servicio.leer(_ip), isNull);
    });

    test('Si fallan los dos endpoints -> null', () async {
      final s = _servicio((uri) {
        if (uri.path == '/config') throw const SocketException('sin conexion');
        return http.Response('error', 500);
      });

      expect(await s.servicio.leer(_ip), isNull);
      expect(s.pedidas, hasLength(2));
    });
  });

  group('enviar', () {
    test('Manda la URL del documento y, con 200, el reset', () async {
      final s = _servicio((_) => http.Response('OK', 200));

      expect(await s.servicio.enviar(_ip, _completa), true);
      expect(s.pedidas, [
        'http://$_ip/save?celdas=4&sensibilidad=2000&division=0.5&conversiones=10&recortes=2'
            '&ventanam=8&gkfiltro=5&correccion=1.0&tiempoestable=3&resethold=10.0',
        'http://$_ip/save?reset=1',
      ]);
    });

    test('El resultado del reset no importa', () async {
      final s = _servicio((uri) {
        if (uri.queryParameters.containsKey('reset')) throw const SocketException('se reinicio');
        return http.Response('OK', 200);
      });

      expect(await s.servicio.enviar(_ip, _completa), true);
      expect(s.pedidas, hasLength(2));
    });

    test('Con un codigo distinto de 200 devuelve false y no manda el reset', () async {
      final s = _servicio((_) => http.Response('error', 500));

      expect(await s.servicio.enviar(_ip, _completa), false);
      expect(s.pedidas, hasLength(1));
    });

    test('Con un error de red devuelve false y no manda el reset', () async {
      final s = _servicio((_) => throw http.ClientException('sin conexion'));

      expect(await s.servicio.enviar(_ip, _completa), false);
      expect(s.pedidas, hasLength(1));
    });

    test('Con una calibracion incompleta no hace ninguna peticion', () async {
      final s = _servicio((_) => http.Response('OK', 200));
      const incompleta = CalibracionModel(firmware: FirmwareCalibracion.esp32, totalCelda: 4);

      expect(await s.servicio.enviar(_ip, incompleta), false);
      expect(s.pedidas, isEmpty);
    });
  });
}
