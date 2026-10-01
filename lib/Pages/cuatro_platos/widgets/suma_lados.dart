

import 'package:cuatro_platos/Controllers/calculos_controllers.dart';
import 'package:cuatro_platos/Theme/theme.dart';
import 'package:cuatro_platos/config/SizeScreen.dart';
import 'package:flutter/material.dart';

class SumaLados extends StatelessWidget {
   final String pesoIzquierdo;
   final String pesoDerecho;

  const SumaLados({
    super.key,
    required this.pesoIzquierdo,
    required this.pesoDerecho,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: SizeScreen.sc().screenWidth / (SizeScreen.sc().isMinWidth ? 5.5 :  5),
          left: SizeScreen.sc().screenWidth * 0.1,
          child: Column(
            children: [
              Container(
                width: ThemePlatos.cn.widthTituloSumaLados(context),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: ThemePlatos.cn.decoracionTituloPlatos,
                child:  Center(child: Text('LADO IZQ', style: ThemePlatos.cn.textoTitulosPlatos)),
              ),
              Container(
                width: ThemePlatos.cn.widthTituloSumaLados(context),
                height: SizeScreen.sc().screenWidth * 0.13,
                decoration: ThemePlatos.cn.decoracionPesoPlatos,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Center(
                      child: Text( pesoIzquierdo, style: ThemePlatos.cn.textoPesoPlatos(context))
                    ),
                    Text('${CalculosController.cn.porcentajePorLado( pesoIzquierdo)} %')
                  ],
                ),
              ),
            ],
          ),
        ),

        Positioned(
          top: SizeScreen.sc().screenWidth / (SizeScreen.sc().isMinWidth ? 5.5 :  5),
          right: SizeScreen.sc().screenWidth * 0.1,
          child: Column(
            children: [
              Container(
                width: ThemePlatos.cn.widthTituloSumaLados(context),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: ThemePlatos.backgroundTitulos,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  border: Border.all()
                ),
                child: Center(child: Text('LADO DER', style: ThemePlatos.cn.textoTitulosPlatos)),
              ),
              Container(
                height: SizeScreen.sc().screenWidth * 0.13,
                width: ThemePlatos.cn.widthTituloSumaLados(context),
                decoration: ThemePlatos.cn.decoracionPesoPlatos,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Center(
                      child: Text( pesoDerecho, style: ThemePlatos.cn.textoPesoPlatos(context))
                    ),
                    Text('${CalculosController.cn.porcentajePorLado( pesoDerecho)} %')
                  ],
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Image(
            height: SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.6 : 0.75),
            image: const AssetImage('assets/chasis.png'),
          ),
        ),
      ],
    );
  }
}

