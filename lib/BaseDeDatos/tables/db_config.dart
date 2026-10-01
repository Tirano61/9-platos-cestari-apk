

class DBconfig{

  static const String tableNameConfig = 'tconfig';

  static const String fconId      = 'id';
  static const String fconplato1  = 'plato1';
  static const String fconplato2  = 'plato2';
  static const String fconplato3  = 'plato3';
  static const String fconplato4  = 'plato4';
  static const String fconConnectionType = 'connection_type';
  static const String fconplato1BleName = 'plato1_ble_name';
  static const String fconplato2BleName = 'plato2_ble_name';
  static const String fconplato3BleName = 'plato3_ble_name';
  static const String fconplato4BleName = 'plato4_ble_name';

  static const String createTableConfig = "CREATE TABLE $tableNameConfig ("
      "$fconId INTEGER PRIMARY KEY AUTOINCREMENT, "
      "$fconplato1 text, "
      "$fconplato2 text, "
      "$fconplato3 text, "
      "$fconplato4 text, "
      "$fconConnectionType text NOT NULL DEFAULT 'udp', "
      "$fconplato1BleName text NOT NULL DEFAULT '', "
      "$fconplato2BleName text NOT NULL DEFAULT '', "
      "$fconplato3BleName text NOT NULL DEFAULT '', "
      "$fconplato4BleName text NOT NULL DEFAULT '');";

}