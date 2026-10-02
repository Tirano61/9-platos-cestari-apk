


import 'dart:async';

import 'package:nueve_platos_cestari/models/pesaje_model.dart';
import 'package:nueve_platos_cestari/Providers/pesadas/interfaces/state_interface.dart';

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