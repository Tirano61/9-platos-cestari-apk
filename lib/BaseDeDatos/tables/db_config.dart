
class DBconfig{

  static const String tableNameConfig = 'tconfig';

  static const String fconId      = 'id';
  static const String fconplato1  = 'plato1';
  static const String fconplato2  = 'plato2';
  static const String fconplato3  = 'plato3';
  static const String fconplato4  = 'plato4';

  static const String createTableConfig = "CREATE TABLE $tableNameConfig ("
      "$fconId INTEGER PRIMARY KEY AUTOINCREMENT, "
      "$fconplato1 text, "
      "$fconplato2 text, "
      "$fconplato3 text, "
      "$fconplato4 text);";

}
