class DBEnsayos {
  static const String tableName = 'tensayos';

  static const String createTable =
      "CREATE TABLE $tableName ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT, "
      "tolva TEXT NOT NULL, "
      "fecha TEXT NOT NULL, "
      "created_at TEXT NOT NULL);";
}
