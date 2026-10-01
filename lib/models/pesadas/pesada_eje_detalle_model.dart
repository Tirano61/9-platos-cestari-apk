class EjeDetalle {
  final int nroEje;
  final String pesoIzq;
  final String pesoDer;
  final String pesoTotal;

  const EjeDetalle({
    required this.nroEje,
    required this.pesoIzq,
    required this.pesoDer,
    required this.pesoTotal,
  });

  factory EjeDetalle.fromJson(Map<String, dynamic> json) => EjeDetalle(
    nroEje: (json['nroEje'] ?? json['nro_eje'] ?? 0) as int,
    pesoIzq: (json['pesoIzq'] ?? json['peso_izq'] ?? '').toString(),
    pesoDer: (json['pesoDer'] ?? json['peso_der'] ?? '').toString(),
    pesoTotal: (json['pesoTotal'] ?? json['peso_total_eje'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'nroEje': nroEje,
    'pesoIzq': pesoIzq,
    'pesoDer': pesoDer,
    'pesoTotal': pesoTotal,
  };

  Map<String, dynamic> toDb({required int pesadaId}) => {
    'pesada_id': pesadaId,
    'nro_eje': nroEje,
    'peso_izq': pesoIzq,
    'peso_der': pesoDer,
    'peso_total_eje': pesoTotal,
  };
}
