import 'package:nueve_platos_cestari/Controllers/config_controller.dart';
import 'package:nueve_platos_cestari/Pages/Home/widgets/dialog_config.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Abre el [DialogConfig] desde un boton, en una pantalla de [alto] px de un
/// telefono angosto. La ruta 'calibracion' muestra el plato que recibe.
Future<void> _abrir(WidgetTester tester, {double alto = 740}) async {
  tester.view.physicalSize = Size(360, alto);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  SizeScreen.sc().setSreenWidth(360);
  SizeScreen.sc().setMinWidth(false);

  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => showDialog(
            context: context,
            builder: (_) => const DialogConfig(),
          ),
          child: const Text('abrir'),
        ),
      ),
    ),
    routes: {
      'calibracion': (context) => Scaffold(
        appBar: AppBar(),
        body: Text(
          'calibracion ${ModalRoute.of(context)!.settings.arguments}',
        ),
      ),
    },
  ));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

Finder _boton(int n) => find.byKey(ValueKey('calibrar_$n'));

void main() {
  setUp(() => Get.put(ConfigController()));
  tearDown(Get.reset);

  testWidgets('hay un boton de calibrar por plato, con su tooltip',
      (tester) async {
    // Pantalla alta: entran los 9 campos sin scroll.
    await _abrir(tester, alto: 2000);

    expect(find.byIcon(Icons.tune), findsNWidgets(cantidadPlatos));
    for (var n = 1; n <= cantidadPlatos; n++) {
      final boton = tester.widget<IconButton>(_boton(n));
      expect(boton.tooltip, 'Calibrar ${nombrePlato(n)}');
    }
    expect(tester.takeException(), isNull);
  });

  for (final n in [1, 5, cantidadPlatos]) {
    testWidgets('el boton del plato $n abre calibracion con su numero',
        (tester) async {
      await _abrir(tester);

      await tester.scrollUntilVisible(_boton(n), 100,
          scrollable: find
              .descendant(of: find.byType(ListView), matching: find.byType(Scrollable))
              .first);
      await tester.ensureVisible(_boton(n));
      await tester.pumpAndSettle();
      await tester.tap(_boton(n));
      await tester.pumpAndSettle();

      expect(find.text('calibracion $n'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('al volver de calibracion el dialogo sigue con los puertos editados',
      (tester) async {
    await _abrir(tester);

    final campo = find
        .widgetWithText(TextField, 'Puerto Plato 1-${nombrePlato(1)}')
        .first;
    await tester.enterText(campo, '9001');
    await tester.tap(_boton(1));
    await tester.pumpAndSettle();
    expect(find.text('calibracion 1'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(DialogConfig), findsOneWidget);
    expect(tester.widget<TextField>(campo).controller!.text, '9001');
    // No se guardo nada: el puerto del controller sigue igual.
    expect(Get.find<ConfigController>().puerto(1).value, '8001');
  });
}
