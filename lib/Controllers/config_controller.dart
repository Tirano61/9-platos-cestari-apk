import 'package:nueve_platos_cestari/BaseDeDatos/helpers/settings/first_data.dart';
import 'package:get/get.dart';

class ConfigController extends GetxController{

  // Puerto UDP de cada plato: el indice 0 es el plato 1.
  final _puertos = <RxString>[
    for (final puerto in puertosPorDefecto) puerto.obs,
  ];

  int get cantidadPlatos => _puertos.length;

  /// Puerto del plato [plato] (1..cantidadPlatos).
  RxString puerto(int plato){
    return _puertos[plato - 1];
  }
  setPuerto(int plato, String puerto){
    _puertos[plato - 1].value = puerto;
  }

  /// Copia a los Rx los puertos de [puertos] (indice 0 = plato 1).
  setPuertos(List<String> puertos){
    for (var n = 1; n <= cantidadPlatos; n++) {
      setPuerto(n, puertos[n - 1]);
    }
  }

}
