


import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/pesadas/pesadas_interfaces.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_9platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_payload_model.dart';

import '../list_pesajes/list_pesaje.dart';

class DbConnectionMock extends PesadasInterface{
  @override
  Future<int> deletePesada(String id)async {
    return 1;
  }

  @override
  Future<int> deletePesadas()async {
    return 1;
  }

  @override
  Future<List<Map<String, dynamic>>> getPesadasExportacion()async {
    return listPesaje;
  }

  @override
  Future<List<Pesada9PlatosPayload>> getPesadas9Platos() async {
    return [pesada9PlatosEjemplo];
  }

  @override
  Future<int> insertPesada9Platos({
    required PesadaBase base,
    required Pesada9PlatosDetalle detalle,
  }) async {
    return 1;
  }


}


