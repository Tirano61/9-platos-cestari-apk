import 'package:nueve_platos_cestari/models/calibracion/calibracion_model.dart';

/// Respuesta de `GET /config?json=1` (firmware clasico): JSON plano con
/// valores numericos (seccion 2.2 de docs/CALIBRACION_WIFI.md).
class CalibracionClasicaModel {
  const CalibracionClasicaModel({
    this.totalCelda,
    this.sensibilidad,
    this.division,
    this.conversiones,
    this.recortes,
    this.ventanaMovil,
    this.kgFiltro,
    this.correccion,
    this.tiempoEstable,
    this.kgResetHold,
    this.capacidadMaxima,
    this.invertido,
    this.unidad,
    this.logicaSensor,
    this.tipoPeso,
    this.teclado,
    this.alimentacion,
  });

  /// Los numeros se leen como `num`, asi los decimales aceptan `1` y `1.0`.
  /// Una clave que falta o que no es numerica queda null.
  factory CalibracionClasicaModel.fromJson(Map<String, dynamic> json) => CalibracionClasicaModel(
        totalCelda: _entero(json['total_celda']),
        sensibilidad: _entero(json['sensibilidad']),
        division: _decimal(json['division']),
        conversiones: _entero(json['conversiones']),
        recortes: _entero(json['recortes']),
        ventanaMovil: _entero(json['ventana_movil']),
        kgFiltro: _entero(json['kg_filtro']),
        correccion: _decimal(json['correccion']),
        tiempoEstable: _entero(json['tiempo_estable']),
        kgResetHold: _decimal(json['kg_reset_hold']),
        capacidadMaxima: _decimal(json['capacidad_maxima']),
        invertido: _entero(json['invertido']),
        unidad: _entero(json['unidad']),
        logicaSensor: _entero(json['logica_sensor']),
        tipoPeso: _entero(json['tipo_peso']),
        teclado: _entero(json['teclado']),
        alimentacion: _entero(json['alimentacion']),
      );

  final int? totalCelda;
  final int? sensibilidad;
  final double? division;
  final int? conversiones;
  final int? recortes;
  final int? ventanaMovil;
  final int? kgFiltro;
  final double? correccion;
  final int? tiempoEstable;
  final double? kgResetHold;
  final double? capacidadMaxima;

  /// Se leen pero no se muestran ni se envian.
  final int? invertido;
  final int? unidad;
  final int? logicaSensor;
  final int? tipoPeso;
  final int? teclado;
  final int? alimentacion;

  CalibracionModel toCalibracion() => CalibracionModel(
        firmware: FirmwareCalibracion.clasico,
        totalCelda: totalCelda,
        sensibilidad: sensibilidad,
        division: division,
        conversiones: conversiones,
        recortes: recortes,
        ventanaMovil: ventanaMovil,
        kgFiltro: kgFiltro,
        correccion: correccion,
        tiempoEstable: tiempoEstable,
        kgResetHold: kgResetHold,
        capacidadMaxima: capacidadMaxima,
      );

  static int? _entero(dynamic valor) => valor is num ? valor.toInt() : null;

  static double? _decimal(dynamic valor) => valor is num ? valor.toDouble() : null;
}
