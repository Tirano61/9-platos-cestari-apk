import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/helpers/preferencias_ensayo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('Sin datos guardados: capacidades vacias y umbral 90', () async {
    final capacidades = await PreferenciasEnsayo.leerCapacidades();
    expect(capacidades, List.filled(cantidadPlatos, ''));
    expect(await PreferenciasEnsayo.leerUmbral(), '90');
  });

  test('Guardar y volver a leer', () async {
    final capacidades = ['3000', '5000', '5000', '5000', '5000', '', '5000', '4500', '4500'];
    await PreferenciasEnsayo.guardar(capacidades: capacidades, umbral: '85');

    expect(await PreferenciasEnsayo.leerCapacidades(), capacidades);
    expect(await PreferenciasEnsayo.leerUmbral(), '85');
  });

  test('Guardar de nuevo pisa los valores anteriores', () async {
    await PreferenciasEnsayo.guardar(
      capacidades: List.filled(cantidadPlatos, '1000'),
      umbral: '80',
    );
    final nuevas = List.generate(cantidadPlatos, (i) => '${(i + 1) * 100}');
    await PreferenciasEnsayo.guardar(capacidades: nuevas, umbral: '95');

    expect(await PreferenciasEnsayo.leerCapacidades(), nuevas);
    expect(await PreferenciasEnsayo.leerUmbral(), '95');
  });

  test('Claves: capacidad_plato1..9 y umbral_alarma', () async {
    await PreferenciasEnsayo.guardar(
      capacidades: List.generate(cantidadPlatos, (i) => 'c${i + 1}'),
      umbral: '70',
    );
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('capacidad_plato1'), 'c1');
    expect(prefs.getString('capacidad_plato9'), 'c9');
    expect(prefs.getString('umbral_alarma'), '70');
  });

  test('Lee lo que ya estaba guardado de antes', () async {
    SharedPreferences.setMockInitialValues({
      'capacidad_plato2': '5000',
      'umbral_alarma': '75',
    });
    final capacidades = await PreferenciasEnsayo.leerCapacidades();
    expect(capacidades[0], '');
    expect(capacidades[1], '5000');
    expect(await PreferenciasEnsayo.leerUmbral(), '75');
  });
}
