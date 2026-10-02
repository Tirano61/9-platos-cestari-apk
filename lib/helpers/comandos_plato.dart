import 'package:nueve_platos_cestari/Controllers/peso1_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso2_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso3_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso4_controller.dart';
import 'package:nueve_platos_cestari/Providers/tcp_conexion.dart';
import 'package:nueve_platos_cestari/models/recibir_peso_model.dart';
import 'package:get/get.dart';

/// Envia los comandos de cero y reset de hold a un plato (1..4) por TCP,
/// a la IP desde la que llegan los datagramas UDP del plato.
///
/// Devuelve false si el comando no se pudo enviar.
class ComandosPlato {
  const ComandosPlato._();

  static Future<bool> enviarCero(int plato) {
    return _enviarTcp(plato, (conexion) => conexion.enviarCero());
  }

  static Future<bool> enviarResetHold(int plato) {
    return _enviarTcp(plato, (conexion) => conexion.enviarHold());
  }

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
