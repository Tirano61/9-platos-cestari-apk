import 'package:get/get.dart';

import 'package:nueve_platos_cestari/Controllers/peso_controller.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/helpers/preferencias_ensayo.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';

/// En que punto esta el ensayo: sin estatico no se puede registrar una
/// maniobra; con el estatico tomado queda `listo`; `registrando` mientras
/// corre una maniobra.
enum EstadoEnsayo { sinEstatico, listo, registrando }

/// Lo que devuelve [EnsayoController.terminarManiobra]: numero, hora de inicio
/// y fin, y el resultado de cada plato (indice 0 = plato 1).
typedef ResultadoManiobra = ({
  int numero,
  DateTime inicio,
  DateTime fin,
  List<ManiobraPlato> platos,
});

/// Estado del ensayo de tolva en curso: lo cargado en la pantalla de inicio
/// el estatico de referencia y la maniobra en curso.
class EnsayoController extends GetxController {
  /// [leerPesos] devuelve el peso actual de los 9 platos (indice 0 = plato 1)
  /// y [platos] los 9 PesoController que registran la maniobra. Por defecto
  /// salen de Get; los tests pasan los suyos.
  EnsayoController({
    List<String> Function()? leerPesos,
    List<PesoController> Function()? platos,
  })  : _leerPesos = leerPesos ?? _pesosDeLosPlatos,
        _platos = platos ?? _controllersDeLosPlatos;

  final List<String> Function() _leerPesos;
  final List<PesoController> Function() _platos;

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

  /// Numero de la ultima maniobra (o de la que esta corriendo) del ensayo.
  /// 0 = todavia ninguna.
  final numeroManiobra = 0.obs;

  /// Hora de inicio de la maniobra en curso (null si no hay).
  final inicioManiobra = Rxn<DateTime>();

  bool get hayEstatico => estaticos.isNotEmpty;

  bool get registrando => estado.value == EstadoEnsayo.registrando;

  /// Estatico del plato [n] (1..9), o `''` si no hay.
  String estatico(int n) => hayEstatico ? estaticos[n - 1] : '';

  /// Alarma del plato [n] (1..9) contra su capacidad y el umbral del ensayo.
  /// Durante la maniobra se compara el [maximo]; sin maniobra (o si todavia no
  /// llego ninguna lectura) el [peso] actual. `sinDato` = sin capacidad.
  EstadoCelda alarma(int n, {required String peso, String maximo = ''}) => estadoCelda(
        peso: registrando && maximo.isNotEmpty ? maximo : peso,
        capacidad: capacidades[n - 1],
        umbral: umbral.value,
      );

  void iniciarEnsayo({
    required String tolva,
    required List<String> capacidades,
    required String umbral,
  }) {
    assert(capacidades.length == cantidadPlatos);
    if (registrando) descartarManiobra();
    numeroManiobra.value = 0;
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

  /// Empieza una maniobra: los 9 platos registran maximo y minimo.
  /// Solo con el estatico tomado (estado `listo`).
  void iniciarManiobra() {
    if (estado.value != EstadoEnsayo.listo) return;
    for (final plato in _platos()) {
      plato.iniciarRegistro();
    }
    numeroManiobra.value++;
    inicioManiobra.value = DateTime.now();
    estado.value = EstadoEnsayo.registrando;
  }

  /// Termina la maniobra en curso y arma el resultado de cada plato con el
  /// estatico y las capacidades del ensayo. null si no habia maniobra.
  ResultadoManiobra? terminarManiobra() {
    final inicio = inicioManiobra.value;
    if (!registrando || inicio == null) return null;

    final platos = _platos();
    final resultado = <ManiobraPlato>[];
    for (var n = 1; n <= cantidadPlatos; n++) {
      final registro = platos[n - 1].detenerRegistro();
      resultado.add(ManiobraPlato(
        plato: n,
        estatico: estatico(n),
        maximo: registro.hayDatos ? registro.maximo.toStringAsFixed(2) : '',
        minimo: registro.hayDatos ? registro.minimo.toStringAsFixed(2) : '',
        lecturas: registro.lecturas,
        capacidad: capacidades[n - 1],
      ));
    }
    inicioManiobra.value = null;
    estado.value = EstadoEnsayo.listo;
    return (
      numero: numeroManiobra.value,
      inicio: inicio,
      fin: DateTime.now(),
      platos: resultado,
    );
  }

  /// Corta la maniobra en curso sin resultado; su numero se vuelve a usar.
  void descartarManiobra() {
    if (!registrando) return;
    for (final plato in _platos()) {
      plato.detenerRegistro();
    }
    numeroManiobra.value--;
    inicioManiobra.value = null;
    estado.value = EstadoEnsayo.listo;
  }

  static List<PesoController> _controllersDeLosPlatos() => [
        for (var n = 1; n <= cantidadPlatos; n++) Get.find<PesoController>(tag: 'plato$n'),
      ];

  static List<String> _pesosDeLosPlatos() => [
        for (var n = 1; n <= cantidadPlatos; n++)
          Get.find<PesoController>(tag: 'plato$n').pesoModel.peso,
      ];
}
