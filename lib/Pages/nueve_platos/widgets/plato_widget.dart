

import 'package:nueve_platos_cestari/Controllers/calculos_controllers.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/Pages/nueve_platos/widgets/batery_widget.dart';
import 'package:nueve_platos_cestari/Widgets/connection_widget.dart';
import 'package:nueve_platos_cestari/Widgets/widget_button.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/helpers/comandos_plato.dart';
import 'package:flutter/material.dart';

class PlatoWidget extends StatelessWidget {
  /// [buttonKeyPlato] debe tener como valor el numero de plato fisico
  /// ('1'..'9') al que se envian los comandos de cero y hold.
  const PlatoWidget({
    super.key,
    required this.numPlato,
    required this.pesoPlato,
    required this.buttonKeyPlato,
    required this.conexionPlato,
    required this.batery,
    required this.estable,
  });

  final String numPlato;
  final int batery;
  final String pesoPlato;
  final ValueKey buttonKeyPlato;
  final bool conexionPlato;
  final String estable;

  /// Envia cero o reset de hold al plato por TCP y avisa si no se pudo enviar.
  Future<void> _enviarComando(BuildContext context, {required bool cero}) async {
    final plato = int.tryParse(buttonKeyPlato.value.toString());
    if (plato == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final enviado = cero
        ? await ComandosPlato.enviarCero(plato)
        : await ComandosPlato.enviarResetHold(plato);

    if (!enviado) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('No se pudo enviar ${cero ? 'cero' : 'reset hold'} a $numPlato.'),
          backgroundColor: ThemePlatos.errorColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Color _colorEstable() {
    final valor = int.tryParse(estable) ?? 0;
    if (valor > 1) return Colors.blue;
    if (valor == 1) return Colors.greenAccent;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenWidth = media.size.width;
    final isSmallPhone = media.size.height < 700 || media.size.shortestSide < 380;
    final altoRecuadroPeso = (SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.116 : 0.14)).clamp(52.0, 120.0).toDouble();
    final estiloPeso = ThemePlatos.cn.textoPesoPlatos(context).copyWith(
      fontSize: isSmallPhone ? (screenWidth < 360 ? 14 : 16) : ThemePlatos.cn.textoPesoPlatos(context).fontSize,
    );
    final estiloPorcentaje = TextStyle(
      fontSize: isSmallPhone ? 10 : 12,
      height: 1.0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // Titulo de cada plato
        Container(
          width: SizeScreen.sc().screenWidth * 0.27,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: ThemePlatos.backgroundTitulos,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: Border.all()
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Título del plato; se achica si no entra (ENGANCHE en telefonos chicos)
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    numPlato, 
                    maxLines: 1,
                    style: ThemePlatos.cn.textoTitulosPlatos,
                  ),
                ),
              ),
              // Estado de la conexión
              ConnectionWidget( connection: conexionPlato),       
            ],
          )
        ),
        // Peso porcentaje y estable del plato
        Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          width: SizeScreen.sc().screenWidth * 0.27,
          height: altoRecuadroPeso,
          decoration: BoxDecoration(
            color: ThemePlatos.backgroundPeso,
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(10)),
            border: Border.all()
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Peso en el plato
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const Icon(Icons.battery_1_bar_outlined, color: Colors.transparent),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            pesoPlato,
                            maxLines: 1,
                            style: estiloPeso,
                          ),
                        ),
                      ),
                    ),
                    //Estado de la batería
                    BateryWidget(batery: batery),
                  ],
                ),
              ),
              // Muestra el porcentaje del plato
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  ('${CalculosController.cn.calculoPorcentajePlatos(pesoPlato)} %'),
                  maxLines: 1,
                  style: estiloPorcentaje,
                ),
              ),
              // Estado del estable
              Container(
                width: SizeScreen.sc().screenWidth * 0.15,
                height: SizeScreen.sc().screenWidth * 0.004,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: _colorEstable(),
                ),
              )
            ],
          )
        ),

        const SizedBox(height: 5),

        // Botones para enviar cero y hold
        SizedBox(
          width: SizeScreen.sc().screenWidth * 0.27,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              WidgetButton(
                ancho: SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.13 : 0.13),
                alto:  SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.065 : 0.09),
                borderRadius: 5,
                fontSize: SizeScreen.sc().screenWidth < 520 
                ? 12 : 16,
                /// Enviar cero a cada una de las balanzas
                onPress: () => _enviarComando(context, cero: true),
                texto: '> 0 <'
              ),
           
              WidgetButton(
                color1: Colors.amber.shade200,
                color2: const Color.fromARGB(255, 188, 148, 29),
                ancho: SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.13 : 0.13),
                alto:  SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.065 : 0.09),
                borderRadius: 5,
                fontSize: SizeScreen.sc().screenWidth < 520 
                ? 12 : 16,
                /// Enviar hold a cada una de las balanzas
                onPress: () => _enviarComando(context, cero: false),
                texto: '< H >'
              ),
            ],
          ),
        ),
        
      ],
    );
  }
}


