import 'package:nueve_platos_cestari/models/pesadas/pesada_9platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';

class Pesada9PlatosPayload {
  final PesadaBase base;
  final Pesada9PlatosDetalle detalle;

  const Pesada9PlatosPayload({
    required this.base,
    required this.detalle,
  });
}
