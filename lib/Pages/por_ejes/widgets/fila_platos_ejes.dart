
// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:cuatro_platos/Pages/cuatro_platos/widgets/plato_widget.dart';

class FilaPlatosEjes extends StatelessWidget {
  /// FILA DE PLATOS
  /// El nº1 es plato izquierdo de la pantala, en el centro esta el peso
  /// total del eje y el porcentaje, y a la derecha el plato nº2
  const FilaPlatosEjes({
    super.key,
    required this.plato1, 
    required this.plato2,
    required this.label1,
    required this.label2,
    required this.buttonKeyPlato1,
    required this.buttonKeyPlato2,
    required this.estable1,
    required this.estable2,
    required this.activo,
    required this.widget,
    required this.pesoPlato1,
    required this.pesoPlato2,
    this.showPorcentaje = true,
  });
  
  final plato1;
  final plato2;
  final String pesoPlato1;
  final String pesoPlato2;
  final String label1;
  final String label2;
  final ValueKey buttonKeyPlato1;
  final ValueKey buttonKeyPlato2;
  final String estable1;
  final String estable2;
  final bool activo;
  final Widget widget;
  final bool showPorcentaje;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PlatoWidget(
          numPlato: label1, 
          pesoPlato: pesoPlato1 , 
          buttonKeyPlato: buttonKeyPlato1,
          conexionPlato: activo ? plato1.conexion : false, 
          batery: activo ? plato1.tension : 0,
          estable: activo ? estable1 : '0',
          showPorcentaje: showPorcentaje,
        ),

        widget,
        
        PlatoWidget(
          numPlato: label2, 
          pesoPlato:  pesoPlato2 , 
          buttonKeyPlato: buttonKeyPlato2,
          conexionPlato: activo ? plato2.conexion : false, 
          batery: activo ? plato2.tension : 0,
          estable: activo ? estable2 : '0',
          showPorcentaje: showPorcentaje,
        ),
      ],
    );
  }
}