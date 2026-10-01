

import 'package:cuatro_platos/config/SizeScreen.dart';
import 'package:flutter/material.dart';

class ThemePlatos{


  static final ThemePlatos cn = ThemePlatos._();
  ThemePlatos._();


  TextStyle  textoTitulosPlatos = const TextStyle( color: Colors.white );

  static Color backgroundTitulos = const Color.fromRGBO(5, 21, 76, 0.7);
  static Color backgroundPeso    = const Color.fromRGBO(1, 40, 108, 0.5);
  static Color errorColor        = const Color.fromRGBO(247, 75, 63, 0.8);
  static Color positiveColor     = const Color.fromRGBO(53, 134, 55, 0.8);

  
  
  BoxDecoration decoracionPesoPlatos = BoxDecoration(
                  color: backgroundPeso,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
                  border: Border.all()
                );

  BoxDecoration decoracionTituloPlatos = BoxDecoration(
                  color: backgroundTitulos,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  border: Border.all()
                );

  widthTituloSumaLados(BuildContext context){
    return SizeScreen.sc().screenWidth * 0.23;
  } 
  
  posisionTopTituloSumaLados(BuildContext context){
    return MediaQuery.of(context).size.height / 7.5;
  } 

  TextStyle textoPesoPlatos(BuildContext context){
    final theme = TextStyle(
                fontSize: SizeScreen.sc().screenWidth < 520 ? 18 : 24,
                fontWeight: FontWeight.w500
              );
    return theme;
  }
  /* TextStyle textoPorcentajePlatos(BuildContext context){
    final theme = TextStyle(
                fontSize: SizeScreen.sc().screenWidth < 520 ? 16 : 22,
                fontWeight: FontWeight.w500
              );
    return theme;
  } */

}