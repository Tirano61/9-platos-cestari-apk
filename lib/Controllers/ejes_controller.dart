
import 'package:get/get.dart';

class EjesController extends GetxController{

  final _eje         = 1.obs;
  final _totalPlato1 = '0'.obs;
  final _totalPlato2 = '0'.obs;
  final _totalPlato3 = '0'.obs;
  final _totalPlato4 = '0'.obs;
  final _saveEje1    = false.obs;
  final _saveEje2    = false.obs;
  final _porcentPlato1 = '0.0'.obs;
  final _porcentPlato2 = '0.0'.obs;
  final _porcentPlato3 = '0.0'.obs;
  final _porcentPlato4 = '0.0'.obs;
  final _porcentEje1   = '0.0'.obs;
  final _porcentEje2   = '0.0'.obs;

  get getEje {
    return _eje;
  }
  setEje(int eje){
    _eje.value = eje; 
  }

  get getTotalPlato1{
    return _totalPlato1;
  }
  get getTotalPlato2{
    return _totalPlato2;
  }
  get getTotalPlato3{
    return _totalPlato3;
  }
  get getTotalPlato4{
    return _totalPlato4;
  }
  setTotalPlato1(String total){
    _totalPlato1.value = total;
  }
  setTotalPlato2(String total){
    _totalPlato2.value = total;
  }
  setTotalPlato3(String total){
    _totalPlato3.value = total;
  }
  setTotalPlato4(String total){
    _totalPlato4.value = total;
  }

  get getSaveEje1{
    return _saveEje1;
  }
  get getSaveEje2{
    return _saveEje2;
  }
  setSaveEje1(bool save){
    _saveEje1.value = save;
  }
  setSaveEje2(bool save){
    _saveEje2.value = save;
  }

  get getPorcentPlato1{
    return _porcentPlato1;
  }
  get getporcentPlato2{
    return _porcentPlato2;
  }
  get getporcentPlato3{
    return _porcentPlato3;
  }
  get getporcentPlato4{
    return _porcentPlato4;
  }
  setPorcentPlato1(String porcent){
    _porcentPlato1.value = porcent;
  }
  setPorcentPlato2(String porcent){
    _porcentPlato2.value = porcent;
  }
  setPorcentPlato3(String porcent){
    _porcentPlato3.value = porcent;
  }
  setPorcentPlato4(String porcent){
    _porcentPlato4.value = porcent;
  }

  get porcentEje1{
    return _porcentEje1;
  }
  get porcentEje2{
    return _porcentEje2;
  }
  setPorcentEje1(String porcent){
    _porcentEje1.value = porcent;
  }
  setPorcentEje2(String porcent){
    _porcentEje2.value = porcent;
  }

}