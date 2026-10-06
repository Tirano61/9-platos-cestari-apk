import 'dart:async';

import 'package:nueve_platos_cestari/Pages/calibracion/calibracion_page.dart';
import 'package:nueve_platos_cestari/Providers/calibracion_wifi.dart';
import 'package:nueve_platos_cestari/models/calibracion/calibracion_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _ip = '192.168.4.12';

const _leida = CalibracionModel(
  firmware: FirmwareCalibracion.clasico,
  totalCelda: 4,
  sensibilidad: 2000,
  division: 0.5,
  conversiones: 10,
  recortes: 2,
  ventanaMovil: 8,
  kgFiltro: 5,
  correccion: 1.0,
  tiempoEstable: 3,
  kgResetHold: 10.0,
  capacidadMaxima: 3000,
);

/// Servicio falso: devuelve las [lecturas] en orden (la ultima se repite) y
/// anota lo que se envia. Con [envio] se controla cuando termina el envio.
class _ServicioFalso implements CalibracionWifi {
  _ServicioFalso(this.lecturas);

  final List<CalibracionModel?> lecturas;
  final leidas = <String>[];
  final enviadas = <CalibracionModel>[];
  Completer<bool>? envio;

  @override
  Duration get timeout => Duration.zero;

  @override
  Future<CalibracionModel?> leer(String ip) async {
    leidas.add(ip);
    return lecturas[(leidas.length - 1).clamp(0, lecturas.length - 1)];
  }

  @override
  Future<bool> enviar(String ip, CalibracionModel calibracion) {
    enviadas.add(calibracion);
    return envio?.future ?? Future.value(true);
  }

  @override
  void cerrar() {}
}

Future<void> _abrir(
  WidgetTester tester,
  _ServicioFalso servicio, {
  String? Function(int plato)? ipPlato,
}) async {
  // Pantalla de telefono angosto.
  tester.view.physicalSize = const Size(360, 740);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(MaterialApp(
    home: CalibracionPage(
      plato: 1,
      servicio: servicio,
      ipPlato: ipPlato ?? (_) => _ip,
    ),
  ));
  await tester.pumpAndSettle();
}

String _texto(WidgetTester tester, String clave) =>
    tester.widget<TextField>(find.byKey(ValueKey('campo_$clave'))).controller!.text;

Future<void> _tocar(WidgetTester tester, String texto) async {
  // Sin foco, el campo editado no vuelve a llevar el scroll hacia el.
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  final boton = find.text(texto);
  await tester.ensureVisible(boton);
  await tester.pumpAndSettle();
  await tester.tap(boton);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Muestra la IP, el firmware y los valores leidos', (tester) async {
    final servicio = _ServicioFalso([_leida]);
    await _abrir(tester, servicio);

    expect(servicio.leidas, [_ip]);
    expect(find.text('Calibración ENGANCHE'), findsOneWidget);
    expect(find.text('IP: $_ip · Firmware clásico'), findsOneWidget);
    expect(_texto(tester, 'celdas'), '4');
    expect(_texto(tester, 'sensibilidad'), '2000');
    expect(_texto(tester, 'division'), '0.5');
    expect(_texto(tester, 'gkfiltro'), '5');
    expect(_texto(tester, 'correccion'), '1.0');
    expect(_texto(tester, 'resethold'), '10.0');
    expect(_texto(tester, 'capacidad_maxima'), '3000.0');
    expect(tester.widget<TextField>(find.byKey(const ValueKey('campo_capacidad_maxima'))).readOnly, true);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Un campo que el firmware no mando queda vacio', (tester) async {
    await _abrir(tester, _ServicioFalso([
      const CalibracionModel(firmware: FirmwareCalibracion.esp32, totalCelda: 4, division: 0.5),
    ]));

    expect(find.text('IP: $_ip · Firmware ESP32'), findsOneWidget);
    expect(_texto(tester, 'celdas'), '4');
    expect(_texto(tester, 'recortes'), '');
    expect(_texto(tester, 'capacidad_maxima'), '');
  });

  testWidgets('Sin IP avisa y no lee; Reintentar vuelve a buscar la IP', (tester) async {
    final servicio = _ServicioFalso([_leida]);
    String? ip;
    await _abrir(tester, servicio, ipPlato: (_) => ip);

    expect(find.text('El plato todavía no mandó datos: no se conoce su IP.'), findsOneWidget);
    expect(servicio.leidas, isEmpty);

    ip = _ip;
    await _tocar(tester, 'Reintentar');

    expect(servicio.leidas, [_ip]);
    expect(_texto(tester, 'celdas'), '4');
  });

  testWidgets('Si la lectura falla avisa y deja leer de nuevo', (tester) async {
    final servicio = _ServicioFalso([null, _leida]);
    await _abrir(tester, servicio);

    expect(find.text('No se pudo leer la calibración del plato.'), findsOneWidget);
    expect(find.byKey(const ValueKey('campo_celdas')), findsNothing);

    await _tocar(tester, 'Leer de nuevo');

    expect(servicio.leidas, hasLength(2));
    expect(_texto(tester, 'celdas'), '4');
  });

  testWidgets('Un campo vacio o invalido se marca y no se envia', (tester) async {
    final servicio = _ServicioFalso([_leida]);
    await _abrir(tester, servicio);

    await tester.enterText(find.byKey(const ValueKey('campo_division')), '');
    await tester.enterText(find.byKey(const ValueKey('campo_correccion')), '1.0.5');
    await _tocar(tester, 'Enviar calibración');

    expect(find.text('Revisá los campos: División, Corrección.'), findsOneWidget);
    expect(find.text('Valor inválido'), findsNWidgets(2));
    expect(find.text('Enviar'), findsNothing); // no pidio confirmacion
    expect(servicio.enviadas, isEmpty);
  });

  testWidgets('Envia el modelo editado, avisa y vuelve a leer', (tester) async {
    const nueva = CalibracionModel(
      firmware: FirmwareCalibracion.clasico,
      totalCelda: 4,
      sensibilidad: 2000,
      division: 0.5,
      conversiones: 10,
      recortes: 2,
      ventanaMovil: 8,
      kgFiltro: 5,
      correccion: 1.05,
      tiempoEstable: 3,
      kgResetHold: 10.0,
      capacidadMaxima: 3000,
    );
    final servicio = _ServicioFalso([_leida, nueva])..envio = Completer<bool>();
    await _abrir(tester, servicio);

    // La coma se acepta como separador decimal.
    await tester.enterText(find.byKey(const ValueKey('campo_correccion')), '1,05');
    await tester.enterText(find.byKey(const ValueKey('campo_sensibilidad')), '1950');
    await _tocar(tester, 'Enviar calibración');

    expect(find.textContaining('El indicador se va a reiniciar.'), findsOneWidget);
    await tester.tap(find.text('Enviar'));
    await tester.pump();

    // Mientras envia, los botones quedan deshabilitados.
    final enviar = find.ancestor(
      of: find.text('Enviar calibración'),
      matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
    );
    expect(tester.widget<ButtonStyleButton>(enviar).enabled, false);

    servicio.envio!.complete(true);
    await tester.pumpAndSettle();

    expect(servicio.enviadas, hasLength(1));
    final enviada = servicio.enviadas.single;
    expect(enviada.correccion, 1.05);
    expect(enviada.sensibilidad, 1950);
    expect(enviada.toSaveQuery(), {...nueva.toSaveQuery(), 'sensibilidad': '1950'});
    expect(find.text('Calibración enviada. El indicador se reinicia.'), findsOneWidget);
    // Relee y muestra lo que quedo en el equipo.
    expect(servicio.leidas, hasLength(2));
    expect(_texto(tester, 'correccion'), '1.05');
    expect(_texto(tester, 'sensibilidad'), '2000');
  });

  testWidgets('Si el envio falla avisa el error y tambien vuelve a leer', (tester) async {
    final servicio = _ServicioFalso([_leida])..envio = (Completer<bool>()..complete(false));
    await _abrir(tester, servicio);

    await _tocar(tester, 'Enviar calibración');
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();

    expect(find.text('No se pudo enviar la calibración.'), findsOneWidget);
    expect(servicio.leidas, hasLength(2));
  });

  testWidgets('Cancelar la confirmacion no envia', (tester) async {
    final servicio = _ServicioFalso([_leida]);
    await _abrir(tester, servicio);

    await _tocar(tester, 'Enviar calibración');
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();

    expect(servicio.enviadas, isEmpty);
    expect(servicio.leidas, hasLength(1));
  });
}
