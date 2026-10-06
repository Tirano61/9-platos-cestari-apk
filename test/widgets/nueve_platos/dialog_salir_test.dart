import 'package:nueve_platos_cestari/Controllers/ensayo_controller.dart';
import 'package:nueve_platos_cestari/Pages/nueve_platos/widgets/dialog_salir.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const nuevo = 'Para seguir midiendo vas a tener que iniciar un ensayo nuevo.';

  test('Sin estatico ni maniobras: el ensayo no se guarda', () {
    final texto = mensajeSalida(estado: EstadoEnsayo.sinEstatico, numeroManiobra: 0, hayEstatico: false);
    expect(texto.titulo, 'Salir del ensayo');
    expect(texto.accion, 'Salir');
    expect(texto.mensaje, 'Todavía no registraste ninguna maniobra: este ensayo no se guarda.\n\n$nuevo');
  });

  test('Con estatico y sin maniobras: avisa que el estatico se pierde', () {
    final texto = mensajeSalida(estado: EstadoEnsayo.listo, numeroManiobra: 0, hayEstatico: true);
    expect(texto.mensaje, 'Todavía no registraste ninguna maniobra: este ensayo no se guarda.\n\n'
        'El estático tomado se pierde.\n\n$nuevo');
  });

  test('Con maniobras terminadas: quedan en el historial (singular y plural)', () {
    final una = mensajeSalida(estado: EstadoEnsayo.listo, numeroManiobra: 1, hayEstatico: true);
    expect(una.mensaje, startsWith('La maniobra que ya terminaste queda guardada en el historial.'));
    expect(una.accion, 'Salir');

    final tres = mensajeSalida(estado: EstadoEnsayo.sinEstatico, numeroManiobra: 3, hayEstatico: false);
    expect(tres.mensaje, 'Las 3 maniobras que ya terminaste quedan guardadas en el historial.\n\n$nuevo');
  });

  test('Con una maniobra en curso: se descarta, las anteriores quedan', () {
    final primera = mensajeSalida(estado: EstadoEnsayo.registrando, numeroManiobra: 1, hayEstatico: true);
    expect(primera.titulo, 'Maniobra en curso');
    expect(primera.accion, 'Descartar y salir');
    expect(primera.mensaje, 'La maniobra 1, que está en curso, se descarta y no se guarda.\n\n'
        'El estático tomado se pierde.\n\n$nuevo');

    final tercera = mensajeSalida(estado: EstadoEnsayo.registrando, numeroManiobra: 3, hayEstatico: true);
    expect(tercera.mensaje, startsWith('La maniobra 3, que está en curso, se descarta y no se guarda.\n\n'
        'Las 2 maniobras que ya terminaste quedan guardadas en el historial.'));
  });
}
