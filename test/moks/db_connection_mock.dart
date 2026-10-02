


import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/pesadas/pesadas_interfaces.dart';
import 'package:nueve_platos_cestari/models/pesaje_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_9platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_payload_model.dart';

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
  Future<List<Pesada9PlatosPayload>> getPesadas9Platos() async {
    return [];
  }

  @override
  Future<int> insertPesada9Platos({
    required PesadaBase base,
    required Pesada9PlatosDetalle detalle,
  }) async {
    return 1;
  }


}


