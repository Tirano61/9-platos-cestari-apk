import 'package:flutter_test/flutter_test.dart';
import 'package:nueve_platos_cestari/Controllers/calculos_controllers.dart';

void main() {
  group('CalculosController.calcularPayload9Platos', () {
    final calculos = CalculosController.cn;

    // enganche, J1 IZQ, J1 DER, J2 IZQ, J2 DER, J3 IZQ, J3 DER, J4 IZQ, J4 DER
    const pesos = [
      '100.00',
      '110.00',
      '120.00',
      '130.00',
      '140.00',
      '150.00',
      '160.00',
      '170.00',
      '180.00',
    ];

    test('total de los 9 platos y tipo 9_platos', () async {
      final payload = await calculos.calcularPayload9Platos(pesos: pesos);

      expect(payload.base.total, '1260.00');
      expect(calculos.pesoTotal, '1260.00');
      expect(payload.base.tipoPesada, '9_platos');
      expect(payload.base.identificacion, '');
    });

    test('pesos de cada plato en su campo', () async {
      final d = (await calculos.calcularPayload9Platos(pesos: pesos)).detalle;

      expect(d.enganche, '100.00');
      expect([d.j1Izq, d.j1Der], ['110.00', '120.00']);
      expect([d.j2Izq, d.j2Der], ['130.00', '140.00']);
      expect([d.j3Izq, d.j3Der], ['150.00', '160.00']);
      expect([d.j4Izq, d.j4Der], ['170.00', '180.00']);
    });

    test('juegos y lados (el enganche no suma a ningun lado)', () async {
      final d = (await calculos.calcularPayload9Platos(pesos: pesos)).detalle;

      expect(d.juego1, '230.00');
      expect(d.juego2, '270.00');
      expect(d.juego3, '310.00');
      expect(d.juego4, '350.00');
      expect(d.ladoIzq, '560.00');
      expect(d.ladoDer, '600.00');
    });

    test('porcentajes sobre el total', () async {
      final d = (await calculos.calcularPayload9Platos(pesos: pesos)).detalle;

      expect(d.porEnganche, '7.9');
      expect(d.porJ1Izq, '8.7');
      expect(d.porJ1Der, '9.5');
      expect(d.porJ4Der, '14.3');
      expect(d.porJuego1, '18.3');
      expect(d.porJuego2, '21.4');
      expect(d.porJuego3, '24.6');
      expect(d.porJuego4, '27.8');
      expect(d.porLadoIzq, '44.4');
      expect(d.porLadoDer, '47.6');
    });

    test('con total cero los porcentajes son 0', () async {
      final d = (await calculos.calcularPayload9Platos(
        pesos: List.filled(9, '0.00'),
      )).detalle;

      expect(d.porEnganche, '0');
      expect(d.porJuego1, '0');
      expect(d.porLadoIzq, '0');
      expect(d.ladoDer, '0.00');
    });

    test('un peso invalido cuenta como 0 en juegos, lados y total', () async {
      final payload = await calculos.calcularPayload9Platos(
        pesos: ['100.00', '', '50.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00'],
      );

      expect(payload.base.total, '150.00');
      expect(payload.detalle.juego1, '50.00');
      expect(payload.detalle.ladoIzq, '0.00');
      expect(payload.detalle.porLadoDer, '33.3');
    });
  });
}
