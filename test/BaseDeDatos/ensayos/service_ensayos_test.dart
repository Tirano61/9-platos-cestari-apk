import 'package:nueve_platos_cestari/BaseDeDatos/services/ensayos/service_ensayos.dart';
import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../moks/db_ensayos_mock.dart';

ManiobraModel maniobra(int ensayoId, int numero) => ManiobraModel(
      ensayoId: ensayoId,
      numero: numero,
      horaInicio: '10:00:00',
      horaFin: '10:01:30',
      duracionMs: 90000,
      umbral: '90',
      platos: [
        for (var n = 1; n <= 9; n++)
          ManiobraPlato(
            plato: n,
            estatico: '2410.00',
            maximo: '5980.00',
            minimo: '1800.00',
            lecturas: 100,
            capacidad: '5000',
          ),
      ],
    );

void main() {
  late DbEnsayosMock db;
  late ServiceEnsayos service;

  setUp(() {
    db = DbEnsayosMock();
    service = ServiceEnsayos(db);
  });

  Future<int> ensayo(String tolva) => service.insertarEnsayo(EnsayoModel(
        tolva: tolva,
        fecha: '05/10/2026',
        createdAt: '2026-10-05T10:00:00.000',
      ));

  test('Insertar ensayo y maniobras devuelve sus ids', () async {
    final id = await ensayo('TC-1');
    expect(id, 1);
    expect(await service.insertarManiobra(maniobra(id, 1)), 1);
    expect(await service.insertarManiobra(maniobra(id, 2)), 2);
  });

  test('Si falla devuelve -1', () async {
    db.fallar = true;
    expect(await ensayo('TC-1'), -1);
    expect(await service.insertarManiobra(maniobra(1, 1)), -1);
  });

  test('getEnsayos: id descendente, con sus maniobras por numero', () async {
    final primero = await ensayo('TC-1');
    final segundo = await ensayo('TC-2');
    await service.insertarManiobra(maniobra(primero, 2));
    await service.insertarManiobra(maniobra(primero, 1));
    await service.insertarManiobra(maniobra(segundo, 1));

    final ensayos = await service.getEnsayos();
    expect(ensayos.map((e) => e.tolva), ['TC-2', 'TC-1']);
    expect(ensayos[1].maniobras.map((m) => m.numero), [1, 2]);
    expect(ensayos[1].maniobras.first.platos.length, 9);
    expect(ensayos[0].maniobras.length, 1);
  });

  test('Borrar un ensayo se lleva sus maniobras', () async {
    final primero = await ensayo('TC-1');
    final segundo = await ensayo('TC-2');
    await service.insertarManiobra(maniobra(primero, 1));
    final otra = await service.insertarManiobra(maniobra(segundo, 1));
    await service.insertarManiobra(maniobra(segundo, 2));

    expect(await service.deleteManiobra(otra), 1);
    expect(await service.deleteEnsayo(primero), 1);

    final ensayos = await service.getEnsayos();
    expect(ensayos.map((e) => e.tolva), ['TC-2']);
    expect(ensayos.single.maniobras.map((m) => m.numero), [2]);

    expect(await service.deleteEnsayos(), 1);
    expect(await service.getEnsayos(), isEmpty);
  });
}
