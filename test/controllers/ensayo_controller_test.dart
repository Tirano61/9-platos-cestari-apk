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
}
