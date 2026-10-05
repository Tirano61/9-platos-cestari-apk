import 'package:nueve_platos_cestari/Pages/nueve_platos/widgets/dialog_maniobra.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formatoDuracion: m:ss y h:mm:ss', () {
    expect(formatoDuracion(const Duration(seconds: 7)), '0:07');
    expect(formatoDuracion(const Duration(minutes: 12, seconds: 5)), '12:05');
    expect(formatoDuracion(const Duration(hours: 1, minutes: 2, seconds: 3)), '1:02:03');
  });

  testWidgets('El dialogo muestra la tabla con un estado por plato', (tester) async {
    // Pantalla de telefono angosto.
    tester.view.physicalSize = const Size(360, 740);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final inicio = DateTime(2026, 10, 5, 10, 0, 0);
    final resultado = (
      numero: 3,
      inicio: inicio,
      fin: inicio.add(const Duration(minutes: 1, seconds: 30)),
      platos: [
        for (var n = 1; n <= 9; n++)
          ManiobraPlato(
            plato: n,
            estatico: '2410.00',
            maximo: n == 1 ? '' : '${3500 + n * 250}.00',
            minimo: n == 1 ? '' : '1800.00',
            lecturas: n == 1 ? 0 : 100,
            capacidad: n == 9 ? '' : '5000',
          ),
      ],
    );

    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () => mostrarResultadoManiobra(context, resultado: resultado, umbral: '90'),
          child: const Text('abrir'),
        ),
      ),
    ));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(find.text('Maniobra 3'), findsOneWidget);
    expect(find.textContaining('10:00:00 a 10:01:30 (1:30)'), findsOneWidget);
    expect(find.text('ENGANCHE'), findsOneWidget);
    expect(find.text('J4 DER'), findsOneWidget);
    // Maximos 4000..5500 contra 5000: 80 y 85 % normal, 90 a 100 % al limite,
    // 105 y 110 % excede. El plato 9 no tiene capacidad.
    expect(find.text('NORMAL'), findsNWidgets(2));
    expect(find.text('AL LÍMITE'), findsNWidgets(3));
    expect(find.text('EXCEDE'), findsNWidgets(2));

    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
    expect(find.text('Maniobra 3'), findsNothing);
  });
}
