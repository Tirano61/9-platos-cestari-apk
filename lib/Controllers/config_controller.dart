

import 'package:get/get.dart';

class ConfigController extends GetxController{

  final _puerto1 = '8001'.obs;
  final _puerto2 = '8002'.obs;
  final _puerto3 = '8003'.obs;
  final _puerto4 = '8004'.obs;

  get getPuerto1{
    return _puerto1;
  }
  setPuerto1(String puerto){
    _puerto1.value = puerto;
  }

  get getPuerto2{
    return _puerto2;
  }
  setPuerto2(String puerto){
    _puerto2.value = puerto;
  }

  get getPuerto3{
    return _puerto3;
  }
  setPuerto3(String puerto){
    _puerto3.value = puerto;
  }

  get getPuerto4{
    return _puerto4;
  }
  setPuerto4(String puerto){
    _puerto4.value = puerto;
  }

}
