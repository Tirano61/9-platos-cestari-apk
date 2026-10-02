import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_pesadas_base.dart';

class DBPesadasEjes {
  static const String tableName = 'tpesadas_ejes';

  static const String createTable =
      "CREATE TABLE $tableName ("
      "pesada_id INTEGER PRIMARY KEY, "
      "cantidad_ejes INTEGER NOT NULL, "
      "lado_izq_total TEXT NOT NULL, "
      "lado_der_total TEXT NOT NULL, "
      "FOREIGN KEY(pesada_id) REFERENCES ${DBPesadasBase.tableName}(id) ON DELETE CASCADE);";
}
