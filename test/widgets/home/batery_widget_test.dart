// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.




import 'package:cuatro_platos/Pages/cuatro_platos/widgets/batery_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget que muestra la carga de bateria', () {
    testWidgets('Icono de bateria con 1 raya, menow 525% de carga', (WidgetTester tester)async{
      await tester.pumpWidget(const MaterialApp(
        home: BateryWidget(batery: 1)
      ));
      await tester.pump();
      expect( find.byIcon(Icons.battery_1_bar), findsOne);
    });
    testWidgets('Icono de bateria con 2 rayas, menos 50% de carga', (WidgetTester tester)async{
      await tester.pumpWidget(const MaterialApp(
        home: BateryWidget(batery: 2)
      ));
      await tester.pump();
      expect( find.byIcon(Icons.battery_2_bar), findsOne);
    });
    testWidgets('Icono de bateria con 4 rayas, mas 50% de carga', (WidgetTester tester)async{
      await tester.pumpWidget(const MaterialApp(
        home: BateryWidget(batery: 3)
      ));
      await tester.pump();
      expect( find.byIcon(Icons.battery_4_bar), findsOne);
    });
    testWidgets('Icono de bateria con 5 rayas, mas 75% - 90% de carga', (WidgetTester tester)async{
      await tester.pumpWidget(const MaterialApp(
        home: BateryWidget(batery: 4)
      ));
      await tester.pump();
      expect( find.byIcon(Icons.battery_5_bar), findsOne);
    });
    testWidgets('Icono de bateria con 6 rayas, mas 90% de carga', (WidgetTester tester)async{
      await tester.pumpWidget(const MaterialApp(
        home: BateryWidget(batery: 5)
      ));
      await tester.pump();
      expect( find.byIcon(Icons.battery_6_bar), findsOne);
    });

    testWidgets('Icono de bateria con 1 rayasconcualquier otro numero', (WidgetTester tester)async{
      await tester.pumpWidget(const MaterialApp(
        home: BateryWidget(batery: 7)
      ));
      await tester.pump();
      expect( find.byIcon(Icons.battery_1_bar), findsOne);
    });
  });
}
