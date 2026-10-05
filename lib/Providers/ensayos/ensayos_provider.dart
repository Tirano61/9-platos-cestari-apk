import 'dart:async';

import 'package:nueve_platos_cestari/BaseDeDatos/services/ensayos/service_ensayos.dart';
import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';

/// Stream de los ensayos guardados (con sus maniobras) para el historial.
/// Cada lectura o borrado vuelve a emitir la lista completa.
class EnsayosProvider {
  EnsayosProvider(this._ensayos);

  final ServiceEnsayos _ensayos;

  // Sin broadcast: si la lista llega antes de que escuche el StreamBuilder,
  // queda en espera en lugar de perderse.
  final _controller = StreamController<List<EnsayoModel>>();

  Stream<List<EnsayoModel>> get ensayosStream => _controller.stream;

  /// Lee la base y emite la lista. Despues de [dispose] no emite nada: lo puede
  /// llamar un SnackBar que se cierra con la pantalla ya cerrada.
  Future<void> getEnsayos() async {
    try {
      final ensayos = await _ensayos.getEnsayos();
      if (!_controller.isClosed) _controller.add(ensayos);
    } catch (e) {
      if (!_controller.isClosed) _controller.addError(e);
    }
  }

  Future<void> borrarEnsayo(int id) async {
    await _ensayos.deleteEnsayo(id);
    await getEnsayos();
  }

  Future<void> borrarEnsayos() async {
    await _ensayos.deleteEnsayos();
    await getEnsayos();
  }

  void dispose() {
    _controller.close();
  }
}
