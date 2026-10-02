

import 'dart:async';

import 'package:nueve_platos_cestari/models/pesaje_model.dart';

abstract class StateInterface{

  

  getPesadas();
  Stream<List<Pesaje>> get pesadasStream;
  dispose();

}