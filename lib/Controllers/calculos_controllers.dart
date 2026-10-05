import 'package:get/get.dart';

class CalculosController{


  static final CalculosController cn = CalculosController._();

  CalculosController._();
  
  var _sumaPesoPorEje = 0.0;
  var sumaEje = 0.0;

  String calculoEje( String peso1, String peso2 ){
    return (double.parse(peso1) + double.parse(peso2)).toStringAsFixed(2);
  }

  String calculoPorcentajePlatos(String pesoPlato){
    return pesoTotal != "0.00" ? (((double.tryParse(pesoPlato) ?? 0) * 100) / double.parse(pesoTotal) ).toPrecision(1).toString() : '0';
  }

  String calculoPorcentajePorEje( String eje, String peso1, String peso2){
    sumaEje = (double.tryParse(peso1) ?? 0) + (double.tryParse(peso2) ?? 0);
  
    return pesoTotal != "0.00" ? ((sumaEje * 100) / double.parse(pesoTotal)).toPrecision(1).toString() : '0';
  }

  String porcentajePorLado(String peso){
    return pesoTotal != "0.00" ? (double.parse(peso) * 100 / double.parse(pesoTotal) ).toPrecision(1).toString() : '0' ;
  }

  void setPesoTotalByList(List<String> pesos) {
    _sumaPesoPorEje = pesos.fold<double>(
      0,
      (sum, peso) => sum + (double.tryParse(peso) ?? 0),
    );
  }

  String get pesoTotal{
    return _sumaPesoPorEje.toStringAsFixed(2);
  }

}
