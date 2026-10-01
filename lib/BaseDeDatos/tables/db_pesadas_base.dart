class DBPesadasBase {
  static const String tableName = 'tpesadas_base';

  static const String createTable =
      "CREATE TABLE $tableName ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT, "
      "fecha TEXT NOT NULL, "
      "hora TEXT NOT NULL, "
      "identificacion TEXT NOT NULL DEFAULT '', "
      "tipo_pesada TEXT NOT NULL, "
      "total TEXT NOT NULL DEFAULT '0.00', "
      "created_at TEXT NOT NULL);";

  static const String createIndexFecha =
      "CREATE INDEX idx_tpesadas_base_fecha ON $tableName(fecha);";

  static const String createIndexTipo =
      "CREATE INDEX idx_tpesadas_base_tipo ON $tableName(tipo_pesada);";
}
