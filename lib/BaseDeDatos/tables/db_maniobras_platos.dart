import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_maniobras.dart';

class DBManiobrasPlatos {
  static const String tableName = 'tmaniobras_platos';

  static const String createTable =
      "CREATE TABLE $tableName ("
      "maniobra_id INTEGER NOT NULL, "
      "plato INTEGER NOT NULL, "
      "estatico TEXT NOT NULL, "
      "maximo TEXT NOT NULL, "
      "minimo TEXT NOT NULL, "
      "lecturas INTEGER NOT NULL, "
      "capacidad TEXT NOT NULL, "
      "PRIMARY KEY(maniobra_id, plato), "
      "FOREIGN KEY(maniobra_id) REFERENCES ${DBManiobras.tableName}(id) ON DELETE CASCADE);";
}
