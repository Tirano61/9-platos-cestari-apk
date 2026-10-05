import 'package:nueve_platos_cestari/Controllers/config_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() => Get.put(ConfigController()));
  tearDown(Get.reset);

  test('Sin iniciar el registro, las lecturas no se registran', () {
    final controller = PesoController(plato: 2);
    controller.registrarLectura('1500.00');
    expect(controller.registro.hayDatos, false);
    expect(controller.maximo.value, '');
    expect(controller.lecturas.value, 0);
  });

  test('Registra max / min, saltea pesos invalidos y actualiza el estado Rx', () {
    final controller = PesoController(plato: 2)..iniciarRegistro();
    for (final peso in ['2410.00', 'abc', '5980.00', '', '1800.5']) {
      controller.registrarLectura(peso);
    }
    expect(controller.maximo.value, '5980.00');
    expect(controller.minimo.value, '1800.50');
    expect(controller.lecturas.value, 3);

    final registro = controller.detenerRegistro();
    expect(registro.maximo, 5980);
    expect(registro.lecturas, 3);

    // Detenido, no registra mas y el estado Rx queda con los ultimos valores.
    controller.registrarLectura('9000.00');
    expect(registro.maximo, 5980);
    expect(controller.maximo.value, '5980.00');
  });

  test('Un registro nuevo arranca vacio y no toca el devuelto antes', () {
    final controller = PesoController(plato: 2)..iniciarRegistro();
    controller.registrarLectura('3000.00');
    final anterior = controller.detenerRegistro();

    controller.iniciarRegistro();
    expect(controller.maximo.value, '');
    expect(controller.lecturas.value, 0);
    controller.registrarLectura('100.00');

    expect(anterior.maximo, 3000);
    expect(anterior.lecturas, 1);
    expect(controller.registro.maximo, 100);
  });
}
