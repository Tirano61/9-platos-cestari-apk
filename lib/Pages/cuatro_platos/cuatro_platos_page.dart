
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/helpers/pesadas/helpers_pesadas.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_payload_model.dart';

import 'package:nueve_platos_cestari/Pages/cuatro_platos/widgets/export_home_wigets.dart';
import 'package:nueve_platos_cestari/Controllers/controllers_export.dart';




class CuatroPlatosPage extends StatelessWidget {
  CuatroPlatosPage({super.key});

  final pesoControllers = [
    for (var n = 1; n <= cantidadPlatos; n++) Get.find<PesoController>(tag: 'plato$n'),
  ];

  @override
  Widget build(BuildContext context) {

    return Obx((){
      // El total y el guardado usan los 9 platos; hasta el PR 8 la pantalla
      // solo dibuja los platos 1..4.
      final pesos = [for (final c in pesoControllers) c.pesoModel.peso];
      final plato1 = pesoControllers[0].pesoModel;
      final plato2 = pesoControllers[1].pesoModel;
      final plato3 = pesoControllers[2].pesoModel;
      final plato4 = pesoControllers[3].pesoModel;
      CalculosController.cn.setPesoTotalByList(pesos);
      return Scaffold(
        appBar: AppBar(
          //backgroundColor: ThemePlatos.backgroundTitulos,
          title: const Text( 'Balanzas Hook'),
         
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Recuadro de Peso total sumado  
              Padding(
                padding: EdgeInsets.only(top: SizeScreen.sc().screenWidth * 0.02, bottom: SizeScreen.sc().screenWidth * 0.035),
                child: RecuadroPesoTotal(
                  suma: CalculosController.cn.pesoTotal
                ),
              ),
              /// Fila de platos eje delantero
              FilaPlatos(
                plato1: plato1, 
                plato2: plato2, 
                label1: 'DEL IZQ', 
                label2: 'DEL DER', 
                eje: '1', 
                buttonKeyPlato1: const ValueKey('1'), 
                buttonKeyPlato2: const ValueKey('2'),
                estable1: plato1.estable,
                estable2: plato2.estable,
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: SizeScreen.sc().screenWidth * 0.025),
                child:  SumaLados(
                  pesoIzquierdo:(double.parse( plato1.peso ) + double.parse(plato3.peso)).toStringAsFixed(2),
                  pesoDerecho:  (double.parse( plato2.peso ) + double.parse(plato4.peso )).toStringAsFixed(2)),
              ),
              // Fila de platos eje trasero  
              FilaPlatos(
                plato1: plato3, 
                plato2: plato4, 
                label1: 'TRAS IZQ', 
                label2: 'TRAS DER', 
                eje: '2', 
                buttonKeyPlato1: const ValueKey('3'), 
                buttonKeyPlato2: const ValueKey('4'),
                estable1: plato3.estable, 
                estable2: plato4.estable,
              ),
            ],
          )
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
              /* if(plato1.conexion && plato2.conexion && plato3.conexion && plato4.conexion ){
                 }else{
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Los platos deben estar conectados'), backgroundColor: ThemePlatos.backgroundPeso));
                 } */
            }
          ),
        ),
        
      );
    });
  }

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









