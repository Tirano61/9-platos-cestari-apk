import 'package:nueve_platos_cestari/config/platos.dart';

/// Puerto UDP por defecto del plato [plato]: 8001..8009.
String puertoPorDefecto(int plato) => '${8000 + plato}';

/// Puertos UDP por defecto de todos los platos: el indice 0 es el plato 1.
final List<String> puertosPorDefecto = [
  for (var n = 1; n <= cantidadPlatos; n++) puertoPorDefecto(n),
];
