/// Firmware del indicador: define de donde se lee la calibracion.
enum FirmwareCalibracion {
  /// `GET /config?json=1`, JSON plano.
  clasico,

  /// `GET /configjson?json=1`, JSON anidado con `{type, value}`.
  esp32,
}

/// Calibracion de un plato, comun a los dos firmwares (seccion 2.4 de
/// docs/CALIBRACION_WIFI.md). Es lo que muestra la pantalla y lo que se envia
/// con `/save`. Un campo queda null si el firmware no lo mando.
class CalibracionModel {
  const CalibracionModel({
    required this.firmware,
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
  });

  final FirmwareCalibracion firmware;

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

  /// Solo lectura: no se envia por WiFi.
  final double? capacidadMaxima;

  /// Los 10 campos que se envian tienen valor.
  bool get completa =>
      totalCelda != null &&
      sensibilidad != null &&
      division != null &&
      conversiones != null &&
      recortes != null &&
      ventanaMovil != null &&
      kgFiltro != null &&
      correccion != null &&
      tiempoEstable != null &&
      kgResetHold != null;

  /// Parametros de `GET /save`, en el orden del documento. Los nombres no son
  /// los de la lectura (ojo con `gkfiltro`). Los decimales van con punto y un
  /// decimal entero como `10.0`. Sin `capacidad_maxima`.
  /// Lanza [StateError] si no esta [completa]: nunca se manda `null` en la URL.
  Map<String, String> toSaveQuery() {
    if (!completa) {
      throw StateError('Calibracion incompleta: no se puede enviar');
    }
    return {
      'celdas': '$totalCelda',
      'sensibilidad': '$sensibilidad',
      'division': division!.toString(),
      'conversiones': '$conversiones',
      'recortes': '$recortes',
      'ventanam': '$ventanaMovil',
      'gkfiltro': '$kgFiltro',
      'correccion': correccion!.toString(),
      'tiempoestable': '$tiempoEstable',
      'resethold': kgResetHold!.toString(),
    };
  }

  CalibracionModel copyWith({
    FirmwareCalibracion? firmware,
    int? totalCelda,
    int? sensibilidad,
    double? division,
    int? conversiones,
    int? recortes,
    int? ventanaMovil,
    int? kgFiltro,
    double? correccion,
    int? tiempoEstable,
    double? kgResetHold,
    double? capacidadMaxima,
  }) =>
      CalibracionModel(
        firmware: firmware ?? this.firmware,
        totalCelda: totalCelda ?? this.totalCelda,
        sensibilidad: sensibilidad ?? this.sensibilidad,
        division: division ?? this.division,
        conversiones: conversiones ?? this.conversiones,
        recortes: recortes ?? this.recortes,
        ventanaMovil: ventanaMovil ?? this.ventanaMovil,
        kgFiltro: kgFiltro ?? this.kgFiltro,
        correccion: correccion ?? this.correccion,
        tiempoEstable: tiempoEstable ?? this.tiempoEstable,
        kgResetHold: kgResetHold ?? this.kgResetHold,
        capacidadMaxima: capacidadMaxima ?? this.capacidadMaxima,
      );
}
