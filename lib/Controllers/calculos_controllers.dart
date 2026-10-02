

import 'package:nueve_platos_cestari/models/pesaje_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_4platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_ejes_model.dart';
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

  String calculoPorcentajeEjePorValores(String peso1, String peso2) {
    final suma = (double.tryParse(peso1) ?? 0) + (double.tryParse(peso2) ?? 0);
    return pesoTotal != "0.00" ? ((suma * 100) / double.parse(pesoTotal)).toPrecision(1).toString() : '0';
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

  Future<Pesaje> claculosParaGuardar(
    String peso1,
    String peso2,
    String peso3,
    String peso4, {
    String? peso5,
    String? peso6,
  }) async {
    if (peso5 != null && peso6 != null) {
      final payloadEjes = await calcularPayloadPorEjes(
        pesosPorPlato: [peso1, peso2, peso3, peso4, peso5, peso6],
      );
      return _pesajeFromEjesPayload(payloadEjes);
    }

    final payload4Platos = await calcularPayload4Platos(
      peso1: peso1,
      peso2: peso2,
      peso3: peso3,
      peso4: peso4,
    );
    return _pesajeFrom4PlatosPayload(payload4Platos);
  }

  Future<Pesaje> calculosParaGuardarPorEjes(List<String> pesosPorPlato) async {
    final payload = await calcularPayloadPorEjes(pesosPorPlato: pesosPorPlato);
    return _pesajeFromEjesPayload(payload);
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

  Future<PesadaEjesPayload> calcularPayloadPorEjes({
    required List<String> pesosPorPlato,
    String identificacion = '',
  }) async {
    final pesos = List<String>.from(pesosPorPlato);

    setPesoTotalByList(pesosPorPlato);

    double acumuladoLadoDerecho = 0;
    double acumuladoLadoIzquierdo = 0;

    for (int i = 0; i < pesosPorPlato.length; i += 2) {
      acumuladoLadoIzquierdo += double.tryParse(pesosPorPlato[i]) ?? 0;
      if (i + 1 < pesosPorPlato.length) {
        acumuladoLadoDerecho += double.tryParse(pesosPorPlato[i + 1]) ?? 0;
      }
    }

    final ladoDerecho = acumuladoLadoDerecho.toStringAsFixed(2);
    final ladoIzquierdo = acumuladoLadoIzquierdo.toStringAsFixed(2);

    final detalleEjes = <EjeDetalle>[];
    for (int i = 0; i < pesos.length; i += 2) {
      final nroEje = (i ~/ 2) + 1;
      final izq = pesos[i];
      final der = (i + 1 < pesos.length) ? pesos[i + 1] : '0.00';
      final totalEje =
          ((double.tryParse(izq) ?? 0) + (double.tryParse(der) ?? 0)).toStringAsFixed(2);
      detalleEjes.add(
        EjeDetalle(
          nroEje: nroEje,
          pesoIzq: izq,
          pesoDer: der,
          pesoTotal: totalEje,
        ),
      );
    }

    final base = PesadaBase(
      fecha: _getDate(),
      hora: _getHora(),
      identificacion: identificacion,
      tipoPesada: '2_platos_ejes',
      total: pesoTotal,
      createdAt: DateTime.now().toIso8601String(),
    );

    final cabecera = PesadaEjesCabecera(
      pesadaId: 0,
      cantidadEjes: detalleEjes.length,
      ladoIzqTotal: ladoIzquierdo,
      ladoDerTotal: ladoDerecho,
    );

    return PesadaEjesPayload(
      base: base,
      cabecera: cabecera,
      detalleEjes: detalleEjes,
    );
  }

  Pesaje _pesajeFrom4PlatosPayload(Pesada4PlatosPayload payload) {
    return Pesaje(
      identificacion: payload.base.identificacion,
      fecha: payload.base.fecha,
      hora: payload.base.hora,
      delDer: payload.detalle.delDer,
      porDelDer: payload.detalle.porDelDer,
      delIzq: payload.detalle.delIzq,
      porDelIzq: payload.detalle.porDelIzq,
      trasDer: payload.detalle.trasDer,
      porTrasDer: payload.detalle.porTrasDer,
      trasIzq: payload.detalle.trasIzq,
      porTrasIzq: payload.detalle.porTrasIzq,
      ejeDel: payload.detalle.ejeDel,
      porEjeDel: payload.detalle.porEjeDel,
      ejeTras: payload.detalle.ejeTras,
      porEjeTras: payload.detalle.porEjeTras,
      eje3Izq: '',
      porEje3Izq: '',
      eje3Der: '',
      porEje3Der: '',
      ejeTer: '',
      porEjeTer: '',
      ladoDer: payload.detalle.ladoDer,
      porLadoDer: payload.detalle.porLadoDer,
      ladoIzq: payload.detalle.ladoIzq,
      porLadoIzq: payload.detalle.porLadoIzq,
      total: payload.base.total,
      detalleEjes: const [],
    );
  }

  Pesaje _pesajeFromEjesPayload(PesadaEjesPayload payload) {
    String izq(int index) =>
        index < payload.detalleEjes.length ? payload.detalleEjes[index].pesoIzq : '';
    String der(int index) =>
        index < payload.detalleEjes.length ? payload.detalleEjes[index].pesoDer : '';
    String total(int index) =>
        index < payload.detalleEjes.length ? payload.detalleEjes[index].pesoTotal : '';

    return Pesaje(
      identificacion: payload.base.identificacion,
      fecha: payload.base.fecha,
      hora: payload.base.hora,
      delDer: der(0),
      porDelDer: '',
      delIzq: izq(0),
      porDelIzq: '',
      trasDer: der(1),
      porTrasDer: '',
      trasIzq: izq(1),
      porTrasIzq: '',
      ejeDel: total(0),
      porEjeDel: '',
      ejeTras: total(1),
      porEjeTras: '',
      eje3Izq: izq(2),
      porEje3Izq: '',
      eje3Der: der(2),
      porEje3Der: '',
      ejeTer: total(2),
      porEjeTer: '',
      ladoDer: payload.cabecera.ladoDerTotal,
      porLadoDer: '',
      ladoIzq: payload.cabecera.ladoIzqTotal,
      porLadoIzq: '',
      total: payload.base.total,
      detalleEjes: payload.detalleEjes,
    );
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