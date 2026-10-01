

import 'package:nueve_platos_cestari/helpers/bateria.dart';
import 'package:get/get.dart';

class RecibirPesoModel {

  RecibirPesoModel({
    String? peso,
    String? estable,
    int?    tension,
    String? adreess,
    bool?   conexion
  });
  
  final  rx = RxRecibiendoPeso();

  String get peso => rx.peso.value;
  set setPeso(String peso) => rx.peso.value = peso;

  String get estable => rx.estable.value;
  set setEstable(String estable) => rx.estable.value = estable;

  String get adreess => rx.adreess.value;
  set setAdreess(String adreess) => rx.adreess.value = adreess;

  bool get conexion => rx.conexion.value;
  set setConexion(bool conexion) => rx.conexion.value = conexion;

  /// true mientras hay un intento de conexion BLE en curso (turno, busqueda, conexion).
  bool get conectando => rx.conectando.value;
  set setConectando(bool conectando) => rx.conectando.value = conectando;

  int get tension => rx.tension.value;
  set setTension(String tension) {
    final parsed = double.tryParse(tension);
    if (parsed == null) {
      rx.tension.value = 0;
      return;
    }

    final porcent = Bateria.porcentaje(parsed);

    if(porcent <= 25){
      rx.tension.value = 1;
    }else if(porcent < 50){
      rx.tension.value = 2;
    }else if(porcent <= 75){
      rx.tension.value = 3;
    }else if(porcent <= 90){
      rx.tension.value = 4;
    }else{
      rx.tension.value = 5;
    }
  }
}

class RxRecibiendoPeso{
  final peso     = '0'.obs;
  final estable  = '0'.obs;
  final tension  =  0.obs;
  final adreess  = '0'.obs;
  final conexion = false.obs;
  final conectando = false.obs;
}