

import 'package:nueve_platos_cestari/Controllers/calculos_controllers.dart';
import 'package:nueve_platos_cestari/Controllers/ensayo_controller.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/Pages/nueve_platos/widgets/batery_widget.dart';
import 'package:nueve_platos_cestari/Widgets/connection_widget.dart';
import 'package:nueve_platos_cestari/Widgets/tabla_maniobra.dart';
import 'package:nueve_platos_cestari/Widgets/widget_button.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/helpers/comandos_plato.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PlatoWidget extends StatelessWidget {
  /// [buttonKeyPlato] debe tener como valor el numero de plato fisico
  /// ('1'..'9') al que se envia el comando de cero.
  const PlatoWidget({
    super.key,
    required this.numPlato,
    required this.pesoPlato,
    required this.buttonKeyPlato,
    required this.conexionPlato,
    required this.batery,
    required this.estable,
    this.estatico = '',
    this.maximo = '',
    this.minimo = '',
    this.ceroHabilitado = true,
    this.nivelAlarma = EstadoCelda.sinDato,
  });

  final String numPlato;
  final int batery;
  final String pesoPlato;
  final ValueKey buttonKeyPlato;
  final bool conexionPlato;
  final String estable;
  /// Peso estatico de referencia ('' si no se tomo).
  final String estatico;
  /// Maximo y minimo de la maniobra en curso ('' si no hay maniobra).
  final String maximo;
  final String minimo;
  /// false durante la maniobra: el boton > 0 < queda deshabilitado.
  final bool ceroHabilitado;
  /// Alarma contra la capacidad: con `alLimite` o `excede` el borde y el
  /// titulo se pintan de ambar o rojo. `normal` y `sinDato` no marcan nada.
  final EstadoCelda nivelAlarma;

  /// Envia cero al plato por TCP y avisa si no se pudo enviar.
  /// Si se envio, borra el estatico del ensayo, que deja de valer.
  Future<void> _enviarCero(BuildContext context) async {
    final plato = int.tryParse(buttonKeyPlato.value.toString());
    if (plato == null) return;

    final messenger = ScaffoldMessenger.of(context);
    final enviado = await ComandosPlato.enviarCero(plato);

    if (!enviado) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('No se pudo enviar cero a $numPlato.'),
          backgroundColor: ThemePlatos.errorColor,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (Get.find<EnsayoController>().borrarEstatico()) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Cero enviado a $numPlato. Volvé a tomar el estático.'),
          backgroundColor: ThemePlatos.positiveColor,
          duration: const Duration(seconds: 3),
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

  /// Color de la alarma (el mismo de la tabla de la maniobra), o null sin alarma.
  Color? get _colorAlarma => switch (nivelAlarma) {
        EstadoCelda.alLimite || EstadoCelda.excede => TablaManiobra.colorEstado(nivelAlarma),
        _ => null,
      };

  @override
  Widget build(BuildContext context) {
    final colorAlarma = _colorAlarma;
    final borde = colorAlarma == null ? Border.all() : Border.all(color: colorAlarma, width: 3);
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
            color: colorAlarma ?? ThemePlatos.backgroundTitulos,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
            border: borde
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
                    // En ambar el texto va en negro, como en la tabla.
                    style: nivelAlarma == EstadoCelda.alLimite
                        ? ThemePlatos.cn.textoTitulosPlatos.copyWith(color: Colors.black)
                        : ThemePlatos.cn.textoTitulosPlatos,
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
            border: borde
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

        // Estatico de referencia; la linea queda vacia si no se tomo
        SizedBox(
          width: SizeScreen.sc().screenWidth * 0.27,
          child: Text(
            estatico.isEmpty ? '' : 'E: $estatico',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: estiloPorcentaje,
          ),
        ),

        // Maximo / minimo en vivo durante la maniobra; vacia si no hay
        SizedBox(
          width: SizeScreen.sc().screenWidth * 0.27,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              maximo.isEmpty ? '' : '▲ $maximo  ▼ $minimo',
              maxLines: 1,
              style: estiloPorcentaje,
            ),
          ),
        ),

        const SizedBox(height: 3),

        // Boton para enviar cero, centrado bajo el plato
        SizedBox(
          width: SizeScreen.sc().screenWidth * 0.27,
          child: Center(
            child: IgnorePointer(
              ignoring: !ceroHabilitado,
              child: Opacity(
                opacity: ceroHabilitado ? 1 : 0.4,
                child: WidgetButton(
                  ancho: SizeScreen.sc().screenWidth * 0.22,
                  alto:  SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.065 : 0.09),
                  borderRadius: 5,
                  fontSize: SizeScreen.sc().screenWidth < 520
                  ? 12 : 16,
                  /// Enviar cero a la balanza del plato
                  onPress: () => _enviarCero(context),
                  texto: '> 0 <'
                ),
              ),
            ),
          ),
        ),
        
      ],
    );
  }
}


