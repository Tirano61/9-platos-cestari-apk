import 'package:nueve_platos_cestari/Controllers/ensayo_controller.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Sin ensayo iniciado: tolva y capacidades vacias, umbral 90', () {
    final ensayo = EnsayoController();
    expect(ensayo.tolva.value, '');
    expect(ensayo.capacidades, List.filled(cantidadPlatos, ''));
    expect(ensayo.umbral.value, '90');
  });

  test('iniciarEnsayo guarda tolva, capacidades y umbral', () {
    final ensayo = EnsayoController();
    final capacidades = ['3000', '5000', '5000', '', '5000', '5000', '5000', '4500', '4500'];
    ensayo.iniciarEnsayo(tolva: 'TC-123', capacidades: capacidades, umbral: '85');

    expect(ensayo.tolva.value, 'TC-123');
    expect(ensayo.capacidades, capacidades);
    expect(ensayo.umbral.value, '85');

    // Un segundo ensayo pisa los valores del anterior.
    ensayo.iniciarEnsayo(
      tolva: 'TC-456',
      capacidades: List.filled(cantidadPlatos, '1000'),
      umbral: '95',
    );
    expect(ensayo.tolva.value, 'TC-456');
    expect(ensayo.capacidades, List.filled(cantidadPlatos, '1000'));
    expect(ensayo.umbral.value, '95');
  });

  test('Sin estatico: estado sinEstatico y lineas vacias', () {
    final ensayo = EnsayoController(leerPesos: () => List.filled(cantidadPlatos, '0'));
    expect(ensayo.hayEstatico, false);
    expect(ensayo.estado.value, EstadoEnsayo.sinEstatico);
    expect(ensayo.estatico(1), '');
  });

  test('tomarEstatico guarda los 9 pesos con 2 decimales y pasa a listo', () {
    var pesos = ['850', '2410.00', '2390.5', 'abc', '', '2400.00', '2405.00', '2380.00', '2395.00'];
    final ensayo = EnsayoController(leerPesos: () => pesos);
    ensayo.tomarEstatico();

    expect(ensayo.estado.value, EstadoEnsayo.listo);
    expect(ensayo.estaticos, [
      '850.00', '2410.00', '2390.50', '0.00', '0.00', '2400.00', '2405.00', '2380.00', '2395.00',
    ]);
    expect(ensayo.estatico(2), '2410.00');
    expect(ensayo.estatico(9), '2395.00');

    // Volver a tomarlo pisa el anterior.
    pesos = List.filled(cantidadPlatos, '100');
    ensayo.tomarEstatico();
    expect(ensayo.estaticos, List.filled(cantidadPlatos, '100.00'));
  });

  test('borrarEstatico avisa si habia uno y vuelve a sinEstatico', () {
    final ensayo = EnsayoController(leerPesos: () => List.filled(cantidadPlatos, '10'));
    expect(ensayo.borrarEstatico(), false);

    ensayo.tomarEstatico();
    expect(ensayo.borrarEstatico(), true);
    expect(ensayo.hayEstatico, false);
    expect(ensayo.estatico(1), '');
    expect(ensayo.estado.value, EstadoEnsayo.sinEstatico);
  });

  test('Un ensayo nuevo borra el estatico del anterior', () {
    final ensayo = EnsayoController(leerPesos: () => List.filled(cantidadPlatos, '10'))
      ..tomarEstatico();
    ensayo.iniciarEnsayo(
      tolva: 'TC-789',
      capacidades: List.filled(cantidadPlatos, ''),
      umbral: '90',
    );
    expect(ensayo.hayEstatico, false);
    expect(ensayo.estado.value, EstadoEnsayo.sinEstatico);
  });
}
