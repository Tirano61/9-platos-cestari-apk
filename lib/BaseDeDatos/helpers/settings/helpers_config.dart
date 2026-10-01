



import 'package:cuatro_platos/BaseDeDatos/services/settings/service_config.dart';
import 'package:cuatro_platos/BaseDeDatos/connections/db_conexion.dart';
import 'package:cuatro_platos/Controllers/config_controller.dart';
import 'package:cuatro_platos/Controllers/peso1_controller.dart';
import 'package:cuatro_platos/Controllers/peso2_controller.dart';
import 'package:cuatro_platos/Controllers/peso3_controller.dart';
import 'package:cuatro_platos/Controllers/peso4_controller.dart';
import 'package:cuatro_platos/Theme/theme.dart';
import 'package:cuatro_platos/models/config_model.dart';
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
      configGetx.setConnectionType(config.connectionType);
      configGetx.setPlato1BleName(config.plato1BleName);
      configGetx.setPlato2BleName(config.plato2BleName);
      configGetx.setPlato3BleName(config.plato3BleName);
      configGetx.setPlato4BleName(config.plato4BleName);
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
      configGetx.setConnectionType(config.connectionType);
      configGetx.setPlato1BleName(config.plato1BleName);
      configGetx.setPlato2BleName(config.plato2BleName);
      configGetx.setPlato3BleName(config.plato3BleName);
      configGetx.setPlato4BleName(config.plato4BleName);
      _refreshScaleConnections();
      scafold.showSnackBar(
        SnackBar(content: const Text('Datos guardados correctamente !!!'),backgroundColor:ThemePlatos.positiveColor,),
      );
    }
  }

  static Future<int> guardarNombreBlePrimerVinculo({
    required int plato,
    required String bleName,
  }) async {
    final nombreNormalizado = bleName.trim();
    if (nombreNormalizado.isEmpty) return -1;

    final serviceDb = ServiceConfig(DBconeccion.db);
    final resp = await serviceDb.updateBleNameForPlato(
      plato: plato,
      bleName: nombreNormalizado,
      overwrite: false,
    );

    // No se toca connectionType: solo se llega aca conectando por BLE, y si el
    // usuario paso a WiFi mientras tanto, forzar BLE pisaria su eleccion.
    if (resp >= 0) {
      final configGetx = Get.find<ConfigController>();
      configGetx.setBleNameByPlato(plato, nombreNormalizado);
    }

    return resp;
  }


}
