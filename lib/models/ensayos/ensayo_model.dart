import 'package:nueve_platos_cestari/models/ensayos/maniobra_model.dart';

/// Ensayo de una tolva (tensayos) con sus maniobras.
class EnsayoModel {
  const EnsayoModel({
    this.id,
    required this.tolva,
    required this.fecha,
    required this.createdAt,
    this.maniobras = const [],
  });

  final int? id;

  /// Identificacion de la tolva.
  final String tolva;

  /// dd/MM/yyyy.
  final String fecha;

  /// ISO 8601.
  final String createdAt;

  /// Ordenadas por numero.
  final List<ManiobraModel> maniobras;

  factory EnsayoModel.fromDb(Map<String, dynamic> row, {List<ManiobraModel> maniobras = const []}) =>
      EnsayoModel(
        id: row['id'] as int?,
        tolva: (row['tolva'] ?? '').toString(),
        fecha: (row['fecha'] ?? '').toString(),
        createdAt: (row['created_at'] ?? '').toString(),
        maniobras: maniobras,
      );

  /// Fila de tensayos (sin id; las maniobras van aparte).
  Map<String, dynamic> toDb() => {
        'tolva': tolva,
        'fecha': fecha,
        'created_at': createdAt,
      };
}
