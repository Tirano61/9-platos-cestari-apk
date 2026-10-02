



import 'package:nueve_platos_cestari/BaseDeDatos/services/settings/service_config.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/connections/db_conexion.dart';
import 'package:nueve_platos_cestari/Controllers/config_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso1_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso2_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso3_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso4_controller.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/models/config_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HelpersConfig{

  static Future<void> _refreshScaleConnections() async {
    final peso1 = Get.find<Peso1Controller>();
    final peso2 = Get.find<Peso2Controller>();
    final peso3 = Get.find<Peso3Controller>();
    final peso4 = Get.find<Peso4Controller>();

    await Future.wait([
      peso1.recibirPeso1(),
      peso2.recibirPeso2(),
      peso3.recibirPeso3(),
      peso4.recibirPeso4(),
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
      configGetx.setPuerto1(config.plato1);
      configGetx.setPuerto2(config.plato2);
      configGetx.setPuerto3(config.plato3);
      configGetx.setPuerto4(config.plato4);
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
      configGetx.setPuerto1(config.plato1);
      configGetx.setPuerto2(config.plato2);
      configGetx.setPuerto3(config.plato3);
      configGetx.setPuerto4(config.plato4);
      _refreshScaleConnections();
      scafold.showSnackBar(
        SnackBar(content: const Text('Datos guardados correctamente !!!'),backgroundColor:ThemePlatos.positiveColor,),
      );
    }
  }


}
