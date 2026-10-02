import 'package:nueve_platos_cestari/Controllers/calculos_controllers.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:flutter/material.dart';

/// Recuadro con el peso y el % de cada lado de la tolva.
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _lado(context, 'LADO IZQ', pesoIzquierdo),
        _lado(context, 'LADO DER', pesoDerecho),
      ],
    );
  }

  Widget _lado(BuildContext context, String titulo, String peso) {
    return Column(
      children: [
        Container(
          width: SizeScreen.sc().screenWidth * 0.35,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: ThemePlatos.cn.decoracionTituloPlatos,
          child: Center(child: Text(titulo, style: ThemePlatos.cn.textoTitulosPlatos)),
        ),
        Container(
          width: SizeScreen.sc().screenWidth * 0.35,
          height: SizeScreen.sc().screenWidth * 0.13,
          decoration: ThemePlatos.cn.decoracionPesoPlatos,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(peso, style: ThemePlatos.cn.textoPesoPlatos(context)),
                ),
              ),
              Text('${CalculosController.cn.porcentajePorLado(peso)} %')
            ],
          ),
        ),
      ],
    );
  }
}
