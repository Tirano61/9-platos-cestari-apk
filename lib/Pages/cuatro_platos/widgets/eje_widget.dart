



import 'package:cuatro_platos/Controllers/calculos_controllers.dart';
import 'package:cuatro_platos/Theme/theme.dart';
import 'package:cuatro_platos/config/SizeScreen.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class EjeWidget extends StatelessWidget {
  String peso1;
  String peso2;
  String eje;
  final String? label;
  final bool showPorcentaje;
  
  EjeWidget({
    super.key,
    required this.peso1,
    required this.peso2,
    required this.eje,
    this.label,
    this.showPorcentaje = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: SizeScreen.sc().screenWidth * 0.25,
          padding: const EdgeInsets.symmetric( vertical: 10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(188, 5, 21, 76),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border.all()
          ),
          child: Center(child: 
            Text(
              label ?? (eje == '1' ? 'EJE  DEL' : 'EJE  TRAS'),
              style: ThemePlatos.cn.textoTitulosPlatos,
            ),
          ),
        ),
        Container(
          width: SizeScreen.sc().screenWidth * 0.25,
          decoration: BoxDecoration(
            color: const Color.fromARGB(147, 0, 93, 254),
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
              if (showPorcentaje)
                Text( 
                  '${CalculosController.cn.calculoPorcentajePorEje(eje, peso1, peso2)} %',
                )
              else
                const SizedBox(height: 18),
            ],
          ),
        ),
      ],
    );
  }
}