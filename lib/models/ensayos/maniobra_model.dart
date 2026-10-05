import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';

/// Una maniobra del ensayo: cabecera (tmaniobras) y el resultado de cada plato
/// (tmaniobras_platos, indice 0 = plato 1).
class ManiobraModel {
  const ManiobraModel({
    this.id,
    this.ensayoId,
    required this.numero,
    required this.horaInicio,
    required this.horaFin,
    required this.duracionMs,
    required this.umbral,
    required this.platos,
  });

  /// null mientras no se guardo en la base.
  final int? id;
  final int? ensayoId;

  /// Numero dentro del ensayo (1, 2, 3...).
  final int numero;

  /// HH:mm:ss.
  final String horaInicio;
  final String horaFin;
  final int duracionMs;

  /// Umbral de alarma (%) del ensayo, copiado en cada maniobra: el de
  /// SharedPreferences cambia en el proximo ensayo.
  final String umbral;

  final List<ManiobraPlato> platos;

  bool get guardada => id != null;

  Duration get duracion => Duration(milliseconds: duracionMs);

  factory ManiobraModel.fromDb(Map<String, dynamic> row, {required List<ManiobraPlato> platos}) =>
      ManiobraModel(
        id: row['id'] as int?,
        ensayoId: row['ensayo_id'] as int?,
        numero: row['numero'] as int,
        horaInicio: (row['hora_inicio'] ?? '').toString(),
        horaFin: (row['hora_fin'] ?? '').toString(),
        duracionMs: (row['duracion_ms'] as int?) ?? 0,
        umbral: (row['umbral'] ?? '').toString(),
        platos: platos,
      );

  /// Fila de tmaniobras (sin id; los platos van aparte).
  Map<String, dynamic> toDb() => {
        'ensayo_id': ensayoId,
        'numero': numero,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
        'duracion_ms': duracionMs,
        'umbral': umbral,
      };

  ManiobraModel copyWith({int? id, int? ensayoId}) => ManiobraModel(
        id: id ?? this.id,
        ensayoId: ensayoId ?? this.ensayoId,
        numero: numero,
        horaInicio: horaInicio,
        horaFin: horaFin,
        duracionMs: duracionMs,
        umbral: umbral,
        platos: platos,
      );
}
