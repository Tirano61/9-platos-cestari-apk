



import 'package:nueve_platos_cestari/BaseDeDatos/connections/db_conexion.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/services/pesadas/service_pesadas.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_payload_model.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:flutter/material.dart';

class HelpersPesadas{

  ///
  /// Guarda en la base de datos, solo devuelve -1
  /// si ocurre una excepcion al guardar.
  ///
  static Future<bool> guardarPesada9PlatosPayload({
    required Pesada9PlatosPayload payload,
    required String identificacion,
    required BuildContext context,
  }) async {
    final serviceDb = ServicePesadas(DBconeccion.db);
    final scafold = ScaffoldMessenger.of(context);

    final base = PesadaBase(
      id: payload.base.id,
      fecha: payload.base.fecha,
      hora: payload.base.hora,
      identificacion: identificacion,
      tipoPesada: payload.base.tipoPesada,
      total: payload.base.total,
      createdAt: payload.base.createdAt,
    );

    final resp = await serviceDb.insertarPesada9Platos(
      base: base,
      detalle: payload.detalle,
    );

    final success = resp != -1;
    if (!success) {
      scafold.showSnackBar(
        SnackBar(
          content: const Text('No se pudo guardar.'),
          backgroundColor: ThemePlatos.errorColor,
        ),
      );
    } else {
      scafold.showSnackBar(
        SnackBar(
          content: const Text('Datos guardados correctamente !!!'),
          backgroundColor: ThemePlatos.positiveColor,
        ),
      );
    }

    return success;
  }

  ///
  ///Borrar todas las pesadas de la base de daatos
  ///
  static borrarTodasPesadas()async {
    final serviceDB = ServicePesadas(DBconeccion.db);
    await Future.delayed(Duration.zero).then((value){
      serviceDB.deletePesadas();
    }); 
  }

}