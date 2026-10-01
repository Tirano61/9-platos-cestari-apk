class ScaleReading {
  ScaleReading({
    required this.peso,
    required this.estable,
    required this.tension,
    required this.sourceId,
    DateTime? receivedAt,
  }) : receivedAt = receivedAt ?? DateTime.now();

  final String peso;
  final String estable;
  final String tension;
  final String sourceId;
  final DateTime receivedAt;
}
