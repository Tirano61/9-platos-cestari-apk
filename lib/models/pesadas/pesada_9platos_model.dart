/// Detalle de una pesada de 9 platos (tabla tpesadas_9platos), 1:1 con
/// PesadaBase. Pesos y porcentajes viajan como String con 2 y 1 decimal.
class Pesada9PlatosDetalle {
  final int pesadaId;
  final String enganche;
  final String j1Izq;
  final String j1Der;
  final String j2Izq;
  final String j2Der;
  final String j3Izq;
  final String j3Der;
  final String j4Izq;
  final String j4Der;
  final String juego1;
  final String juego2;
  final String juego3;
  final String juego4;
  final String ladoIzq;
  final String ladoDer;
  final String porEnganche;
  final String porJ1Izq;
  final String porJ1Der;
  final String porJ2Izq;
  final String porJ2Der;
  final String porJ3Izq;
  final String porJ3Der;
  final String porJ4Izq;
  final String porJ4Der;
  final String porJuego1;
  final String porJuego2;
  final String porJuego3;
  final String porJuego4;
  final String porLadoIzq;
  final String porLadoDer;

  const Pesada9PlatosDetalle({
    required this.pesadaId,
    required this.enganche,
    required this.j1Izq,
    required this.j1Der,
    required this.j2Izq,
    required this.j2Der,
    required this.j3Izq,
    required this.j3Der,
    required this.j4Izq,
    required this.j4Der,
    required this.juego1,
    required this.juego2,
    required this.juego3,
    required this.juego4,
    required this.ladoIzq,
    required this.ladoDer,
    required this.porEnganche,
    required this.porJ1Izq,
    required this.porJ1Der,
    required this.porJ2Izq,
    required this.porJ2Der,
    required this.porJ3Izq,
    required this.porJ3Der,
    required this.porJ4Izq,
    required this.porJ4Der,
    required this.porJuego1,
    required this.porJuego2,
    required this.porJuego3,
    required this.porJuego4,
    required this.porLadoIzq,
    required this.porLadoDer,
  });

  factory Pesada9PlatosDetalle.fromDb(Map<String, dynamic> row) =>
      Pesada9PlatosDetalle(
        pesadaId: (row['pesada_id'] ?? 0) as int,
        enganche: (row['enganche'] ?? '').toString(),
        j1Izq: (row['j1_izq'] ?? '').toString(),
        j1Der: (row['j1_der'] ?? '').toString(),
        j2Izq: (row['j2_izq'] ?? '').toString(),
        j2Der: (row['j2_der'] ?? '').toString(),
        j3Izq: (row['j3_izq'] ?? '').toString(),
        j3Der: (row['j3_der'] ?? '').toString(),
        j4Izq: (row['j4_izq'] ?? '').toString(),
        j4Der: (row['j4_der'] ?? '').toString(),
        juego1: (row['juego1'] ?? '').toString(),
        juego2: (row['juego2'] ?? '').toString(),
        juego3: (row['juego3'] ?? '').toString(),
        juego4: (row['juego4'] ?? '').toString(),
        ladoIzq: (row['lado_izq'] ?? '').toString(),
        ladoDer: (row['lado_der'] ?? '').toString(),
        porEnganche: (row['por_enganche'] ?? '').toString(),
        porJ1Izq: (row['por_j1_izq'] ?? '').toString(),
        porJ1Der: (row['por_j1_der'] ?? '').toString(),
        porJ2Izq: (row['por_j2_izq'] ?? '').toString(),
        porJ2Der: (row['por_j2_der'] ?? '').toString(),
        porJ3Izq: (row['por_j3_izq'] ?? '').toString(),
        porJ3Der: (row['por_j3_der'] ?? '').toString(),
        porJ4Izq: (row['por_j4_izq'] ?? '').toString(),
        porJ4Der: (row['por_j4_der'] ?? '').toString(),
        porJuego1: (row['por_juego1'] ?? '').toString(),
        porJuego2: (row['por_juego2'] ?? '').toString(),
        porJuego3: (row['por_juego3'] ?? '').toString(),
        porJuego4: (row['por_juego4'] ?? '').toString(),
        porLadoIzq: (row['por_lado_izq'] ?? '').toString(),
        porLadoDer: (row['por_lado_der'] ?? '').toString(),
      );

  Map<String, dynamic> toDb() => {
    'pesada_id': pesadaId,
    'enganche': enganche,
    'j1_izq': j1Izq,
    'j1_der': j1Der,
    'j2_izq': j2Izq,
    'j2_der': j2Der,
    'j3_izq': j3Izq,
    'j3_der': j3Der,
    'j4_izq': j4Izq,
    'j4_der': j4Der,
    'juego1': juego1,
    'juego2': juego2,
    'juego3': juego3,
    'juego4': juego4,
    'lado_izq': ladoIzq,
    'lado_der': ladoDer,
    'por_enganche': porEnganche,
    'por_j1_izq': porJ1Izq,
    'por_j1_der': porJ1Der,
    'por_j2_izq': porJ2Izq,
    'por_j2_der': porJ2Der,
    'por_j3_izq': porJ3Izq,
    'por_j3_der': porJ3Der,
    'por_j4_izq': porJ4Izq,
    'por_j4_der': porJ4Der,
    'por_juego1': porJuego1,
    'por_juego2': porJuego2,
    'por_juego3': porJuego3,
    'por_juego4': porJuego4,
    'por_lado_izq': porLadoIzq,
    'por_lado_der': porLadoDer,
  };
}
