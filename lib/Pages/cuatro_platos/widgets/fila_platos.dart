

import 'package:flutter/material.dart';

import 'package:cuatro_platos/Pages/cuatro_platos/widgets/eje_widget.dart';
import 'package:cuatro_platos/Pages/cuatro_platos/widgets/plato_widget.dart';


class FilaPlatos extends StatelessWidget {

  const FilaPlatos({
    super.key,
    required this.plato1, 
    required this.plato2,
    required this.label1,
    required this.label2,
    required this.eje,
    required this.buttonKeyPlato1,
    required this.buttonKeyPlato2,
    required this.estable1,
    required this.estable2,
  });

  final plato1;
  final plato2;
  final String label1;
  final String label2;
  final String eje;
  final ValueKey buttonKeyPlato1;
  final ValueKey buttonKeyPlato2;
  final String estable1;
  final String estable2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        PlatoWidget(
          numPlato: label1, 
          pesoPlato: plato1.peso, 
          buttonKeyPlato: buttonKeyPlato1,
          conexionPlato: plato1.conexion, 
          batery: plato1.tension,
          estable: estable1,
        ),
        EjeWidget(peso1: plato1.peso, peso2: plato2.peso, eje: eje),
        PlatoWidget(
          numPlato: label2, 
          pesoPlato: plato2.peso, 
          buttonKeyPlato: buttonKeyPlato2,
          conexionPlato: plato2.conexion, 
          batery: plato2.tension,
          estable: estable2,
        ),
      ],
    );
  }
}