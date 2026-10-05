import 'package:get/get.dart';

import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/helpers/preferencias_ensayo.dart';

/// Estado del ensayo de tolva en curso. Por ahora solo guarda lo que se cargo
/// en la pantalla de inicio; el estatico y las maniobras se agregan despues.
class EnsayoController extends GetxController {
  /// Identificacion de la tolva ensayada.
  final tolva = ''.obs;

  /// Capacidad nominal de cada celda en kg (indice 0 = plato 1).
  /// `''` = sin capacidad, esa celda no tiene alarma.
  final capacidades = List.generate(cantidadPlatos, (_) => '').obs;

  /// Umbral de alarma en %, comun a los 9 platos.
  final umbral = PreferenciasEnsayo.umbralPorDefecto.obs;

  void iniciarEnsayo({
    required String tolva,
    required List<String> capacidades,
    required String umbral,
  }) {
    assert(capacidades.length == cantidadPlatos);
    this.tolva.value = tolva;
    this.capacidades.assignAll(capacidades);
    this.umbral.value = umbral;
  }
}
