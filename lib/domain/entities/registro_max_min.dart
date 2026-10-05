/// Maximo y minimo de los pesos de un plato durante una maniobra.
///
/// Clase pura (sin GetX): [PesoController] le pasa cada peso que llega por UDP
/// mientras registra. No guarda las lecturas, solo cuantas hubo.
class RegistroMaxMin {

  double _maximo = 0;
  double _minimo = 0;
  int _lecturas = 0;

  /// Mayor peso registrado (0 si no hay datos).
  double get maximo => _maximo;

  /// Menor peso registrado (0 si no hay datos).
  double get minimo => _minimo;

  /// Cantidad de pesos registrados.
  int get lecturas => _lecturas;

  bool get hayDatos => _lecturas > 0;

  void registrar(double peso) {
    if (!hayDatos) {
      _maximo = peso;
      _minimo = peso;
    } else {
      if (peso > _maximo) _maximo = peso;
      if (peso < _minimo) _minimo = peso;
    }
    _lecturas++;
  }

  void reiniciar() {
    _maximo = 0;
    _minimo = 0;
    _lecturas = 0;
  }
}
