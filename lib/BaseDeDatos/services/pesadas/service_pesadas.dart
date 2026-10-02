


import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/pesadas/pesadas_interfaces.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_9platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_payload_model.dart';

class ServicePesadas{

  late final PesadasInterface _pesadasInterface;
  ServicePesadas(PesadasInterface pesadasInterface){
    _pesadasInterface = pesadasInterface;
  }
  Future<int> insertarPesada9Platos({
    required PesadaBase base,
    required Pesada9PlatosDetalle detalle,
  }){
    return _pesadasInterface.insertPesada9Platos(base: base, detalle: detalle);
  }
  Future<List<Pesada9PlatosPayload>> getPesadas9Platos(){
    return _pesadasInterface.getPesadas9Platos();
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