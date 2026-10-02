



import 'package:nueve_platos_cestari/BaseDeDatos/services/settings/service_config.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/connections/db_conexion.dart';
import 'package:nueve_platos_cestari/Controllers/config_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso_controller.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/models/config_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpersConfig{

  static Future<void> _refreshScaleConnections() async {
    final cantidad = Get.find<ConfigController>().cantidadPlatos;

    await Future.wait([
      for (var n = 1; n <= cantidad; n++)
        Get.find<PesoController>(tag: 'plato$n').recibirPeso(),
    ]);
  }

  /// 
  /// Guarda en la base de datos, solo devuelve -1 
  /// si ocurre una excepcion al guardar.
  /// 
  static guardarConfig(ConfigModel config,BuildContext context)async{
    
    final serviceDb = ServiceConfig(DBconeccion.db);

    Navigator.pop(context);
    final scafold = ScaffoldMessenger.of(context); 

    final resp = await serviceDb.insertarConfig(config);

    if(resp == -1){
      scafold.showSnackBar(
        SnackBar(content: const Text('No se pudo guardar.'),backgroundColor: ThemePlatos.errorColor,)
      );
    }else{
      final configGetx = Get.find<ConfigController>();
      configGetx.setPuerto(1, config.plato1);
      configGetx.setPuerto(2, config.plato2);
      configGetx.setPuerto(3, config.plato3);
      configGetx.setPuerto(4, config.plato4);
      _refreshScaleConnections();
      scafold.showSnackBar(
        SnackBar(content: const Text('Datos guardados correctamente !!!'),backgroundColor:ThemePlatos.positiveColor,),
      );
    }
  }
  static upDateConfig(ConfigModel config,BuildContext context)async{
    
    final serviceDb = ServiceConfig(DBconeccion.db);

    Navigator.pop(context);
    final scafold = ScaffoldMessenger.of(context); 

    final resp = await serviceDb.upDateConfig(config);

    if(resp == -1){
      scafold.showSnackBar(
        SnackBar(content: const Text('No se pudo guardar.'),backgroundColor: ThemePlatos.errorColor,)
      );
    }else{
      final configGetx = Get.find<ConfigController>();
      configGetx.setPuerto(1, config.plato1);
      configGetx.setPuerto(2, config.plato2);
      configGetx.setPuerto(3, config.plato3);
      configGetx.setPuerto(4, config.plato4);
      _refreshScaleConnections();
      scafold.showSnackBar(
        SnackBar(content: const Text('Datos guardados correctamente !!!'),backgroundColor:ThemePlatos.positiveColor,),
      );
    }
  }


}
