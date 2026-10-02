import 'package:nueve_platos_cestari/models/pesadas/pesada_4platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';

class Pesada4PlatosPayload {
  final PesadaBase base;
  final Pesada4PlatosDetalle detalle;

  const Pesada4PlatosPayload({
    required this.base,
    required this.detalle,
  });
}
