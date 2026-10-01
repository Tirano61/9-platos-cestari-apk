


class DBpesadas{

  static const String tableNamePesadas = 'tpesadas';

  static const String fpesId          = 'id';
  static const String fpFecha         = 'fecha';
  static const String fpHora          = 'hora';
  static const String fpidentificacion= 'identificacion';
  static const String fpdelDer        = 'delDer';
  static const String fpporDelDer     = 'porDelDer';
  static const String fpdelIzq        = 'delIzq';
  static const String fpporDelIzq     = 'porDelIzq';
  static const String fptrasDer       = 'trasDer';
  static const String fpporTrasDer    = 'porTrasDer';
  static const String fptrasIzq       = 'trasIzq';
  static const String fpporTrasIzq    = 'porTrasIzq';
  static const String fpejeDel        = 'ejeDel';
  static const String fpporEjeDel     = 'porEjeDel';
  static const String fpejeTras       = 'ejeTras';
  static const String fpporEjeTras    = 'porEjeTras';
  static const String fpeje3Izq       = 'eje3Izq';
  static const String fpporEje3Izq    = 'porEje3Izq';
  static const String fpeje3Der       = 'eje3Der';
  static const String fpporEje3Der    = 'porEje3Der';
  static const String fpejeTer        = 'ejeTer';
  static const String fpporEjeTer     = 'porEjeTer';
  static const String fpladoDer       = 'ladoDer';
  static const String fpporLadoDer    = 'porLadoDer';
  static const String fpladoIzq       = 'ladoIzq';
  static const String fpporLadoIzq    = 'porLadoIzq';
  static const String fptotal         = 'total';

  static const String createTablePesadas = "CREATE TABLE $tableNamePesadas ("
      "$fpesId INTEGER PRIMARY KEY AUTOINCREMENT, "
      "$fpFecha          text, "
      "$fpHora           text, "
      "$fpidentificacion text, "
      "$fpdelDer         text, "
      "$fpporDelDer      text, "
      "$fpdelIzq         text, "
      "$fpporDelIzq      text, "
      "$fptrasDer        text, "
      "$fpporTrasDer     text, "
      "$fptrasIzq        text, "
      "$fpporTrasIzq     text, "
      "$fpejeDel         text, "
      "$fpporEjeDel      text, "
      "$fpejeTras        text, "
      "$fpporEjeTras     text, "
      "$fpeje3Izq        text, "
      "$fpporEje3Izq     text, "
      "$fpeje3Der        text, "
      "$fpporEje3Der     text, "
      "$fpejeTer         text, "
      "$fpporEjeTer      text, "
      "$fpladoDer        text, "
      "$fpporLadoDer     text, "
      "$fpladoIzq        text, "
      "$fpporLadoIzq     text, "
      "$fptotal          text);";
}