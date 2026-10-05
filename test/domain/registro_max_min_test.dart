import 'package:nueve_platos_cestari/domain/entities/registro_max_min.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Sin lecturas: no hay datos y max / min en 0', () {
    final registro = RegistroMaxMin();
    expect(registro.hayDatos, false);
    expect(registro.lecturas, 0);
    expect(registro.maximo, 0);
    expect(registro.minimo, 0);
  });

  test('La primera lectura es el maximo y el minimo', () {
    final registro = RegistroMaxMin()..registrar(2410);
    expect(registro.hayDatos, true);
    expect(registro.lecturas, 1);
    expect(registro.maximo, 2410);
    expect(registro.minimo, 2410);
  });

  test('Secuencia de pesos', () {
    final registro = RegistroMaxMin();
    for (final peso in [2410.0, 3100.5, 5980.0, 1800.25, 2400.0]) {
      registro.registrar(peso);
    }
    expect(registro.lecturas, 5);
    expect(registro.maximo, 5980.0);
    expect(registro.minimo, 1800.25);
  });

  test('Con pesos positivos el minimo no queda en 0', () {
    final registro = RegistroMaxMin()
      ..registrar(1500)
      ..registrar(1200);
    expect(registro.minimo, 1200);
  });

  test('Negativos', () {
    final registro = RegistroMaxMin()
      ..registrar(-5)
      ..registrar(-20.5)
      ..registrar(-1);
    expect(registro.maximo, -1);
    expect(registro.minimo, -20.5);

    registro.registrar(10);
    expect(registro.maximo, 10);
    expect(registro.minimo, -20.5);
    expect(registro.lecturas, 4);
  });

  test('Reiniciar borra todo y la siguiente lectura vuelve a ser max y min', () {
    final registro = RegistroMaxMin()
      ..registrar(5000)
      ..registrar(100);
    registro.reiniciar();
    expect(registro.hayDatos, false);
    expect(registro.lecturas, 0);
    expect(registro.maximo, 0);
    expect(registro.minimo, 0);

    registro.registrar(3000);
    expect(registro.maximo, 3000);
    expect(registro.minimo, 3000);
    expect(registro.lecturas, 1);
  });
}
