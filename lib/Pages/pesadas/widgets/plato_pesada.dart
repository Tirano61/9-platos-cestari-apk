

import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:flutter/material.dart';

class PlatoPesadas extends StatelessWidget {
  final String title;
  final String peso;
  final String porcentaje;
  const PlatoPesadas({
    required this.title, 
    required this.peso, 
    required this.porcentaje,
    super.key});

  @override
  Widget build(BuildContext context) {
    final showPorcentaje = porcentaje.trim().isNotEmpty;

    return Container(
      width:  SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.16 : 0.2) ,
      height: SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.06 : 0.09),
      
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: ThemeApp.colorPesoPlatos,
      ),
      child: Row(
        children: [
          Expanded(
            flex: showPorcentaje ? 2 : 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  width: double.infinity,
                  color: ThemeApp.colorTituloPlatos,
                  child: Text(title, style: ThemeApp.fontWithtitlePlatosPesadas)
                ),
                Expanded(
                  child: Center(
                    child: Text(peso , style: ThemeApp.fontPlatosPesadas)
                  )
                ),
              ],
            ),
          ),
          if (showPorcentaje)
            Expanded(flex: 1 ,
              child: Container(
                color: ThemeApp.colorTarjetaPesaadas,
                child: Center(
                  child: Text('$porcentaje%', style: ThemeApp.fontPlatosPesadas),
                ),
              ),
            )
        ],
      ),
    );
  }
}