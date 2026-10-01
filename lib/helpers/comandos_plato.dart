import 'package:cuatro_platos/Controllers/config_controller.dart';
import 'package:cuatro_platos/Controllers/peso1_controller.dart';
import 'package:cuatro_platos/Controllers/peso2_controller.dart';
import 'package:cuatro_platos/Controllers/peso3_controller.dart';
import 'package:cuatro_platos/Controllers/peso4_controller.dart';
import 'package:cuatro_platos/Providers/tcp_conexion.dart';
import 'package:cuatro_platos/data/ble/ble_scale_service.dart';
import 'package:cuatro_platos/models/config_model.dart';
import 'package:cuatro_platos/models/recibir_peso_model.dart';
import 'package:get/get.dart';

/// Envia los comandos de cero y reset de hold a un plato (1..4) por la
/// conexion configurada.
///
/// - BLE: se escribe el comando AT en la caracteristica de escritura del
///   plato. Nunca se usa WiFi, aunque la escritura falle.
/// - WiFi: se abre un socket TCP a la IP desde la que llegan los datagramas
///   UDP del plato.
///
/// Devuelve false si el comando no se pudo enviar.
class ComandosPlato {
  const ComandosPlato._();

  static Future<bool> enviarCero(int plato) {
    if (_esBle) return BleScaleService.instance.enviarCero(plato);
    return _enviarTcp(plato, (conexion) => conexion.enviarCero());
  }

  static Future<bool> enviarResetHold(int plato) {
    if (_esBle) return BleScaleService.instance.enviarResetHold(plato);
    return _enviarTcp(plato, (conexion) => conexion.enviarHold());
  }

  static bool get _esBle =>
      Get.find<ConfigController>().getConnectionType.value == ConnectionType.ble;

  static Future<bool> _enviarTcp(
    int plato,
    Future<bool> Function(Conexion conexion) enviar,
  ) async {
    final ip = _ipPlato(plato);
    if (ip == null) return false;

    final conexion = Conexion.cn;
    if (!await conexion.conectar(ip)) return false;

    try {
      return await enviar(conexion);
    } finally {
      await conexion.cerrarSocket();
    }
  }

  static String? _ipPlato(int plato) {
    final RecibirPesoModel? modelo = switch (plato) {
      1 => Get.find<Peso1Controller>().getPesoModel1,
      2 => Get.find<Peso2Controller>().getPesoModel2,
      3 => Get.find<Peso3Controller>().getPesoModel3,
      4 => Get.find<Peso4Controller>().getPesoModel4,
      _ => null,
    };
    return modelo?.adreess;
  }
}
