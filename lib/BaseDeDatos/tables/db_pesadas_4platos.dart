import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_pesadas_base.dart';

class DBPesadas4Platos {
  static const String tableName = 'tpesadas_4platos';

  static const String createTable =
      "CREATE TABLE $tableName ("
      "pesada_id INTEGER PRIMARY KEY, "
      "del_izq TEXT NOT NULL, "
      "del_der TEXT NOT NULL, "
      "tras_izq TEXT NOT NULL, "
      "tras_der TEXT NOT NULL, "
      "eje_del TEXT NOT NULL, "
      "eje_tras TEXT NOT NULL, "
      "lado_izq TEXT NOT NULL, "
      "lado_der TEXT NOT NULL, "
      "por_del_izq TEXT NOT NULL, "
      "por_del_der TEXT NOT NULL, "
      "por_tras_izq TEXT NOT NULL, "
      "por_tras_der TEXT NOT NULL, "
      "por_eje_del TEXT NOT NULL, "
      "por_eje_tras TEXT NOT NULL, "
      "por_lado_izq TEXT NOT NULL, "
      "por_lado_der TEXT NOT NULL, "
      "FOREIGN KEY(pesada_id) REFERENCES ${DBPesadasBase.tableName}(id) ON DELETE CASCADE);";
}
