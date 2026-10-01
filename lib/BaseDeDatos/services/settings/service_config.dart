


import 'package:cuatro_platos/BaseDeDatos/interfaces/settings/config_interfaces.dart';
import 'package:cuatro_platos/models/config_model.dart';


class ServiceConfig{

  late final ConfigInterface _configInterface;
  /// Servicio para utilizar la base de datos en las configuraciones 
  /// ``` 
  /// Future<int> insertarConfig(ConfigModel config)
  /// Future<int> upDateConfig(ConfigModel config)
  /// Future<List<ConfigModel>>getConfig()
  /// ```
  /// 
  ServiceConfig(ConfigInterface configInterface){
    _configInterface = configInterface;
  }
  /// Se utiliza para guardar la configuracion de puertos la primera
  /// vez que inicia la aplicación
  Future<int> insertarConfig(ConfigModel config){
    return _configInterface.insertConfig(config);
  }
  ///  Actualiza siempre la primera insercion en la base de datos
  ///  por que solo va a haber una lista de puertos disponible
  Future<int> upDateConfig(ConfigModel config){
    return _configInterface.upDateConfig(config);
  }

  Future<List<ConfigModel>>getConfig(){
    return _configInterface.getConfig();
  }

  Future<int> updateBleNameForPlato({
    required int plato,
    required String bleName,
    bool overwrite = false,
  }) {
    return _configInterface.updateBleNameForPlato(
      plato: plato,
      bleName: bleName,
      overwrite: overwrite,
    );
  }


}