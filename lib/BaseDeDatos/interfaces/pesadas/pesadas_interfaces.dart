


import 'package:nueve_platos_cestari/models/pesaje_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_9platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_payload_model.dart';

abstract class PesadasInterface{

  Future<int> insertPesada9Platos({
    required PesadaBase base,
    required Pesada9PlatosDetalle detalle,
  });
  Future<List<Pesaje>> getPesadas();
  Future<List<Pesada9PlatosPayload>> getPesadas9Platos();
  Future<List<Map<String, dynamic>>> getPesadasExportacion();
  Future<int> deletePesadas();
  Future<int> deletePesada(String id);

}

