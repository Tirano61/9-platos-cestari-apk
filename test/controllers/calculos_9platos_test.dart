import 'package:flutter_test/flutter_test.dart';
import 'package:nueve_platos_cestari/Controllers/calculos_controllers.dart';

void main() {
  group('CalculosController (total y % en vivo)', () {
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

    setUp(() => calculos.setPesoTotalByList(pesos));

    test('total de los 9 platos', () {
      expect(calculos.pesoTotal, '1260.00');
    });

    test('subtotal de un juego', () {
      expect(calculos.calculoEje('110.00', '120.00'), '230.00');
      expect(calculos.calculoEje('170.00', '180.00'), '350.00');
    });

    test('porcentajes sobre el total', () {
      expect(calculos.calculoPorcentajePlatos('100.00'), '7.9');
      expect(calculos.calculoPorcentajePlatos('110.00'), '8.7');
      expect(calculos.calculoPorcentajePlatos('180.00'), '14.3');
      expect(calculos.calculoPorcentajePorEje('1', '110.00', '120.00'), '18.3');
      expect(calculos.calculoPorcentajePorEje('4', '170.00', '180.00'), '27.8');
      // Lados: izq 2+4+6+8 y der 3+5+7+9; el enganche no suma a ninguno.
      expect(calculos.porcentajePorLado('560.00'), '44.4');
      expect(calculos.porcentajePorLado('600.00'), '47.6');
    });

    test('con total cero los porcentajes son 0', () {
      calculos.setPesoTotalByList(List.filled(9, '0.00'));

      expect(calculos.pesoTotal, '0.00');
      expect(calculos.calculoPorcentajePlatos('0.00'), '0');
      expect(calculos.calculoPorcentajePorEje('1', '0.00', '0.00'), '0');
      expect(calculos.porcentajePorLado('0.00'), '0');
    });

    test('un peso invalido cuenta como 0 en el total y los %', () {
      calculos.setPesoTotalByList(
        ['100.00', '', '50.00', '0.00', '0.00', '0.00', '0.00', '0.00', '0.00'],
      );

      expect(calculos.pesoTotal, '150.00');
      expect(calculos.calculoPorcentajePlatos(''), '0.0');
      expect(calculos.calculoPorcentajePorEje('1', '', '50.00'), '33.3');
    });
  });
}
