
import 'package:nueve_platos_cestari/BaseDeDatos/helpers/settings/first_data.dart';
import 'package:nueve_platos_cestari/config/platos.dart';

class DBconfig{

  static const String tableNameConfig = 'tconfig';

  static const String fconId      = 'id';

  /// Columna con el puerto del plato [plato]: 'plato1'..'plato9'.
  static String fconPlato(int plato) => 'plato$plato';

  static final String createTableConfig = "CREATE TABLE $tableNameConfig ("
      "$fconId INTEGER PRIMARY KEY AUTOINCREMENT, "
      "${[for (var n = 1; n <= cantidadPlatos; n++) '${fconPlato(n)} text'].join(', ')});";

  /// SQL que agrega a tconfig las columnas de plato que no estan en
  /// [columnasExistentes], con el puerto por defecto. Una base creada con la
  /// tabla de 4 platos (plato1..plato4) no tiene plato5..plato9.
  static List<String> completarColumnas(Iterable<String> columnasExistentes) => [
        for (var n = 1; n <= cantidadPlatos; n++)
          if (!columnasExistentes.contains(fconPlato(n))) ...[
            "ALTER TABLE $tableNameConfig ADD COLUMN ${fconPlato(n)} text;",
            "UPDATE $tableNameConfig SET ${fconPlato(n)} = '${puertoPorDefecto(n)}';",
          ],
      ];

}
