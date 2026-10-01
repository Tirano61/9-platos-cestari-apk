class Pesada4PlatosDetalle {
  final int pesadaId;
  final String delIzq;
  final String delDer;
  final String trasIzq;
  final String trasDer;
  final String ejeDel;
  final String ejeTras;
  final String ladoIzq;
  final String ladoDer;
  final String porDelIzq;
  final String porDelDer;
  final String porTrasIzq;
  final String porTrasDer;
  final String porEjeDel;
  final String porEjeTras;
  final String porLadoIzq;
  final String porLadoDer;

  const Pesada4PlatosDetalle({
    required this.pesadaId,
    required this.delIzq,
    required this.delDer,
    required this.trasIzq,
    required this.trasDer,
    required this.ejeDel,
    required this.ejeTras,
    required this.ladoIzq,
    required this.ladoDer,
    required this.porDelIzq,
    required this.porDelDer,
    required this.porTrasIzq,
    required this.porTrasDer,
    required this.porEjeDel,
    required this.porEjeTras,
    required this.porLadoIzq,
    required this.porLadoDer,
  });

  factory Pesada4PlatosDetalle.fromDb(Map<String, dynamic> row) =>
      Pesada4PlatosDetalle(
        pesadaId: (row['pesada_id'] ?? 0) as int,
        delIzq: (row['del_izq'] ?? '').toString(),
        delDer: (row['del_der'] ?? '').toString(),
        trasIzq: (row['tras_izq'] ?? '').toString(),
        trasDer: (row['tras_der'] ?? '').toString(),
        ejeDel: (row['eje_del'] ?? '').toString(),
        ejeTras: (row['eje_tras'] ?? '').toString(),
        ladoIzq: (row['lado_izq'] ?? '').toString(),
        ladoDer: (row['lado_der'] ?? '').toString(),
        porDelIzq: (row['por_del_izq'] ?? '').toString(),
        porDelDer: (row['por_del_der'] ?? '').toString(),
        porTrasIzq: (row['por_tras_izq'] ?? '').toString(),
        porTrasDer: (row['por_tras_der'] ?? '').toString(),
        porEjeDel: (row['por_eje_del'] ?? '').toString(),
        porEjeTras: (row['por_eje_tras'] ?? '').toString(),
        porLadoIzq: (row['por_lado_izq'] ?? '').toString(),
        porLadoDer: (row['por_lado_der'] ?? '').toString(),
      );

  Map<String, dynamic> toDb() => {
    'pesada_id': pesadaId,
    'del_izq': delIzq,
    'del_der': delDer,
    'tras_izq': trasIzq,
    'tras_der': trasDer,
    'eje_del': ejeDel,
    'eje_tras': ejeTras,
    'lado_izq': ladoIzq,
    'lado_der': ladoDer,
    'por_del_izq': porDelIzq,
    'por_del_der': porDelDer,
    'por_tras_izq': porTrasIzq,
    'por_tras_der': porTrasDer,
    'por_eje_del': porEjeDel,
    'por_eje_tras': porEjeTras,
    'por_lado_izq': porLadoIzq,
    'por_lado_der': porLadoDer,
  };
}
