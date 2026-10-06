import 'package:nueve_platos_cestari/Controllers/peso_controller.dart';
import 'package:nueve_platos_cestari/Providers/tcp_conexion.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:get/get.dart';

/// Envia el comando de cero a un plato (1..N) por TCP,
/// a la IP desde la que llegan los datagramas UDP del plato.
///
/// Devuelve false si el comando no se pudo enviar.
class ComandosPlato {
  const ComandosPlato._();

  static Future<bool> enviarCero(int plato) {
    return _enviarTcp(plato, (conexion) => conexion.enviarCero());
  }

  /// Envia cero a los platos 1..cantidadPlatos y devuelve los que fallaron.
  ///
  /// Va en secuencia porque [Conexion.cn] es un solo socket.
  static Future<List<int>> enviarCeroGeneral() async {
    final fallidos = <int>[];
    for (var plato = 1; plato <= cantidadPlatos; plato++) {
      if (!await enviarCero(plato)) fallidos.add(plato);
    }
    return fallidos;
  }

  static Future<bool> _enviarTcp(
    int plato,
    Future<bool> Function(Conexion conexion) enviar,
  ) async {
    final ip = ipPlato(plato);
    if (ip == null) return false;

    final conexion = Conexion.cn;
    if (!await conexion.conectar(ip)) return false;

    try {
      return await enviar(conexion);
    } finally {
      await conexion.cerrarSocket();
    }
  }

  /// IP de origen de los datagramas UDP del plato. null si el plato no
  /// existe o todavia no mando datos (`adreess` vale '0' hasta el primero).
  static String? ipPlato(int plato) {
    final tag = 'plato$plato';
    if (!Get.isRegistered<PesoController>(tag: tag)) return null;
    final ip = Get.find<PesoController>(tag: tag).pesoModel.adreess.trim();
    return ip.isEmpty || ip == '0' ? null : ip;
  }
}
