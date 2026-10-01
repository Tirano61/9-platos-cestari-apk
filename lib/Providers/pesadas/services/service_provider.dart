


import 'dart:async';

import 'package:cuatro_platos/models/pesaje_model.dart';
import 'package:cuatro_platos/Providers/pesadas/interfaces/state_interface.dart';

class ServiceProvider {


  late StateInterface _stateInterface;
  ServiceProvider(StateInterface stateInterface){
    _stateInterface = stateInterface;

  }

  getPesadas(){
    _stateInterface.getPesadas();
  }
  Stream<List<Pesaje>> get pesadasStream => _stateInterface.pesadasStream;
  dispose(){
    _stateInterface.dispose();
  }
}