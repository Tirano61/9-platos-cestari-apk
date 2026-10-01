

import 'package:cuatro_platos/models/config_model.dart';

abstract class ConfigInterface{

  Future<int> insertConfig(ConfigModel config);
  Future<List<ConfigModel>> getConfig();
  Future<int> upDateConfig(ConfigModel config);
  Future<int> updateBleNameForPlato({
    required int plato,
    required String bleName,
    bool overwrite = false,
  });

}

