

import 'package:nueve_platos_cestari/models/pesadas/pesada_4platos_model.dart';
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
    return pesoTotal != "0.00" ? ((double.parse(pesoPlato) * 100) / double.parse(pesoTotal) ).toPrecision(1).toString() : '0';
  }

  String calculoPorcentajePorEje( String eje, String peso1, String peso2){
    sumaEje = (double.tryParse(peso1) ?? 0) + (double.tryParse(peso2) ?? 0);
  
    return pesoTotal != "0.00" ? ((sumaEje * 100) / double.parse(pesoTotal)).toPrecision(1).toString() : '0';
  }

  String porcentajePorLado(String peso){
    return pesoTotal != "0.00" ? (double.parse(peso) * 100 / double.parse(pesoTotal) ).toPrecision(1).toString() : '0' ;
  }

  setPesoTotal(String peso1, String peso2, String peso3, String peso4){
    _sumaPesoPorEje = double.parse(peso1) + double.parse(peso2) +
                      double.parse(peso3) + double.parse(peso4);
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

  Future<Pesada4PlatosPayload> calcularPayload4Platos({
    required String peso1,
    required String peso2,
    required String peso3,
    required String peso4,
    String identificacion = '',
  }) async {
    final pesosTotales = [peso1, peso2, peso3, peso4];
    setPesoTotalByList(pesosTotales);

    final ladoDerecho =
        ((double.tryParse(peso2) ?? 0) + (double.tryParse(peso4) ?? 0)).toStringAsFixed(2);
    final ladoIzquierdo =
        ((double.tryParse(peso1) ?? 0) + (double.tryParse(peso3) ?? 0)).toStringAsFixed(2);

    final base = PesadaBase(
      fecha: _getDate(),
      hora: _getHora(),
      identificacion: identificacion,
      tipoPesada: '4_platos',
      total: pesoTotal,
      createdAt: DateTime.now().toIso8601String(),
    );

    final detalle = Pesada4PlatosDetalle(
      pesadaId: 0,
      delIzq: peso1,
      delDer: peso2,
      trasIzq: peso3,
      trasDer: peso4,
      ejeDel: calculoEje(peso1, peso2),
      ejeTras: calculoEje(peso3, peso4),
      ladoIzq: ladoIzquierdo,
      ladoDer: ladoDerecho,
      porDelIzq: calculoPorcentajePlatos(peso1),
      porDelDer: calculoPorcentajePlatos(peso2),
      porTrasIzq: calculoPorcentajePlatos(peso3),
      porTrasDer: calculoPorcentajePlatos(peso4),
      porEjeDel: calculoPorcentajePorEje('1', peso1, peso2),
      porEjeTras: calculoPorcentajePorEje('2', peso3, peso4),
      porLadoIzq: porcentajePorLado(ladoIzquierdo),
      porLadoDer: porcentajePorLado(ladoDerecho),
    );

    return Pesada4PlatosPayload(base: base, detalle: detalle);
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