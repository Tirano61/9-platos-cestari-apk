import 'dart:typed_data';

import 'package:nueve_platos_cestari/models/calibracion/calibracion_model.dart';

/// Decimal que el firmware ESP32 manda como `u64`: los 32 bits bajos de
/// [value] son un float IEEE-754 (como `Float.intBitsToFloat`). Redondeado a
/// 2 decimales. null si [value] no es un entero o el float no es finito.
double? floatDesdeU64(String value) {
  final n = BigInt.tryParse(value.trim());
  if (n == null) return null;
  final bits = (n & BigInt.from(0xFFFFFFFF)).toInt();
  final datos = ByteData(4)..setUint32(0, bits);
  final valor = datos.getFloat32(0);
  if (!valor.isFinite) return null;
  return double.parse(valor.toStringAsFixed(2));
}

/// Respuesta de `GET /configjson?json=1` (firmware ESP32): los datos van en
/// `Configuracion.Balanza` y cada campo es `{type, value}` con `value` como
/// texto (seccion 2.3 de docs/CALIBRACION_WIFI.md).
class CalibracionEsp32Model {
  const CalibracionEsp32Model({
    this.totalCelda,
    this.sensiCelda,
    this.sizeConv,
    this.sizeRecortes,
    this.sizeVentMovil,
    this.timeEstabilidad,
    this.capMax,
    this.divisiones,
    this.factorCorrec,
    this.kgFiltroMov,
    this.pIniCalcH,
  });

  /// Lanza [FormatException] si no existe `Configuracion.Balanza`.
  factory CalibracionEsp32Model.fromJson(Map<String, dynamic> json) {
    final configuracion = json['Configuracion'];
    final balanza = configuracion is Map ? configuracion['Balanza'] : null;
    if (balanza is! Map) {
      throw const FormatException('Respuesta ESP32 sin Configuracion.Balanza');
    }
    return CalibracionEsp32Model(
      totalCelda: _entero(balanza['totalCelda']),
      sensiCelda: _entero(balanza['sensiCelda']),
      sizeConv: _entero(balanza['sizeConv']),
      sizeRecortes: _entero(balanza['sizeRecortes']),
      sizeVentMovil: _entero(balanza['sizeVentMovil']),
      timeEstabilidad: _entero(balanza['timeEstabilidad']),
      capMax: _entero(balanza['capMax'])?.toDouble(),
      divisiones: _u64(balanza['divisiones']),
      factorCorrec: _u64(balanza['factorCorrec']),
      kgFiltroMov: _u64(balanza['kgFiltroMov'])?.truncate(),
      pIniCalcH: _u64(balanza['pIniCalcH']),
    );
  }

  final int? totalCelda;
  final int? sensiCelda;
  final int? sizeConv;
  final int? sizeRecortes;
  final int? sizeVentMovil;
  final int? timeEstabilidad;

  /// Llega como entero y se usa como decimal.
  final double? capMax;

  /// Decodificados de `u64` con [floatDesdeU64].
  final double? divisiones;
  final double? factorCorrec;
  final double? pIniCalcH;

  /// Decodificado de `u64` y truncado a entero.
  final int? kgFiltroMov;

  CalibracionModel toCalibracion() => CalibracionModel(
        firmware: FirmwareCalibracion.esp32,
        totalCelda: totalCelda,
        sensibilidad: sensiCelda,
        division: divisiones,
        conversiones: sizeConv,
        recortes: sizeRecortes,
        ventanaMovil: sizeVentMovil,
        kgFiltro: kgFiltroMov,
        correccion: factorCorrec,
        tiempoEstable: timeEstabilidad,
        kgResetHold: pIniCalcH,
        capacidadMaxima: capMax,
      );

  /// `value` del campo como texto, o null si el campo no es `{type, value}`.
  static String? _valor(dynamic campo) => campo is Map ? campo['value']?.toString() : null;

  static int? _entero(dynamic campo) {
    final valor = _valor(campo);
    return valor == null ? null : int.tryParse(valor.trim());
  }

  /// Solo se decodifica si `type == 'u64'`; si no, queda vacio.
  static double? _u64(dynamic campo) {
    if (campo is! Map || campo['type'] != 'u64') return null;
    final valor = _valor(campo);
    return valor == null ? null : floatDesdeU64(valor);
  }
}
