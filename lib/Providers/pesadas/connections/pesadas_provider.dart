

import 'dart:async';

import 'package:nueve_platos_cestari/models/pesadas/pesada_payload_model.dart';
import 'package:nueve_platos_cestari/Providers/pesadas/interfaces/state_interface.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/pesadas/pesadas_interfaces.dart';

class PesadasProvider extends StateInterface{

  late PesadasInterface _pesadasInterface;

  PesadasProvider(PesadasInterface pesadasInterface){
    _pesadasInterface = pesadasInterface;
  }


  StreamController<List<Pesada9PlatosPayload>> pesadasStreamController = StreamController<List<Pesada9PlatosPayload>>.broadcast();
   

  @override
  Stream<List<Pesada9PlatosPayload>> get pesadasStream => pesadasStreamController.stream;

  @override
  getPesadas()async {
    pesadasStreamController.sink.add( await _pesadasInterface.getPesadas9Platos() );
  }
  @override
  dispose(){
    pesadasStreamController.close();
  }
  

}