import 'dart:convert';

import 'package:nueve_platos_cestari/models/calibracion/calibracion_clasica_model.dart';
import 'package:nueve_platos_cestari/models/calibracion/calibracion_esp32_model.dart';
import 'package:nueve_platos_cestari/models/calibracion/calibracion_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ejemplo de la seccion 2.2 del documento, con `correccion` entero.
const _jsonClasico = '''
{
  "total_celda": 4,
  "sensibilidad": 2000,
  "division": 0.5,
  "conversiones": 10,
  "recortes": 2,
  "ventana_movil": 8,
  "kg_filtro": 5,
  "correccion": 1,
  "tiempo_estable": 3,
  "kg_reset_hold": 10.0,
  "capacidad_maxima": 3000,
  "invertido": 0,
  "unidad": 1,
  "logica_sensor": 0,
  "tipo_peso": 2,
  "teclado": 0,
  "alimentacion": 1
}
''';

/// Ejemplo de la seccion 2.3 del documento.
const _jsonEsp32 = '''
{
  "Configuracion": {
    "Balanza": {
      "totalCelda":      { "type": "u16", "value": "4" },
      "sensiCelda":      { "type": "u16", "value": "2000" },
      "sizeConv":        { "type": "u16", "value": "10" },
      "sizeRecortes":    { "type": "u16", "value": "2" },
      "sizeVentMovil":   { "type": "u16", "value": "8" },
      "timeEstabilidad": { "type": "u16", "value": "3" },
      "capMax":          { "type": "u16", "value": "3000" },
      "divisiones":      { "type": "u64", "value": "1056964608" },
      "factorCorrec":    { "type": "u64", "value": "1065353216" },
      "kgFiltroMov":     { "type": "u64", "value": "1084227584" },
      "pIniCalcH":       { "type": "u64", "value": "1092616192" }
    }
  }
}
''';

Map<String, dynamic> _decodificar(String json) => jsonDecode(json) as Map<String, dynamic>;

/// La que muestra la URL de ejemplo de la seccion 3.1.
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

void main() {
  group('Firmware clasico', () {
    test('Ejemplo del documento, con correccion entero', () {
      final clasica = CalibracionClasicaModel.fromJson(_decodificar(_jsonClasico));
      expect(clasica.invertido, 0);
      expect(clasica.unidad, 1);
      expect(clasica.logicaSensor, 0);
      expect(clasica.tipoPeso, 2);
      expect(clasica.teclado, 0);
      expect(clasica.alimentacion, 1);

      final cal = clasica.toCalibracion();
      expect(cal.firmware, FirmwareCalibracion.clasico);
      expect(cal.totalCelda, 4);
      expect(cal.sensibilidad, 2000);
      expect(cal.division, 0.5);
      expect(cal.conversiones, 10);
      expect(cal.recortes, 2);
      expect(cal.ventanaMovil, 8);
      expect(cal.kgFiltro, 5);
      expect(cal.correccion, isA<double>());
      expect(cal.correccion, 1.0);
      expect(cal.tiempoEstable, 3);
      expect(cal.kgResetHold, 10.0);
      expect(cal.capacidadMaxima, isA<double>());
      expect(cal.capacidadMaxima, 3000.0);
      expect(cal.completa, isTrue);
    });

    test('Claves que faltan o no son numeros quedan vacias', () {
      final cal = CalibracionClasicaModel.fromJson({
        'total_celda': 4,
        'division': 'x',
      }).toCalibracion();
      expect(cal.totalCelda, 4);
      expect(cal.division, isNull);
      expect(cal.sensibilidad, isNull);
      expect(cal.completa, isFalse);
    });
  });

  group('Firmware ESP32', () {
    test('Ejemplo del documento', () {
      final cal = CalibracionEsp32Model.fromJson(_decodificar(_jsonEsp32)).toCalibracion();
      expect(cal.firmware, FirmwareCalibracion.esp32);
      expect(cal.totalCelda, 4);
      expect(cal.sensibilidad, 2000);
      expect(cal.division, 0.5);
      expect(cal.conversiones, 10);
      expect(cal.recortes, 2);
      expect(cal.ventanaMovil, 8);
      expect(cal.kgFiltro, 5);
      expect(cal.correccion, 1.0);
      expect(cal.tiempoEstable, 3);
      expect(cal.kgResetHold, 10.0);
      expect(cal.capacidadMaxima, 3000.0);
      expect(cal.completa, isTrue);
    });

    test('Tabla de decodificacion de u64', () {
      expect(floatDesdeU64('1056964608'), 0.5);
      expect(floatDesdeU64('1065353216'), 1.0);
      expect(floatDesdeU64('1084227584'), 5.0);
      expect(floatDesdeU64('1092616192'), 10.0);
    });

    test('u64: solo cuentan los 32 bits bajos y se redondea a 2 decimales', () {
      // 0x1_3F800000: el bit 32 se descarta, queda 1.0.
      expect(floatDesdeU64('${0x13F800000}'), 1.0);
      // Mas grande que un int de Dart: igual se toman los 32 bits bajos.
      expect(floatDesdeU64('18446744070479937536'), 1.0); // 0xFFFFFFFF3F800000
      // 0x3F866666 = 1.05 en float, que no es exacto.
      expect(floatDesdeU64('${0x3F866666}'), 1.05);
      expect(floatDesdeU64('abc'), isNull);
      expect(floatDesdeU64('${0x7FC00000}'), isNull); // NaN
    });

    test('Un campo u64 cuyo type no es u64 queda vacio', () {
      final json = _decodificar(_jsonEsp32);
      final balanza = json['Configuracion']['Balanza'] as Map<String, dynamic>;
      balanza['divisiones'] = {'type': 'u32', 'value': '1056964608'};
      balanza['kgFiltroMov'] = {'type': 'u16', 'value': '5'};
      final cal = CalibracionEsp32Model.fromJson(json).toCalibracion();
      expect(cal.division, isNull);
      expect(cal.kgFiltro, isNull);
      expect(cal.correccion, 1.0);
      expect(cal.completa, isFalse);
    });

    test('kgFiltroMov se trunca a entero', () {
      final json = _decodificar(_jsonEsp32);
      final balanza = json['Configuracion']['Balanza'] as Map<String, dynamic>;
      balanza['kgFiltroMov'] = {'type': 'u64', 'value': '${0x40B66666}'}; // 5.7
      expect(CalibracionEsp32Model.fromJson(json).kgFiltroMov, 5);
    });

    test('Campos enteros que no son numeros o faltan quedan vacios', () {
      final json = _decodificar(_jsonEsp32);
      final balanza = json['Configuracion']['Balanza'] as Map<String, dynamic>;
      balanza['sensiCelda'] = {'type': 'u16', 'value': 'x'};
      balanza.remove('capMax');
      final cal = CalibracionEsp32Model.fromJson(json).toCalibracion();
      expect(cal.sensibilidad, isNull);
      expect(cal.capacidadMaxima, isNull);
      expect(cal.totalCelda, 4);
    });

    test('Sin Configuracion.Balanza es una respuesta invalida', () {
      expect(() => CalibracionEsp32Model.fromJson({}), throwsFormatException);
      expect(
        () => CalibracionEsp32Model.fromJson({'Configuracion': {}}),
        throwsFormatException,
      );
      expect(
        () => CalibracionEsp32Model.fromJson({'Configuracion': 'x'}),
        throwsFormatException,
      );
    });
  });

  group('CalibracionModel', () {
    test('toSaveQuery: nombres, orden y decimales como en la URL del documento', () {
      final query = _completa.toSaveQuery();
      expect(query.keys.toList(), [
        'celdas',
        'sensibilidad',
        'division',
        'conversiones',
        'recortes',
        'ventanam',
        'gkfiltro',
        'correccion',
        'tiempoestable',
        'resethold',
      ]);
      expect(
        Uri(queryParameters: query).query,
        'celdas=4&sensibilidad=2000&division=0.5&conversiones=10&recortes=2&ventanam=8'
        '&gkfiltro=5&correccion=1.0&tiempoestable=3&resethold=10.0',
      );
    });

    test('toSaveQuery no manda la capacidad maxima', () {
      expect(_completa.toSaveQuery().containsKey('capacidad_maxima'), isFalse);
      expect(_completa.toSaveQuery().values, isNot(contains('3000.0')));
    });

    test('completa es false con un campo vacio y toSaveQuery no arma la query', () {
      const incompleta = CalibracionModel(
        firmware: FirmwareCalibracion.esp32,
        totalCelda: 4,
        sensibilidad: 2000,
        division: 0.5,
        conversiones: 10,
        recortes: 2,
        ventanaMovil: 8,
        correccion: 1.0,
        tiempoEstable: 3,
        kgResetHold: 10.0,
      );
      expect(incompleta.completa, isFalse);
      expect(incompleta.toSaveQuery, throwsStateError);
    });

    test('La capacidad maxima no cuenta para completa', () {
      expect(CalibracionModel(
        firmware: _completa.firmware,
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
      ).completa, isTrue);
    });

    test('copyWith cambia solo lo pedido', () {
      final editada = _completa.copyWith(correccion: 1.05, kgFiltro: 7);
      expect(editada.correccion, 1.05);
      expect(editada.kgFiltro, 7);
      expect(editada.firmware, FirmwareCalibracion.clasico);
      expect(editada.toSaveQuery()['correccion'], '1.05');
      expect(editada.toSaveQuery()['celdas'], '4');
      expect(editada.capacidadMaxima, 3000.0);
    });
  });
}
