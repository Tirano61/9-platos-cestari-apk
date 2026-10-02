

import 'dart:async';

import 'package:nueve_platos_cestari/models/pesadas/pesada_payload_model.dart';

abstract class StateInterface{

  

  getPesadas();
  Stream<List<Pesada9PlatosPayload>> get pesadasStream;
  dispose();

}