class PesadaEjesCabecera {
  final int pesadaId;
  final int cantidadEjes;
  final String ladoIzqTotal;
  final String ladoDerTotal;

  const PesadaEjesCabecera({
    required this.pesadaId,
    required this.cantidadEjes,
    required this.ladoIzqTotal,
    required this.ladoDerTotal,
  });

  factory PesadaEjesCabecera.fromDb(Map<String, dynamic> row) =>
      PesadaEjesCabecera(
        pesadaId: (row['pesada_id'] ?? 0) as int,
        cantidadEjes: (row['cantidad_ejes'] ?? 0) as int,
        ladoIzqTotal: (row['lado_izq_total'] ?? '').toString(),
        ladoDerTotal: (row['lado_der_total'] ?? '').toString(),
      );

  Map<String, dynamic> toDb() => {
    'pesada_id': pesadaId,
    'cantidad_ejes': cantidadEjes,
    'lado_izq_total': ladoIzqTotal,
    'lado_der_total': ladoDerTotal,
  };
}
