


import 'package:nueve_platos_cestari/models/pesaje_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_4platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';

abstract class PesadasInterface{

  Future<int> insertPesada(Pesaje pesaje);
  Future<int> insertPesada4Platos({
    required PesadaBase base,
    required Pesada4PlatosDetalle detalle,
  });
  Future<List<Pesaje>> getPesadas();
  Future<List<Pesaje>> getPesadas4Platos();
  Future<List<Map<String, dynamic>>> getPesadasExportacion();
  Future<int> deletePesadas();
  Future<int> deletePesada(String id);

}

