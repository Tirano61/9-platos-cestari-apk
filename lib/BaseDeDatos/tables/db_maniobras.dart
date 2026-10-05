import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_ensayos.dart';

class DBManiobras {
  static const String tableName = 'tmaniobras';

  static const String createTable =
      "CREATE TABLE $tableName ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT, "
      "ensayo_id INTEGER NOT NULL, "
      "numero INTEGER NOT NULL, "
      "hora_inicio TEXT NOT NULL, "
      "hora_fin TEXT NOT NULL, "
      "duracion_ms INTEGER NOT NULL, "
      "umbral TEXT NOT NULL, "
      "FOREIGN KEY(ensayo_id) REFERENCES ${DBEnsayos.tableName}(id) ON DELETE CASCADE);";

  static const String createIndexEnsayo =
      "CREATE INDEX idx_tmaniobras_ensayo ON $tableName(ensayo_id);";
}
