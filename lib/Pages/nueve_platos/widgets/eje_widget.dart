



import 'package:nueve_platos_cestari/Controllers/calculos_controllers.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EjeWidget extends StatelessWidget {
  String peso1;
  String peso2;
  String eje;
  final String label;
  
  EjeWidget({
    super.key,
    required this.peso1,
    required this.peso2,
    required this.eje,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: SizeScreen.sc().screenWidth * 0.25,
          padding: const EdgeInsets.symmetric( vertical: 4),
          decoration: BoxDecoration(
            color: ThemeApp.pesajeJuegoTitulo,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border.all()
          ),
          child: Center(child: 
            Text(
              label,
              style: ThemePlatos.cn.textoTitulosPlatos,
            ),
          ),
        ),
        Container(
          width: SizeScreen.sc().screenWidth * 0.25,
          decoration: BoxDecoration(
            color: ThemeApp.pesajeJuegoPeso,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
            border: Border.all()
          ),
          child: Column(
            mainAxisAlignment:  MainAxisAlignment.spaceAround,
            children: [
              Center(
                child: Text( 
                  CalculosController.cn.calculoEje(peso1, peso2),
                  style: ThemePlatos.cn.textoPesoPlatos(context),
                )
              ),
              Text( 
                '${CalculosController.cn.calculoPorcentajePorEje(eje, peso1, peso2)} %',
              ),
            ],
          ),
        ),
      ],
    );
  }
}