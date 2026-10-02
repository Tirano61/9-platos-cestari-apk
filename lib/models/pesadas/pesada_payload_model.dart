import 'package:nueve_platos_cestari/models/pesadas/pesada_9platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';

class Pesada9PlatosPayload {
  final PesadaBase base;
  final Pesada9PlatosDetalle detalle;

  const Pesada9PlatosPayload({
    required this.base,
    required this.detalle,
  });

  /// Fila de la hoja '9_platos' del XLSX: cabecera, los 9 pesos, juegos,
  /// lados y todos los porcentajes. Las claves son las columnas de la base
  /// (sin pesada_id) y se usan como encabezado de la hoja.
  Map<String, dynamic> toExportRow() {
    final detalleDb = detalle.toDb()..remove('pesada_id');
    return {
      'id': base.id,
      'fecha': base.fecha,
      'hora': base.hora,
      'identificacion': base.identificacion,
      'total': base.total,
      ...detalleDb,
    };
  }
}
