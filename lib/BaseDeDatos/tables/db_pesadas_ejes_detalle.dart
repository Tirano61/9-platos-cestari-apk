import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_pesadas_base.dart';

class DBPesadasEjesDetalle {
  static const String tableName = 'tpesadas_ejes_detalle';

  static const String createTable =
      "CREATE TABLE $tableName ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT, "
      "pesada_id INTEGER NOT NULL, "
      "nro_eje INTEGER NOT NULL, "
      "peso_izq TEXT NOT NULL, "
      "peso_der TEXT NOT NULL, "
      "peso_total_eje TEXT NOT NULL, "
      "FOREIGN KEY(pesada_id) REFERENCES ${DBPesadasBase.tableName}(id) ON DELETE CASCADE, "
      "UNIQUE(pesada_id, nro_eje));";

  static const String createIndexPesadaId =
      "CREATE INDEX idx_tpesadas_ejes_detalle_pesada ON $tableName(pesada_id);";
}
