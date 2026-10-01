import 'package:cuatro_platos/models/pesadas/pesada_4platos_model.dart';
import 'package:cuatro_platos/models/pesadas/pesada_base_model.dart';
import 'package:cuatro_platos/models/pesadas/pesada_ejes_model.dart';
import 'package:cuatro_platos/models/pesadas/pesada_eje_detalle_model.dart';

class Pesada4PlatosPayload {
  final PesadaBase base;
  final Pesada4PlatosDetalle detalle;

  const Pesada4PlatosPayload({
    required this.base,
    required this.detalle,
  });
}

class PesadaEjesPayload {
  final PesadaBase base;
  final PesadaEjesCabecera cabecera;
  final List<EjeDetalle> detalleEjes;

  const PesadaEjesPayload({
    required this.base,
    required this.cabecera,
    required this.detalleEjes,
  });
}
