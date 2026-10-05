import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Capacidad nominal de cada celda y umbral de alarma del ensayo,
/// guardados en SharedPreferences (no van a la base ni a tconfig).
///
/// Se precargan en el inicio de cada ensayo y el usuario los puede cambiar.
class PreferenciasEnsayo {
  const PreferenciasEnsayo._();

  /// Umbral de alarma en % cuando nunca se guardo uno.
  static const umbralPorDefecto = '90';

  static const claveUmbral = 'umbral_alarma';

  /// Clave de la capacidad del plato [plato] (1..cantidadPlatos).
  static String claveCapacidad(int plato) => 'capacidad_plato$plato';

  /// Capacidades de los platos 1..cantidadPlatos (indice 0 = plato 1),
  /// `''` en los que nunca se cargaron.
  static Future<List<String>> leerCapacidades() async {
    final prefs = await SharedPreferences.getInstance();
    return List.generate(
      cantidadPlatos,
      (i) => prefs.getString(claveCapacidad(i + 1)) ?? '',
    );
  }

  static Future<String> leerUmbral() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(claveUmbral) ?? umbralPorDefecto;
  }

  /// Guarda las [capacidades] (una por plato, indice 0 = plato 1) y el [umbral].
  static Future<void> guardar({
    required List<String> capacidades,
    required String umbral,
  }) async {
    assert(capacidades.length == cantidadPlatos);
    final prefs = await SharedPreferences.getInstance();
    for (var plato = 1; plato <= cantidadPlatos; plato++) {
      await prefs.setString(claveCapacidad(plato), capacidades[plato - 1]);
    }
    await prefs.setString(claveUmbral, umbral);
  }
}
