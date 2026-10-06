import 'package:nueve_platos_cestari/Controllers/config_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso_controller.dart';
import 'package:nueve_platos_cestari/helpers/comandos_plato.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  late PesoController plato2;

  setUp(() {
    Get.put(ConfigController());
    plato2 = Get.put(PesoController(plato: 2), tag: 'plato2');
  });
  tearDown(() {
    // force corre onClose, que cancela el timer de desconexion.
    Get.delete<PesoController>(tag: 'plato2', force: true);
    Get.reset();
  });

  test('ipPlato devuelve la IP de origen de los datagramas', () {
    plato2.pesoModel.setAdreess = '192.168.4.12';
    expect(ComandosPlato.ipPlato(2), '192.168.4.12');
  });

  test('ipPlato es null si el plato todavia no mando datos', () {
    expect(plato2.pesoModel.adreess, '0');
    expect(ComandosPlato.ipPlato(2), isNull);

    plato2.pesoModel.setAdreess = '';
    expect(ComandosPlato.ipPlato(2), isNull);
  });

  test('ipPlato es null si el plato no esta registrado', () {
    expect(ComandosPlato.ipPlato(3), isNull);
  });
}
