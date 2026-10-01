

import 'dart:async';

import 'package:cuatro_platos/models/pesaje_model.dart';
import 'package:cuatro_platos/Providers/pesadas/interfaces/state_interface.dart';
import 'package:cuatro_platos/BaseDeDatos/interfaces/pesadas/pesadas_interfaces.dart';

class PesadasProvider extends StateInterface{

  late PesadasInterface _pesadasInterface;

  PesadasProvider(PesadasInterface pesadasInterface){
    _pesadasInterface = pesadasInterface;
  }


  StreamController<List<Pesaje>> pesadasStreamController = StreamController<List<Pesaje>>.broadcast();
   

  @override
  Stream<List<Pesaje>> get pesadasStream => pesadasStreamController.stream;

  @override
  getPesadas()async {
    pesadasStreamController.sink.add( await _pesadasInterface.getPesadas() );
  }
  @override
  dispose(){
    pesadasStreamController.close();
  }
  

}