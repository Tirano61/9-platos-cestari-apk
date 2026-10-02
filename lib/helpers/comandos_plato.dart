import 'package:nueve_platos_cestari/Controllers/peso_controller.dart';
import 'package:nueve_platos_cestari/Providers/tcp_conexion.dart';
import 'package:get/get.dart';

/// Envia los comandos de cero y reset de hold a un plato (1..N) por TCP,
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
    final tag = 'plato$plato';
    if (!Get.isRegistered<PesoController>(tag: tag)) return null;
    return Get.find<PesoController>(tag: tag).pesoModel.adreess;
  }
}
