import 'package:nueve_platos_cestari/BaseDeDatos/services/ensayos/service_ensayos.dart';
import 'package:nueve_platos_cestari/Providers/ensayos/ensayos_provider.dart';
import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../moks/db_ensayos_mock.dart';

void main() {
  late DbEnsayosMock db;
  late EnsayosProvider provider;

  setUp(() async {
    db = DbEnsayosMock();
    await db.insertEnsayo(const EnsayoModel(tolva: 'T-1', fecha: '05/10/2026', createdAt: '2026-10-05T10:00:00'));
    await db.insertEnsayo(const EnsayoModel(tolva: 'T-2', fecha: '05/10/2026', createdAt: '2026-10-05T11:00:00'));
    provider = EnsayosProvider(ServiceEnsayos(db));
  });

  test('getEnsayos emite la lista aunque nadie escuche todavia', () async {
    await provider.getEnsayos();
    final lista = await provider.ensayosStream.first;
    expect(lista.map((e) => e.tolva), ['T-2', 'T-1']);
  });

  test('borrarEnsayo y borrarEnsayos vuelven a emitir la lista', () async {
    final emitidas = <List<String>>[];
    provider.ensayosStream.listen((l) => emitidas.add(l.map((e) => e.tolva).toList()));

    await provider.getEnsayos();
    await provider.borrarEnsayo(1);
    await provider.borrarEnsayos();
    await pumpEventQueue();

    expect(emitidas, [
      ['T-2', 'T-1'],
      ['T-2'],
      <String>[],
    ]);
    expect(db.ensayos, isEmpty);
  });

  test('Despues de dispose borra pero no emite ni falla', () async {
    provider.dispose();
    await provider.borrarEnsayo(1);
    expect(db.ensayos.map((e) => e.tolva), ['T-2']);
  });
}
