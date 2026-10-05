
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/helpers/pesadas/helpers_pesadas.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_payload_model.dart';

import 'package:nueve_platos_cestari/Pages/nueve_platos/widgets/export_home_wigets.dart';
import 'package:nueve_platos_cestari/Controllers/controllers_export.dart';
import 'package:nueve_platos_cestari/Controllers/ensayo_controller.dart';




class NuevePlatosPage extends StatelessWidget {
  NuevePlatosPage({super.key});

  final pesoControllers = [
    for (var n = 1; n <= cantidadPlatos; n++) Get.find<PesoController>(tag: 'plato$n'),
  ];
  final ensayo = Get.find<EnsayoController>();

  @override
  Widget build(BuildContext context) {

    return Obx((){
      final pesos = [for (final c in pesoControllers) c.pesoModel.peso];
      CalculosController.cn.setPesoTotalByList(pesos);
      final separacion = SizeScreen.sc().screenWidth * 0.025;
      return Scaffold(
        appBar: AppBar(
          //backgroundColor: ThemePlatos.backgroundTitulos,
          // Nombre de la tolva del ensayo en curso.
          title: Text(
            ensayo.tolva.value.isEmpty ? 'Balanzas Hook' : ensayo.tolva.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
         
        ),
        body: Column(
          children: [
            // Barra de acciones fija bajo el AppBar
            const BarraEnsayo(),
            Expanded(
              child: _contenidoPlatos(pesos, separacion),
            ),
          ],
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(107, 3, 3, 3),
                offset: Offset(0.3, 3),
                blurRadius: 3,
                spreadRadius: 0.3,
                blurStyle: BlurStyle.normal
              ),
            ],
            borderRadius: BorderRadius.circular(50)
          ),
          child: IconButton(
            padding: EdgeInsets.all(SizeScreen.sc().isMinWidth ? 25 : 15),
            color: ThemeApp.colorPesoPlatos,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
                  if (states.contains(WidgetState.pressed)) {
                    return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                  }
                  return ThemeApp.colorPesoPlatos; 
                },
              ),
            ),
            icon: const Icon(Icons.save, color: Color.fromARGB(172, 255, 255, 255),),
            onPressed: ()async{
              /// Debe abrir dialogo para ingresar datos de la maquina
              /// Antes de abrir el dialogo debe verificar la conexión
              /// Se quito la verificación de conexion por que querian 
              /// usar una cantidad indeterminada de platos
                final payload = await CalculosController.cn.calcularPayload9Platos(
                  pesos: pesos,
                );
                if (!context.mounted) return;
                showDialogGuardarPesada(payload, context);
            }
          ),
        ),
        
      );
    });
  }

  /// Total, enganche, los 4 juegos y los lados, con scroll.
  Widget _contenidoPlatos(List<String> pesos, double separacion) {
    return SingleChildScrollView(
      // El padding de abajo deja libre el recuadro de lados bajo el FAB.
      padding: const EdgeInsets.only(bottom: 90),
      child: Column(
        children: [
          // Recuadro de Peso total sumado
          Padding(
            padding: EdgeInsets.only(top: SizeScreen.sc().screenWidth * 0.02, bottom: SizeScreen.sc().screenWidth * 0.035),
            child: RecuadroPesoTotal(
              suma: CalculosController.cn.pesoTotal
            ),
          ),
          // Enganche, centrado
          _platoWidget(1),
          // Juegos de celdas: J1 = platos 2/3 ... J4 = platos 8/9
          for (var juego = 1; juego <= 4; juego++)
            Padding(
              padding: EdgeInsets.only(top: separacion),
              child: FilaPlatos(
                izq: _platoWidget(juego * 2),
                der: _platoWidget(juego * 2 + 1),
                eje: '$juego',
                label: 'JUEGO $juego',
              ),
            ),
          // Lados: izq = platos 2, 4, 6, 8 y der = 3, 5, 7, 9. El enganche no suma.
          Padding(
            padding: EdgeInsets.only(top: separacion * 2),
            child: SumaLados(
              pesoIzquierdo: _sumaPesos([pesos[1], pesos[3], pesos[5], pesos[7]]),
              pesoDerecho:   _sumaPesos([pesos[2], pesos[4], pesos[6], pesos[8]]),
            ),
          ),
        ],
      ),
    );
  }

  /// PlatoWidget del plato [n] (1..9). La key del boton es el numero
  /// de plato al que se manda el cero.
  PlatoWidget _platoWidget(int n) {
    final plato = pesoControllers[n - 1].pesoModel;
    return PlatoWidget(
      numPlato: nombrePlato(n),
      pesoPlato: plato.peso,
      buttonKeyPlato: ValueKey('$n'),
      conexionPlato: plato.conexion,
      batery: plato.tension,
      estable: plato.estable,
    );
  }

  String _sumaPesos(List<String> pesos) => pesos
      .fold<double>(0, (sum, peso) => sum + (double.tryParse(peso) ?? 0))
      .toStringAsFixed(2);

  showDialogGuardarPesada(Pesada9PlatosPayload payload, BuildContext context){
    showDialog(
      context: context,
      builder: (_){

        return DialogWidget(
          onConfirm: (identificacion) {
            return HelpersPesadas.guardarPesada9PlatosPayload(
              payload: payload,
              identificacion: identificacion,
              context: context,
            );
          },
        );
      }
    );
  }
}









