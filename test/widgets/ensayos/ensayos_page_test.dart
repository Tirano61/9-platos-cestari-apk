import 'package:nueve_platos_cestari/BaseDeDatos/services/ensayos/service_ensayos.dart';
import 'package:nueve_platos_cestari/Pages/ensayos/ensayos_page.dart';
import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../moks/db_ensayos_mock.dart';

ManiobraModel _maniobra(int ensayoId, int numero) => ManiobraModel(
      ensayoId: ensayoId,
      numero: numero,
      horaInicio: '10:0$numero:00',
      horaFin: '10:0$numero:30',
      duracionMs: 30000,
      umbral: '90',
      platos: [
        for (var n = 1; n <= 9; n++)
          ManiobraPlato(
            plato: n,
            estatico: '2410.00',
            maximo: '4000.00',
            minimo: '1800.00',
            lecturas: 100,
            capacidad: '5000',
          ),
      ],
    );

void main() {
  late DbEnsayosMock db;

  setUp(() async {
    db = DbEnsayosMock();
    final t1 = await db.insertEnsayo(
        const EnsayoModel(tolva: 'Tolva 1', fecha: '01/10/2026', createdAt: '2026-10-01T10:00:00'));
    await db.insertManiobra(_maniobra(t1, 1));
    await db.insertManiobra(_maniobra(t1, 2));
    final t2 = await db.insertEnsayo(
        const EnsayoModel(tolva: 'Tolva 2', fecha: '05/10/2026', createdAt: '2026-10-05T10:00:00'));
    await db.insertManiobra(_maniobra(t2, 1));
  });

  Future<void> abrir(WidgetTester tester) async {
    // Pantalla de telefono angosto.
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(home: EnsayosPage(ensayos: ServiceEnsayos(db))));
    await tester.pumpAndSettle();
  }

  testWidgets('Una tarjeta por ensayo que se expande con sus maniobras', (tester) async {
    await abrir(tester);

    expect(find.text('Tolva 2'), findsOneWidget);
    expect(find.text('05/10/2026 · 1 maniobra'), findsOneWidget);
    expect(find.text('01/10/2026 · 2 maniobras'), findsOneWidget);
    expect(find.text('Maniobra 1'), findsNothing);

    await tester.tap(find.text('Tolva 1'));
    await tester.pumpAndSettle();

    expect(find.text('Maniobra 1'), findsOneWidget);
    expect(find.text('Maniobra 2'), findsOneWidget);
    expect(find.text('10:01:00 a 10:01:30 (0:30) · umbral 90 %'), findsOneWidget);
    // Una tabla por maniobra; 4000 contra 5000 = 80 %, normal.
    expect(find.text('ENGANCHE'), findsNWidgets(2));
    expect(find.text('NORMAL'), findsNWidgets(18));
  });

  testWidgets('Deslizar y cancelar conserva el ensayo; OK lo borra', (tester) async {
    await abrir(tester);

    await tester.drag(find.text('Tolva 2'), const Offset(500, 0));
    await tester.pumpAndSettle();
    expect(find.text('Tolva 2'), findsNothing);
    expect(find.text('Se eliminara el ensayo Tolva 2'), findsOneWidget);

    await tester.tap(find.text('cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Tolva 2'), findsOneWidget);
    expect(db.ensayos.length, 2);

    await tester.drag(find.text('Tolva 2'), const Offset(500, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Tolva 2'), findsNothing);
    expect(db.ensayos.map((e) => e.tolva), ['Tolva 1']);
  });

  testWidgets('Borrar todo deja la lista vacia', (tester) async {
    await abrir(tester);

    await tester.tap(find.byIcon(Icons.delete_forever_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Desea eliminar todos los ensayos guardados?'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(db.ensayos, isEmpty);
    expect(find.text('No hay ensayos guardados'), findsOneWidget);
  });
}
