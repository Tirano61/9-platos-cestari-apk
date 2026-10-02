
import 'package:get/get.dart';

class ConfigController extends GetxController{

  // Puerto UDP de cada plato: el indice 0 es el plato 1.
  final _puertos = <RxString>[
    '8001'.obs,
    '8002'.obs,
    '8003'.obs,
    '8004'.obs,
  ];

  int get cantidadPlatos => _puertos.length;

  /// Puerto del plato [plato] (1..cantidadPlatos).
  RxString puerto(int plato){
    return _puertos[plato - 1];
  }
  setPuerto(int plato, String puerto){
    _puertos[plato - 1].value = puerto;
  }

}
