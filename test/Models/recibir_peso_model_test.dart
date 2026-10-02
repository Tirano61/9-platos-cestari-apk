


import 'package:nueve_platos_cestari/helpers/bateria.dart';
import 'package:nueve_platos_cestari/models/recibir_peso_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 3.0 V = 0 %, 4.2 V = 100 %, fuera de rango se recorta.
  test('Porcentaje de bateria entre 3.0 V y 4.2 V', () {
    expect(Bateria.porcentaje(3.0), 0);
    expect(Bateria.porcentaje(3.6), 50);
    expect(Bateria.porcentaje(4.2), 100);
  });

  test('Porcentaje de bateria fuera de rango', () {
    expect(Bateria.porcentaje(2.5), 0);
    expect(Bateria.porcentaje(0), 0);
    expect(Bateria.porcentaje(4.5), 100);
  });

  test('Nivel de bateria segun el voltaje', () {
    final recibirPeso = RecibirPesoModel();
    recibirPeso.setTension = '2.8';
    expect(recibirPeso.tension, 1);
    recibirPeso.setTension = '3.4';   // 33 %
    expect(recibirPeso.tension, 2);
    recibirPeso.setTension = '3.9';   // 75 %
    expect(recibirPeso.tension, 3);
    recibirPeso.setTension = '4.0';   // 83 %
    expect(recibirPeso.tension, 4);
    recibirPeso.setTension = '4.3';
    expect(recibirPeso.tension, 5);
    recibirPeso.setTension = 'x';
    expect(recibirPeso.tension, 0);
  });
}
