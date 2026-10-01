

import 'dart:async';

import 'package:cuatro_platos/models/pesaje_model.dart';

abstract class StateInterface{

  

  getPesadas();
  Stream<List<Pesaje>> get pesadasStream;
  dispose();

}