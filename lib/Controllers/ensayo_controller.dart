import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'package:nueve_platos_cestari/BaseDeDatos/connections/db_conexion.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/services/ensayos/service_ensayos.dart';
import 'package:nueve_platos_cestari/Controllers/peso_controller.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/helpers/preferencias_ensayo.dart';
import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';

/// En que punto esta el ensayo: sin estatico no se puede registrar una
/// maniobra; con el estatico tomado queda `listo`; `registrando` mientras
/// corre una maniobra.
enum EstadoEnsayo { sinEstatico, listo, registrando }

/// Estado del ensayo de tolva en curso: lo cargado en la pantalla de inicio
/// el estatico de referencia y la maniobra en curso.
class EnsayoController extends GetxController {
  /// [leerPesos] devuelve el peso actual de los 9 platos (indice 0 = plato 1)
  /// y [platos] los 9 PesoController que registran la maniobra. Por defecto
  /// salen de Get; los tests pasan los suyos. [pantallaEncendida] mantiene
  /// la pantalla prendida (true) o la deja apagarse (false) durante la
  /// maniobra; por defecto usa wakelock_plus. [ensayos] guarda el ensayo y
  /// sus maniobras; por defecto en la base (DBconeccion).
  EnsayoController({
    List<String> Function()? leerPesos,
    List<PesoController> Function()? platos,
    void Function(bool encender)? pantallaEncendida,
    ServiceEnsayos? ensayos,
  })  : _leerPesos = leerPesos ?? _pesosDeLosPlatos,
        _platos = platos ?? _controllersDeLosPlatos,
        _pantallaEncendida = pantallaEncendida ?? _wakelock,
        _ensayos = ensayos ?? ServiceEnsayos(DBconeccion.db);

  final List<String> Function() _leerPesos;
  final List<PesoController> Function() _platos;
  final void Function(bool encender) _pantallaEncendida;
  final ServiceEnsayos _ensayos;

  static final _hora = DateFormat('HH:mm:ss');
  static final _fecha = DateFormat('dd/MM/yyyy');

  /// Id del ensayo en la base (lo que devuelve el insert). La fila se inserta
  /// al guardar la primera maniobra (asi no quedan ensayos vacios) y la
  /// comparten las siguientes. null = todavia no se guardo ninguna, o fallo el
  /// insert y la proxima maniobra lo reintenta.
  Future<int>? _ensayoId;

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
    _ensayoId = null;
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
    // Si la pantalla se apaga, Android puede cortar el WiFi y se pierden tramas.
    _pantallaEncendida(true);
  }

  /// Termina la maniobra en curso, arma el resultado de cada plato con el
  /// estatico y las capacidades del ensayo, y la guarda en la base.
  /// Devuelve la maniobra (`guardada` dice si se pudo guardar), o null si no
  /// habia maniobra. El registro se corta antes del primer await.
  Future<ManiobraModel?> terminarManiobra() async {
    final inicio = inicioManiobra.value;
    if (!registrando || inicio == null) return null;
    final fin = DateTime.now();

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
    _pantallaEncendida(false);

    final maniobra = ManiobraModel(
      numero: numeroManiobra.value,
      horaInicio: _hora.format(inicio),
      horaFin: _hora.format(fin),
      duracionMs: fin.difference(inicio).inMilliseconds,
      // Se copia: el umbral de SharedPreferences cambia en el proximo ensayo.
      umbral: umbral.value,
      platos: resultado,
    );
    return _guardar(maniobra, inicio);
  }

  /// Guarda la [maniobra]; si es la primera del ensayo, antes inserta el
  /// ensayo con la fecha de [inicio]. Se devuelve con sus ids, o sin id si fallo.
  Future<ManiobraModel> _guardar(ManiobraModel maniobra, DateTime inicio) async {
    // Se asigna antes del await: dos maniobras seguidas usan el mismo ensayo.
    final ensayo = _ensayoId ??= _ensayos.insertarEnsayo(EnsayoModel(
      tolva: tolva.value,
      fecha: _fecha.format(inicio),
      createdAt: DateTime.now().toIso8601String(),
    ));
    final ensayoId = await ensayo;
    if (ensayoId == -1) {
      // Que la proxima maniobra lo vuelva a intentar (si sigue siendo este ensayo).
      if (identical(_ensayoId, ensayo)) _ensayoId = null;
      return maniobra;
    }

    final conEnsayo = maniobra.copyWith(ensayoId: ensayoId);
    final id = await _ensayos.insertarManiobra(conEnsayo);
    return id == -1 ? conEnsayo : conEnsayo.copyWith(id: id);
  }

  /// Corta la maniobra en curso sin resultado; su numero se vuelve a usar.
  void descartarManiobra() {
    if (!registrando) return;
    for (final plato in _platos()) {
      plato.limpiarRegistro();
    }
    numeroManiobra.value--;
    inicioManiobra.value = null;
    estado.value = EstadoEnsayo.listo;
    _pantallaEncendida(false);
  }

  @override
  void onClose() {
    _pantallaEncendida(false);
    super.onClose();
  }

  static void _wakelock(bool encender) {
    WakelockPlus.toggle(enable: encender).catchError((Object e) {
      debugPrint('No se pudo cambiar el wakelock: $e');
    });
  }

  static List<PesoController> _controllersDeLosPlatos() => [
        for (var n = 1; n <= cantidadPlatos; n++) Get.find<PesoController>(tag: 'plato$n'),
      ];

  static List<String> _pesosDeLosPlatos() => [
        for (var n = 1; n <= cantidadPlatos; n++)
          Get.find<PesoController>(tag: 'plato$n').pesoModel.peso,
      ];
}
