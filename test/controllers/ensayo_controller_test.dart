import 'package:nueve_platos_cestari/Controllers/config_controller.dart';
import 'package:nueve_platos_cestari/Controllers/ensayo_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso_controller.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

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

  group('Maniobra', () {
    late List<PesoController> platos;
    late EnsayoController ensayo;

    setUp(() {
      // PesoController busca el ConfigController; no se abre UDP.
      Get.put(ConfigController());
      platos = [for (var n = 1; n <= cantidadPlatos; n++) PesoController(plato: n)];
      ensayo = EnsayoController(
        leerPesos: () => ['850', '2410', '2400', '2400', '2400', '2400', '2400', '2400', '0'],
        platos: () => platos,
      );
      ensayo.iniciarEnsayo(
        tolva: 'TC-1',
        capacidades: ['3000', '5000', '5000', '5000', '5000', '5000', '5000', '5000', ''],
        umbral: '90',
      );
    });
    tearDown(Get.reset);

    test('Sin estatico no se puede iniciar', () {
      ensayo.iniciarManiobra();
      expect(ensayo.registrando, false);
      expect(ensayo.numeroManiobra.value, 0);
      expect(platos.any((p) => p.registrando), false);
      expect(ensayo.terminarManiobra(), isNull);
    });

    test('Iniciar pone a registrar los 9 platos y numera la maniobra', () {
      ensayo.tomarEstatico();
      ensayo.iniciarManiobra();

      expect(ensayo.estado.value, EstadoEnsayo.registrando);
      expect(ensayo.numeroManiobra.value, 1);
      expect(ensayo.inicioManiobra.value, isNotNull);
      expect(platos.every((p) => p.registrando), true);

      // Con una maniobra en curso no arranca otra.
      ensayo.iniciarManiobra();
      expect(ensayo.numeroManiobra.value, 1);
    });

    test('Terminar arma el resultado con estatico, max / min y capacidades', () {
      ensayo.tomarEstatico();
      ensayo.iniciarManiobra();
      for (final peso in ['2410.00', '5980.00', '1800.00']) {
        platos[1].registrarLectura(peso);
      }
      platos[8].registrarLectura('300.00');

      final resultado = ensayo.terminarManiobra()!;
      expect(resultado.numero, 1);
      expect(resultado.fin.isBefore(resultado.inicio), false);
      expect(resultado.platos.length, cantidadPlatos);
      expect(ensayo.estado.value, EstadoEnsayo.listo);
      expect(ensayo.inicioManiobra.value, isNull);
      expect(platos.any((p) => p.registrando), false);

      final c2 = resultado.platos[1];
      expect(c2.plato, 2);
      expect(c2.estatico, '2410.00');
      expect(c2.maximo, '5980.00');
      expect(c2.minimo, '1800.00');
      expect(c2.lecturas, 3);
      expect(c2.capacidad, '5000');
      expect(c2.estado(ensayo.umbral.value), EstadoCelda.excede);

      // Plato sin lecturas.
      final enganche = resultado.platos[0];
      expect(enganche.maximo, '');
      expect(enganche.lecturas, 0);

      // Plato 9: estatico 0 y sin capacidad.
      final c9 = resultado.platos[8];
      expect(c9.factorCresta, '-');
      expect(c9.estado('90'), EstadoCelda.sinDato);

      // La siguiente es la 2.
      ensayo.iniciarManiobra();
      expect(ensayo.numeroManiobra.value, 2);
    });

    test('Descartar corta el registro y libera el numero', () {
      ensayo.tomarEstatico();
      ensayo.iniciarManiobra();
      ensayo.descartarManiobra();

      expect(ensayo.estado.value, EstadoEnsayo.listo);
      expect(ensayo.numeroManiobra.value, 0);
      expect(platos.any((p) => p.registrando), false);

      ensayo.iniciarManiobra();
      expect(ensayo.numeroManiobra.value, 1);
    });

    test('Un ensayo nuevo descarta la maniobra y reinicia la numeracion', () {
      ensayo.tomarEstatico();
      ensayo.iniciarManiobra();
      ensayo.iniciarEnsayo(
        tolva: 'TC-2',
        capacidades: List.filled(cantidadPlatos, ''),
        umbral: '90',
      );
      expect(ensayo.estado.value, EstadoEnsayo.sinEstatico);
      expect(ensayo.numeroManiobra.value, 0);
      expect(platos.any((p) => p.registrando), false);
    });
  });
}
