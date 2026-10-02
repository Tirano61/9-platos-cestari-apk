

import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_9platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_payload_model.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';

class CalculosController{


  static final CalculosController cn = CalculosController._();

  CalculosController._();
  
  var _sumaPesoPorEje = 0.0;
  var sumaEje = 0.0;

  String calculoEje( String peso1, String peso2 ){
    return (double.parse(peso1) + double.parse(peso2)).toStringAsFixed(2);
  }

  String calculoPorcentajePlatos(String pesoPlato){
    return pesoTotal != "0.00" ? (((double.tryParse(pesoPlato) ?? 0) * 100) / double.parse(pesoTotal) ).toPrecision(1).toString() : '0';
  }

  String calculoPorcentajePorEje( String eje, String peso1, String peso2){
    sumaEje = (double.tryParse(peso1) ?? 0) + (double.tryParse(peso2) ?? 0);
  
    return pesoTotal != "0.00" ? ((sumaEje * 100) / double.parse(pesoTotal)).toPrecision(1).toString() : '0';
  }

  String porcentajePorLado(String peso){
    return pesoTotal != "0.00" ? (double.parse(peso) * 100 / double.parse(pesoTotal) ).toPrecision(1).toString() : '0' ;
  }

  void setPesoTotalByList(List<String> pesos) {
    _sumaPesoPorEje = pesos.fold<double>(
      0,
      (sum, peso) => sum + (double.tryParse(peso) ?? 0),
    );
  }

  String get pesoTotal{
    return _sumaPesoPorEje.toStringAsFixed(2);
  }

  /// Arma la pesada a guardar. [pesos] son los 9 pesos en el orden de los
  /// platos: enganche, J1 IZQ, J1 DER, J2 IZQ ... J4 DER. Los lados suman
  /// los platos izq (2, 4, 6, 8) y der (3, 5, 7, 9); el enganche va aparte.
  Future<Pesada9PlatosPayload> calcularPayload9Platos({
    required List<String> pesos,
    String identificacion = '',
  }) async {
    assert(pesos.length == cantidadPlatos);
    setPesoTotalByList(pesos);

    String suma(List<String> lista) => lista
        .fold<double>(0, (sum, peso) => sum + (double.tryParse(peso) ?? 0))
        .toStringAsFixed(2);

    final enganche = pesos[0];
    final izq = [pesos[1], pesos[3], pesos[5], pesos[7]];
    final der = [pesos[2], pesos[4], pesos[6], pesos[8]];
    final juegos = [for (var j = 0; j < 4; j++) suma([izq[j], der[j]])];
    final ladoIzquierdo = suma(izq);
    final ladoDerecho = suma(der);

    final base = PesadaBase(
      fecha: _getDate(),
      hora: _getHora(),
      identificacion: identificacion,
      tipoPesada: '9_platos',
      total: pesoTotal,
      createdAt: DateTime.now().toIso8601String(),
    );

    final detalle = Pesada9PlatosDetalle(
      pesadaId: 0,
      enganche: enganche,
      j1Izq: izq[0],
      j1Der: der[0],
      j2Izq: izq[1],
      j2Der: der[1],
      j3Izq: izq[2],
      j3Der: der[2],
      j4Izq: izq[3],
      j4Der: der[3],
      juego1: juegos[0],
      juego2: juegos[1],
      juego3: juegos[2],
      juego4: juegos[3],
      ladoIzq: ladoIzquierdo,
      ladoDer: ladoDerecho,
      porEnganche: calculoPorcentajePlatos(enganche),
      porJ1Izq: calculoPorcentajePlatos(izq[0]),
      porJ1Der: calculoPorcentajePlatos(der[0]),
      porJ2Izq: calculoPorcentajePlatos(izq[1]),
      porJ2Der: calculoPorcentajePlatos(der[1]),
      porJ3Izq: calculoPorcentajePlatos(izq[2]),
      porJ3Der: calculoPorcentajePlatos(der[2]),
      porJ4Izq: calculoPorcentajePlatos(izq[3]),
      porJ4Der: calculoPorcentajePlatos(der[3]),
      porJuego1: calculoPorcentajePorEje('1', izq[0], der[0]),
      porJuego2: calculoPorcentajePorEje('2', izq[1], der[1]),
      porJuego3: calculoPorcentajePorEje('3', izq[2], der[2]),
      porJuego4: calculoPorcentajePorEje('4', izq[3], der[3]),
      porLadoIzq: porcentajePorLado(ladoIzquierdo),
      porLadoDer: porcentajePorLado(ladoDerecho),
    );

    return Pesada9PlatosPayload(base: base, detalle: detalle);
  }

  /// Devuelve la fecha actual en el momento de guardar
  /// 
  String _getDate(){
    final date = DateTime.now();
    String format = DateFormat('dd/MM/yyyy').format(date);
    return format;
  }
  /// Devuelve la hora actual en el momento de guardar
  /// 
  String _getHora(){
    final format = DateFormat.Hm().format(DateTime.now());
    return format; 
  }

}