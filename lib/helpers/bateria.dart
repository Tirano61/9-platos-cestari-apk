


abstract class Bateria{

  /// Voltaje de bateria cargada (100 %).
  static const max = 4.2;
  /// Voltaje de bateria descargada (0 %).
  static const min = 3.0;

  ///
  ///  `Porcentaje de bateria`
  ///
  /// Devuelve un número entre 0 y 100 según el voltaje recibido del plato.
  /// Por encima de [max] queda en 100
  /// y por debajo de [min] queda en 0.
  ///
  static int porcentaje(double voltaje) {
    final porcent = (voltaje - min) / (max - min) * 100;
    return porcent.round().clamp(0, 100);
  }

}
