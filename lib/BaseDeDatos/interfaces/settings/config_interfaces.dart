

import 'package:nueve_platos_cestari/models/config_model.dart';

abstract class ConfigInterface{

  Future<int> insertConfig(ConfigModel config);
  Future<List<ConfigModel>> getConfig();
  Future<int> upDateConfig(ConfigModel config);

}

