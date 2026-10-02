

import 'package:flutter/material.dart';

class BateryWidget extends StatelessWidget {
  final int batery;
  const BateryWidget({
    required  this.batery,
    super.key, 
  });

  final encendida = Colors.green;
  final apagada = Colors.transparent;

  @override
  Widget build(BuildContext context) {
   
    switch(batery){
      case 1:
      return const Icon(
        Icons.battery_1_bar,
        color: Color.fromARGB(255, 203, 230, 87),
      );
      case 2:
      return const Icon(
        Icons.battery_2_bar,
        color: Colors.green,
      );
      case 3:
      return const Icon(
        Icons.battery_4_bar,
        color: Colors.green,
      );
      case 4:
      return const Icon(
        Icons.battery_5_bar,
        color: Colors.green,
      );
      case 5:
      return const Icon(
        Icons.battery_6_bar,
        color: Colors.green,
      );
      default:
      return const Icon(
        Icons.battery_1_bar,
        color: Color.fromARGB(255, 237, 250, 57),
      );           
    }
  }
}