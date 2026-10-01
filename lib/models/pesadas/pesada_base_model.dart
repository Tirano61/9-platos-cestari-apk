class PesadaBase {
  final int? id;
  final String fecha;
  final String hora;
  final String identificacion;
  final String tipoPesada;
  final String total;
  final String createdAt;

  const PesadaBase({
    this.id,
    required this.fecha,
    required this.hora,
    required this.identificacion,
    required this.tipoPesada,
    required this.total,
    required this.createdAt,
  });

  factory PesadaBase.fromDb(Map<String, dynamic> row) => PesadaBase(
    id: row['id'] as int?,
    fecha: (row['fecha'] ?? '').toString(),
    hora: (row['hora'] ?? '').toString(),
    identificacion: (row['identificacion'] ?? '').toString(),
    tipoPesada: (row['tipo_pesada'] ?? '').toString(),
    total: (row['total'] ?? '0.00').toString(),
    createdAt: (row['created_at'] ?? '').toString(),
  );

  Map<String, dynamic> toDb() => {
    'fecha': fecha,
    'hora': hora,
    'identificacion': identificacion,
    'tipo_pesada': tipoPesada,
    'total': total,
    'created_at': createdAt,
  };
}
