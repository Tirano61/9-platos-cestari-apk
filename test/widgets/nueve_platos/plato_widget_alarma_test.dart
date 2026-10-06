import 'package:nueve_platos_cestari/Pages/nueve_platos/widgets/plato_widget.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// Color de fondo del titulo y del borde del recuadro del plato.
  ({Color? titulo, Color borde}) colores(WidgetTester tester) {
    final cajas = tester
        .widgetList<Container>(find.descendant(of: find.byType(PlatoWidget), matching: find.byType(Container)))
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .where((d) => d.border != null)
        .toList();
    return (titulo: cajas.first.color, borde: (cajas.first.border as Border).top.color);
  }

  for (final (nivel, titulo, borde) in [
    (EstadoCelda.sinDato, ThemeApp.pesajeTitulos, Colors.black),
    (EstadoCelda.normal, ThemeApp.pesajeTitulos, Colors.black),
    (EstadoCelda.alLimite, Colors.amber, Colors.amber),
    (EstadoCelda.excede, ThemePlatos.errorColor, ThemePlatos.errorColor),
  ]) {
    testWidgets('Alarma ${nivel.name}: titulo y borde', (tester) async {
      // Telefono chico: el borde grueso no tiene que desbordar el recuadro.
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SizeScreen.sc().setSreenWidth(360);
      SizeScreen.sc().setMinWidth(false);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PlatoWidget(
            numPlato: 'J1 IZQ',
            pesoPlato: '-12345.67',
            buttonKeyPlato: const ValueKey('2'),
            conexionPlato: true,
            batery: 3,
            estable: '1',
            estatico: '2410.00',
            maximo: '5980.00',
            minimo: '1800.00',
            nivelAlarma: nivel,
          ),
        ),
      ));

      expect(tester.takeException(), isNull);
      final c = colores(tester);
      expect(c.titulo, titulo);
      expect(c.borde, borde);
    });
  }

  /// RichText del PlatoWidget que empieza con [flecha] (min o max).
  Finder valor(String flecha) => find.descendant(
        of: find.byType(PlatoWidget),
        matching: find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText().startsWith(flecha)),
      );

  for (final (maximo, minimo, textoMin, textoMax) in [
    ('5980.00', '1800.00', '▼ 1800.00', '▲ 5980.00'),
    ('', '', '▼ -', '▲ -'),
  ]) {
    testWidgets('Min / max dentro del plato: "$textoMin" "$textoMax"', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      SizeScreen.sc().setSreenWidth(360);
      SizeScreen.sc().setMinWidth(false);

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: PlatoWidget(
            numPlato: 'J1 IZQ',
            pesoPlato: '2410.00',
            buttonKeyPlato: const ValueKey('2'),
            conexionPlato: true,
            batery: 3,
            estable: '1',
            maximo: maximo,
            minimo: minimo,
          ),
        ),
      ));

      expect(tester.takeException(), isNull);
      final min = tester.widget<RichText>(valor('▼'));
      final max = tester.widget<RichText>(valor('▲'));
      expect(min.text.toPlainText(), textoMin);
      expect(max.text.toPlainText(), textoMax);
      // El minimo a la izquierda y el maximo a la derecha.
      expect(tester.getCenter(valor('▼')).dx, lessThan(tester.getCenter(valor('▲')).dx));
    });
  }
}
