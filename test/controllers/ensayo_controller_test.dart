import 'package:nueve_platos_cestari/Controllers/config_controller.dart';
import 'package:nueve_platos_cestari/Controllers/ensayo_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso_controller.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/services/ensayos/service_ensayos.dart';

import '../moks/db_ensayos_mock.dart';

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
    // Llamadas al wakelock: true = pantalla encendida.
    late List<bool> pantalla;
    late DbEnsayosMock db;

    setUp(() {
      pantalla = [];
      db = DbEnsayosMock();
      // PesoController busca el ConfigController; no se abre UDP.
      Get.put(ConfigController());
      platos = [for (var n = 1; n <= cantidadPlatos; n++) PesoController(plato: n)];
      ensayo = EnsayoController(
        leerPesos: () => ['850', '2410', '2400', '2400', '2400', '2400', '2400', '2400', '0'],
        platos: () => platos,
        pantallaEncendida: pantalla.add,
        ensayos: ServiceEnsayos(db),
      );
      ensayo.iniciarEnsayo(
        tolva: 'TC-1',
        capacidades: ['3000', '5000', '5000', '5000', '5000', '5000', '5000', '5000', ''],
        umbral: '90',
      );
    });
    tearDown(Get.reset);

    test('Sin estatico no se puede iniciar', () async {
      ensayo.iniciarManiobra();
      expect(ensayo.registrando, false);
      expect(ensayo.numeroManiobra.value, 0);
      expect(platos.any((p) => p.registrando), false);
      expect(await ensayo.terminarManiobra(), isNull);
      expect(db.ensayos, isEmpty);
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

    test('Terminar arma el resultado con estatico, max / min y capacidades', () async {
      ensayo.tomarEstatico();
      ensayo.iniciarManiobra();
      for (final peso in ['2410.00', '5980.00', '1800.00']) {
        platos[1].registrarLectura(peso);
      }
      platos[8].registrarLectura('300.00');

      final resultado = (await ensayo.terminarManiobra())!;
      expect(resultado.numero, 1);
      expect(resultado.duracionMs >= 0, true);
      expect(resultado.umbral, '90');
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
      platos[1].registrarLectura('5980.00');
      ensayo.descartarManiobra();

      expect(ensayo.estado.value, EstadoEnsayo.listo);
      expect(ensayo.numeroManiobra.value, 0);
      expect(platos.any((p) => p.registrando), false);
      // El max / min descartado no queda en pantalla.
      expect(platos[1].maximo.value, '');
      expect(platos[1].minimo.value, '');

      ensayo.iniciarManiobra();
      expect(ensayo.numeroManiobra.value, 1);
    });

    test('La pantalla queda encendida solo durante la maniobra', () async {
      ensayo.iniciarManiobra(); // sin estatico no arranca
      expect(pantalla, isEmpty);

      ensayo.tomarEstatico();
      ensayo.iniciarManiobra();
      expect(pantalla, [true]);
      await ensayo.terminarManiobra();
      expect(pantalla, [true, false]);

      ensayo.iniciarManiobra();
      ensayo.descartarManiobra();
      expect(pantalla, [true, false, true, false]);

      // Un ensayo nuevo con una maniobra en curso tambien la apaga.
      ensayo.iniciarManiobra();
      ensayo.iniciarEnsayo(
        tolva: 'TC-2',
        capacidades: List.filled(cantidadPlatos, ''),
        umbral: '90',
      );
      expect(pantalla.last, false);

      ensayo.onClose();
      expect(pantalla.last, false);
    });

    test('Alarma sin maniobra: compara el peso actual', () {
      // Capacidad 5000 y umbral 90: >= 4500 al limite, > 100.0 % (ya redondeado) excede.
      expect(ensayo.alarma(2, peso: '4000.00'), EstadoCelda.normal);
      expect(ensayo.alarma(2, peso: '4500.00'), EstadoCelda.alLimite);
      expect(ensayo.alarma(2, peso: '5000.00'), EstadoCelda.alLimite);
      expect(ensayo.alarma(2, peso: '5003.00'), EstadoCelda.excede);
      // Sin maniobra el maximo no cuenta.
      expect(ensayo.alarma(2, peso: '100.00', maximo: '6000.00'), EstadoCelda.normal);
      // Plato 9 sin capacidad: no hay alarma.
      expect(ensayo.alarma(9, peso: '99999.00'), EstadoCelda.sinDato);
    });

    test('Alarma durante la maniobra: compara el maximo', () {
      ensayo.tomarEstatico();
      ensayo.iniciarManiobra();

      // El peso actual bajo, pero el maximo ya se paso.
      expect(ensayo.alarma(2, peso: '2400.00', maximo: '5980.00'), EstadoCelda.excede);
      expect(ensayo.alarma(1, peso: '850.00', maximo: '2700.00'), EstadoCelda.alLimite);
      // Sin lecturas todavia: usa el peso actual.
      expect(ensayo.alarma(2, peso: '4600.00'), EstadoCelda.alLimite);
      expect(ensayo.alarma(9, peso: '0', maximo: '99999.00'), EstadoCelda.sinDato);
    });

    test('Alarma con el umbral del ensayo', () {
      ensayo.iniciarEnsayo(
        tolva: 'TC-1',
        capacidades: List.filled(cantidadPlatos, '1000'),
        umbral: '80',
      );
      expect(ensayo.alarma(5, peso: '799.00'), EstadoCelda.normal);
      expect(ensayo.alarma(5, peso: '800.00'), EstadoCelda.alLimite);
    });

    test('Terminar guarda la maniobra; el ensayo se inserta con la primera', () async {
      ensayo.tomarEstatico();
      expect(db.ensayos, isEmpty);

      ensayo.iniciarManiobra();
      platos[1].registrarLectura('5980.00');
      final primera = (await ensayo.terminarManiobra())!;
      ensayo.iniciarManiobra();
      final segunda = (await ensayo.terminarManiobra())!;

      // Un solo ensayo, con la tolva y la fecha de la primera maniobra.
      expect(db.ensayos.length, 1);
      expect(db.ensayos.single.tolva, 'TC-1');
      expect(db.ensayos.single.fecha, DateFormat('dd/MM/yyyy').format(DateTime.now()));
      expect(primera.guardada, true);
      expect(segunda.guardada, true);
      expect(primera.ensayoId, db.ensayos.single.id);
      expect(segunda.ensayoId, primera.ensayoId);
      expect(db.maniobras.map((m) => m.numero), [1, 2]);

      // Se guarda el max y la capacidad del plato, y el umbral del ensayo.
      final guardada = db.maniobras.first;
      expect(guardada.umbral, '90');
      expect(guardada.platos[1].maximo, '5980.00');
      expect(guardada.platos[1].capacidad, '5000');

      // Otro ensayo inserta otra fila.
      ensayo.iniciarEnsayo(
        tolva: 'TC-2',
        capacidades: List.filled(cantidadPlatos, ''),
        umbral: '80',
      );
      ensayo.tomarEstatico();
      ensayo.iniciarManiobra();
      final otra = (await ensayo.terminarManiobra())!;
      expect(db.ensayos.map((e) => e.tolva), ['TC-1', 'TC-2']);
      expect(otra.numero, 1);
      expect(otra.ensayoId, db.ensayos.last.id);
      expect(otra.umbral, '80');
    });

    test('Si no se puede guardar, la maniobra vuelve sin id y se reintenta', () async {
      ensayo.tomarEstatico();
      db.fallar = true;
      ensayo.iniciarManiobra();
      final fallida = (await ensayo.terminarManiobra())!;
      expect(fallida.guardada, false);
      expect(fallida.numero, 1);
      expect(ensayo.estado.value, EstadoEnsayo.listo);

      // La siguiente vuelve a intentar insertar el ensayo.
      db.fallar = false;
      ensayo.iniciarManiobra();
      final guardada = (await ensayo.terminarManiobra())!;
      expect(guardada.guardada, true);
      expect(guardada.numero, 2);
      expect(db.ensayos.length, 1);
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
