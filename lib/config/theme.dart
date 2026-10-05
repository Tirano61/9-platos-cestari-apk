

import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:flutter/material.dart';

class ThemeApp{

  static final ThemeApp _theme = ThemeApp._internal();
  
  ThemeApp._internal();

  factory ThemeApp.th() => _theme;


  TextStyle  textoTitulosPlatos = const TextStyle( color: Colors.white );

  static Color backgroundTitulos = const Color(0xFF153a65);
  static Color backgroundPeso    = const Color.fromRGBO(1, 40, 108, 0.5);
  static Color errorColor        = const Color.fromRGBO(247, 75, 63, 0.8);
  static Color positiveColor     = const Color.fromRGBO(53, 134, 55, 0.8);

  /// Styles de fuentes para uso generales
  static final fontStandard = TextStyle( fontSize: SizeScreen.sc().isMinWidth ? 14 : 11);
  //static const fontStandardMin = TextStyle( fontSize: 11);
  static final fontIdentificacionPesadas    = TextStyle( fontSize: SizeScreen.sc().isMinWidth ? 16 : 14, fontWeight: FontWeight.bold);
  //static const fontIdentificacionPesadasMin = TextStyle( fontSize: 14, fontWeight: FontWeight.bold);
  /// Platos pesadas
  static const colorTituloPlatos = Color(0xFF153a65);
  static const colorPesoPlatos = Color.fromARGB(255, 108, 140, 166);
  /// Tarjeta para visualizaar pesadas
  static const colorTarjetaPesaadas = Color.fromARGB(173, 239, 239, 239);
  /// Sombra de las tarjetas
  static const shadowColor = Color.fromARGB(117, 96, 96, 96);
}