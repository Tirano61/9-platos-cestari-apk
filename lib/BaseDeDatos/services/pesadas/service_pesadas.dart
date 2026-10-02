


import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/pesadas/pesadas_interfaces.dart';
import 'package:nueve_platos_cestari/models/pesaje_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_4platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';

class ServicePesadas{

  late final PesadasInterface _pesadasInterface;
  ServicePesadas(PesadasInterface pesadasInterface){
    _pesadasInterface = pesadasInterface;
  }
  Future<int> insertarPesada(Pesaje pesaje){
    return _pesadasInterface.insertPesada(pesaje);
  }
  Future<int> insertarPesada4Platos({
    required PesadaBase base,
    required Pesada4PlatosDetalle detalle,
  }){
    return _pesadasInterface.insertPesada4Platos(base: base, detalle: detalle);
  }
  Future<List<Pesaje>> getPesadas4Platos(){
    return _pesadasInterface.getPesadas4Platos();
  }
  Future<int> deletePesadas(){
    return _pesadasInterface.deletePesadas();
  }
  Future<List<Map<String, dynamic>>> getPesadasExportacion(){
    return _pesadasInterface.getPesadasExportacion();
  }
  Future<int> deletePesada(String id){
    return _pesadasInterface.deletePesada(id);
  }
}