
import 'package:flutter/material.dart';

import 'package:nueve_platos_cestari/Pages/nueve_platos/widgets/eje_widget.dart';
import 'package:nueve_platos_cestari/Pages/nueve_platos/widgets/plato_widget.dart';


/// Fila de un juego de celdas: plato izq, subtotal del juego y plato der.
class FilaPlatos extends StatelessWidget {

  const FilaPlatos({
    super.key,
    required this.izq,
    required this.der,
    required this.eje,
    required this.label,
  });

  final PlatoWidget izq;
  final PlatoWidget der;
  final String eje;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        izq,
        EjeWidget(peso1: izq.pesoPlato, peso2: der.pesoPlato, eje: eje, label: label),
        der,
      ],
    );
  }
}
