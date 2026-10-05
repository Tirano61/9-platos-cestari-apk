import 'package:get/get.dart';

import 'package:nueve_platos_cestari/Controllers/peso_controller.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/helpers/preferencias_ensayo.dart';

/// En que punto esta el ensayo: sin estatico no se puede registrar una
/// maniobra; con el estatico tomado queda `listo`; `registrando` mientras
/// corre una maniobra.
enum EstadoEnsayo { sinEstatico, listo, registrando }

/// Estado del ensayo de tolva en curso: lo cargado en la pantalla de inicio
/// y el estatico de referencia. Las maniobras se agregan despues.
class EnsayoController extends GetxController {
  /// [leerPesos] devuelve el peso actual de los 9 platos (indice 0 = plato 1).
  /// Por defecto los lee de los PesoController; los tests pasan los suyos.
  EnsayoController({List<String> Function()? leerPesos})
      : _leerPesos = leerPesos ?? _pesosDeLosPlatos;

  final List<String> Function() _leerPesos;

  /// Identificacion de la tolva ensayada.
  final tolva = ''.obs;

  /// Capacidad nominal de cada celda en kg (indice 0 = plato 1).
  /// `''` = sin capacidad, esa celda no tiene alarma.
  final capacidades = List.generate(cantidadPlatos, (_) => '').obs;

  /// Umbral de alarma en %, comun a los 9 platos.
  final umbral = PreferenciasEnsayo.umbralPorDefecto.obs;

  /// Peso estatico de referencia de cada plato, con 2 decimales
  /// (indice 0 = plato 1). Vacia = sin estatico.
  final estaticos = <String>[].obs;

  final estado = EstadoEnsayo.sinEstatico.obs;

  bool get hayEstatico => estaticos.isNotEmpty;

  /// Estatico del plato [n] (1..9), o `''` si no hay.
  String estatico(int n) => hayEstatico ? estaticos[n - 1] : '';

  void iniciarEnsayo({
    required String tolva,
    required List<String> capacidades,
    required String umbral,
  }) {
    assert(capacidades.length == cantidadPlatos);
    this.tolva.value = tolva;
    this.capacidades.assignAll(capacidades);
    this.umbral.value = umbral;
    // El estatico de un ensayo anterior no vale para esta tolva.
    borrarEstatico();
  }

  /// Toma el peso actual de los 9 platos como referencia estatica.
  /// Un peso invalido cuenta como 0.
  void tomarEstatico() {
    final pesos = _leerPesos();
    assert(pesos.length == cantidadPlatos);
    estaticos.assignAll([
      for (final peso in pesos) (double.tryParse(peso) ?? 0).toStringAsFixed(2),
    ]);
    estado.value = EstadoEnsayo.listo;
  }

  /// Borra el estatico (por ejemplo despues de un cero, que lo invalida).
  /// Devuelve true si habia uno tomado.
  bool borrarEstatico() {
    final habia = hayEstatico;
    estaticos.clear();
    estado.value = EstadoEnsayo.sinEstatico;
    return habia;
  }

  static List<String> _pesosDeLosPlatos() => [
        for (var n = 1; n <= cantidadPlatos; n++)
          Get.find<PesoController>(tag: 'plato$n').pesoModel.peso,
      ];
}
