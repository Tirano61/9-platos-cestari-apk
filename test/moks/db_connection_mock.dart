


import 'package:cuatro_platos/BaseDeDatos/interfaces/pesadas/pesadas_interfaces.dart';
import 'package:cuatro_platos/models/pesaje_model.dart';
import 'package:cuatro_platos/models/pesadas/pesada_4platos_model.dart';
import 'package:cuatro_platos/models/pesadas/pesada_base_model.dart';
import 'package:cuatro_platos/models/pesadas/pesada_ejes_model.dart';

import '../list_pesajes/list_pesaje.dart';

class DbConnectionMock extends PesadasInterface{
  @override
  Future<int> deletePesada(String id)async {
    return 1;
  }

  @override
  Future<int> deletePesadas()async {
    return 1;
  }

  @override
  Future<List<Pesaje>> getPesadas()async {
    return [Pesaje(id: 1,fecha: 'fecha', hora: 'hora', identificacion: 'identificacion', 
      delDer: 'delDer', porDelDer: 'porDelDer', delIzq: 'delIzq', porDelIzq: 'porDelIzq',
      trasDer: 'trasDer', porTrasDer: 'porTrasDer', trasIzq: 'trasIzq', porTrasIzq: 'porTrasIzq',
      ejeDel: 'ejeDel', porEjeDel: 'porEjeDel', ejeTras: 'ejeTras', porEjeTras: 'porEjeTras', 
      ladoDer: 'ladoDer', porLadoDer: 'porLadoDer', ladoIzq: 'ladoIzq', porLadoIzq: 'porLadoIzq', total: 'total')];
  }

  @override
  Future<List<Map<String, dynamic>>> getPesadasExportacion()async {
    return listPesaje;
  }

  @override
  Future<List<Pesaje>> getPesadas4Platos() async {
    return getPesadas();
  }

  @override
  Future<List<Pesaje>> getPesadasPorEjes() async {
    return getPesadas();
  }

  @override
  Future<int> insertPesada(Pesaje pesaje)async {
    return 1;
  }

  @override
  Future<int> insertPesada4Platos({
    required PesadaBase base,
    required Pesada4PlatosDetalle detalle,
  }) async {
    return 1;
  }

  @override
  Future<int> insertPesadaPorEjes({
    required PesadaBase base,
    required PesadaEjesCabecera cabecera,
    required List<EjeDetalle> detalleEjes,
  }) async {
    return 1;
  }


}


