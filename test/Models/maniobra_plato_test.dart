import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';
import 'package:flutter_test/flutter_test.dart';

ManiobraPlato _plato({
  String estatico = '2410.00',
  String maximo = '5980.00',
  String capacidad = '5000',
}) =>
    ManiobraPlato(
      plato: 2,
      estatico: estatico,
      maximo: maximo,
      minimo: '1800.00',
      lecturas: 120,
      capacidad: capacidad,
    );

void main() {
  test('Ejemplo del documento: C2 da FC 2.48, 119.6 % y EXCEDE', () {
    final plato = _plato();
    expect(plato.factorCresta, '2.48');
    expect(plato.porCapacidad, '119.6');
    expect(plato.estado('90'), EstadoCelda.excede);
    expect(plato.estado('90').texto, 'EXCEDE');
  });

  test('Exactamente 100 % es AL LIMITE, apenas mas EXCEDE', () {
    expect(_plato(maximo: '5000.00').porCapacidad, '100.0');
    expect(_plato(maximo: '5000.00').estado('90'), EstadoCelda.alLimite);
    expect(_plato(maximo: '5005.00').estado('90'), EstadoCelda.excede);
  });

  test('Igual al umbral es AL LIMITE, debajo NORMAL', () {
    expect(_plato(maximo: '4500.00').porCapacidad, '90.0');
    expect(_plato(maximo: '4500.00').estado('90'), EstadoCelda.alLimite);
    expect(_plato(maximo: '4495.00').estado('90'), EstadoCelda.normal);
    expect(_plato(maximo: '4495.00').estado('90').texto, 'NORMAL');
  });

  test('El estado usa el % redondeado que se muestra', () {
    // 100.04 % se muestra 100.0: no excede.
    expect(_plato(maximo: '5002.00').porCapacidad, '100.0');
    expect(_plato(maximo: '5002.00').estado('90'), EstadoCelda.alLimite);
    // 89.96 % se muestra 90.0: llega al umbral.
    expect(_plato(maximo: '4498.00').estado('90'), EstadoCelda.alLimite);
  });

  test('Capacidad vacia, 0 o invalida: sin % ni estado', () {
    for (final capacidad in ['', '0', '0.00', 'abc']) {
      final plato = _plato(capacidad: capacidad);
      expect(plato.porCapacidad, '-', reason: capacidad);
      expect(plato.estado('90'), EstadoCelda.sinDato, reason: capacidad);
      expect(plato.estado('90').texto, '-');
      // El factor de cresta no depende de la capacidad.
      expect(plato.factorCresta, '2.48');
    }
  });

  test('Estatico 0 o negativo: sin factor de cresta', () {
    expect(_plato(estatico: '0.00').factorCresta, '-');
    expect(_plato(estatico: '-5.00').factorCresta, '-');
    expect(_plato(estatico: '0.00').porCapacidad, '119.6');
  });

  test('Plato sin lecturas en la maniobra: todo en -', () {
    final plato = _plato(maximo: '');
    expect(plato.factorCresta, '-');
    expect(plato.porCapacidad, '-');
    expect(plato.estado('90'), EstadoCelda.sinDato);
  });

  test('Umbral invalido: solo distingue EXCEDE de NORMAL', () {
    expect(_plato(maximo: '4900.00').estado(''), EstadoCelda.normal);
    expect(_plato(maximo: '5980.00').estado(''), EstadoCelda.excede);
  });
}
