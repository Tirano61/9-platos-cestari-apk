import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('EnsayoModel: toDb sin id y fromDb', () {
    const ensayo = EnsayoModel(tolva: 'TC-1', fecha: '05/10/2026', createdAt: '2026-10-05T10:00:00.000');
    expect(ensayo.toDb(), {'tolva': 'TC-1', 'fecha': '05/10/2026', 'created_at': '2026-10-05T10:00:00.000'});

    final leido = EnsayoModel.fromDb({...ensayo.toDb(), 'id': 7});
    expect(leido.id, 7);
    expect(leido.tolva, 'TC-1');
    expect(leido.fecha, '05/10/2026');
    expect(leido.createdAt, '2026-10-05T10:00:00.000');
    expect(leido.maniobras, isEmpty);
  });

  test('ManiobraModel: columnas de tmaniobras, ida y vuelta', () {
    const plato = ManiobraPlato(
      plato: 2,
      estatico: '2410.00',
      maximo: '5980.00',
      minimo: '1800.00',
      lecturas: 250,
      capacidad: '5000',
    );
    const maniobra = ManiobraModel(
      ensayoId: 3,
      numero: 4,
      horaInicio: '10:00:00',
      horaFin: '10:01:30',
      duracionMs: 90250,
      umbral: '85',
      platos: [plato],
    );
    expect(maniobra.guardada, false);
    expect(maniobra.duracion, const Duration(milliseconds: 90250));
    expect(maniobra.toDb(), {
      'ensayo_id': 3,
      'numero': 4,
      'hora_inicio': '10:00:00',
      'hora_fin': '10:01:30',
      'duracion_ms': 90250,
      'umbral': '85',
    });

    final leida = ManiobraModel.fromDb(
      {...maniobra.toDb(), 'id': 9},
      platos: [ManiobraPlato.fromDb({...plato.toDb(), 'maniobra_id': 9})],
    );
    expect(leida.id, 9);
    expect(leida.guardada, true);
    expect(leida.toDb(), maniobra.toDb());

    final leido = leida.platos.single;
    expect(leido.toDb(), plato.toDb());
    // El estado se recalcula igual con la capacidad y el umbral copiados.
    expect(leido.porCapacidad, '119.6');
    expect(leido.estado(leida.umbral), EstadoCelda.excede);
  });

  test('copyWith solo cambia los ids', () {
    const maniobra = ManiobraModel(
      numero: 1,
      horaInicio: '10:00:00',
      horaFin: '10:00:10',
      duracionMs: 10000,
      umbral: '90',
      platos: [],
    );
    final guardada = maniobra.copyWith(ensayoId: 2).copyWith(id: 5);
    expect(guardada.id, 5);
    expect(guardada.ensayoId, 2);
    expect(guardada.toDb(), {...maniobra.toDb(), 'ensayo_id': 2});
  });
}
