import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_pesadas_base.dart';

class DBPesadas9Platos {
  static const String tableName = 'tpesadas_9platos';

  static const String createTable =
      "CREATE TABLE $tableName ("
      "pesada_id INTEGER PRIMARY KEY, "
      "enganche TEXT NOT NULL, "
      "j1_izq TEXT NOT NULL, "
      "j1_der TEXT NOT NULL, "
      "j2_izq TEXT NOT NULL, "
      "j2_der TEXT NOT NULL, "
      "j3_izq TEXT NOT NULL, "
      "j3_der TEXT NOT NULL, "
      "j4_izq TEXT NOT NULL, "
      "j4_der TEXT NOT NULL, "
      "juego1 TEXT NOT NULL, "
      "juego2 TEXT NOT NULL, "
      "juego3 TEXT NOT NULL, "
      "juego4 TEXT NOT NULL, "
      "lado_izq TEXT NOT NULL, "
      "lado_der TEXT NOT NULL, "
      "por_enganche TEXT NOT NULL, "
      "por_j1_izq TEXT NOT NULL, "
      "por_j1_der TEXT NOT NULL, "
      "por_j2_izq TEXT NOT NULL, "
      "por_j2_der TEXT NOT NULL, "
      "por_j3_izq TEXT NOT NULL, "
      "por_j3_der TEXT NOT NULL, "
      "por_j4_izq TEXT NOT NULL, "
      "por_j4_der TEXT NOT NULL, "
      "por_juego1 TEXT NOT NULL, "
      "por_juego2 TEXT NOT NULL, "
      "por_juego3 TEXT NOT NULL, "
      "por_juego4 TEXT NOT NULL, "
      "por_lado_izq TEXT NOT NULL, "
      "por_lado_der TEXT NOT NULL, "
      "FOREIGN KEY(pesada_id) REFERENCES ${DBPesadasBase.tableName}(id) ON DELETE CASCADE);";
}
