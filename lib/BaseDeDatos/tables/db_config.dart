
import 'package:nueve_platos_cestari/config/platos.dart';

class DBconfig{

  static const String tableNameConfig = 'tconfig';

  static const String fconId      = 'id';

  /// Columna con el puerto del plato [plato]: 'plato1'..'plato9'.
  static String fconPlato(int plato) => 'plato$plato';

  static final String createTableConfig = "CREATE TABLE $tableNameConfig ("
      "$fconId INTEGER PRIMARY KEY AUTOINCREMENT, "
      "${[for (var n = 1; n <= cantidadPlatos; n++) '${fconPlato(n)} text'].join(', ')});";

}
