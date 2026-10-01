


import 'package:cuatro_platos/models/pesaje_model.dart';
import 'package:cuatro_platos/models/pesadas/pesada_4platos_model.dart';
import 'package:cuatro_platos/models/pesadas/pesada_base_model.dart';
import 'package:cuatro_platos/models/pesadas/pesada_ejes_model.dart';

abstract class PesadasInterface{

  Future<int> insertPesada(Pesaje pesaje);
  Future<int> insertPesada4Platos({
    required PesadaBase base,
    required Pesada4PlatosDetalle detalle,
  });
  Future<int> insertPesadaPorEjes({
    required PesadaBase base,
    required PesadaEjesCabecera cabecera,
    required List<EjeDetalle> detalleEjes,
  });
  Future<List<Pesaje>> getPesadas();
  Future<List<Pesaje>> getPesadas4Platos();
  Future<List<Pesaje>> getPesadasPorEjes();
  Future<List<Map<String, dynamic>>> getPesadasExportacion();
  Future<int> deletePesadas();
  Future<int> deletePesada(String id);

}

