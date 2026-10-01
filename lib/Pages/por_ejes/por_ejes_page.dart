
import 'package:cuatro_platos/Controllers/ejes_controller.dart';
import 'package:cuatro_platos/Pages/por_ejes/widgets/fila_platos_ejes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cuatro_platos/config/SizeScreen.dart';
import 'package:cuatro_platos/config/theme.dart';
import 'package:cuatro_platos/BaseDeDatos/helpers/pesadas/helpers_pesadas.dart';
import 'package:cuatro_platos/models/pesadas/pesada_payload_model.dart';
import 'package:cuatro_platos/Pages/cuatro_platos/widgets/export_home_wigets.dart';
import 'package:cuatro_platos/Controllers/controllers_export.dart';

class PorEjesPage extends StatelessWidget {
  PorEjesPage({super.key});

  final peso1GetxController = Get.find<Peso1Controller>(); 
  final peso2GetxController = Get.find<Peso2Controller>(); 
  final ejesController = Get.find<EjesController>(); 
  final style = const TextStyle(fontSize: 8, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {

    return Obx((){
      final plato1 = peso1GetxController.getPesoModel1;
      final plato2 = peso2GetxController.getPesoModel2;
      final int ejes = ejesController.getEje.value;
      if(ejes == 1){
        if(!ejesController.getSaveEje1.value){
          ejesController.setTotalPlato1(double.parse(plato1.peso).toStringAsFixed(2));
          ejesController.setTotalPlato2(double.parse(plato2.peso).toStringAsFixed(2));
        }
      }else{
        if(!ejesController.getSaveEje2.value){
          ejesController.setTotalPlato3(double.parse(plato1.peso).toStringAsFixed(2));
          ejesController.setTotalPlato4(double.parse(plato2.peso).toStringAsFixed(2));
        }
      }

      CalculosController.cn.setPesoTotal(
        ejesController.getTotalPlato1.value, 
        ejesController.getTotalPlato2.value, 
        ejesController.getTotalPlato3.value, 
        ejesController.getTotalPlato4.value
      );

      return Scaffold(
        appBar: AppBar(
          //backgroundColor: ThemePlatos.backgroundTitulos,
          title: const Text( 'Pesaje Por Ejes'),
         
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //! Recuadro de Peso total sumado  
              Padding(
                padding: EdgeInsets.only(top: SizeScreen.sc().screenWidth * 0.02, bottom: SizeScreen.sc().screenWidth * 0.035),
                child: RecuadroPesoTotal(
                  suma: (double.parse(ejesController.getTotalPlato1.value) + 
                      double.parse(ejesController.getTotalPlato2.value) +
                      double.parse(ejesController.getTotalPlato3.value) +
                      double.parse(ejesController.getTotalPlato4.value)
                    ).toStringAsFixed(2) 
                ),
              ),
              //! Fila de platos eje delantero
              Container(
                decoration: BoxDecoration(
                  color: ejes == 1 ? const Color.fromARGB(124, 98, 202, 254) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12)
                ),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(vertical: 10),
                //color: ejes == 1 ? const Color.fromARGB(124, 98, 202, 254) : Colors.transparent,
                child: GestureDetector(
                  onTap: (){
                    ejesController.setEje(1); 
                    ejesController.setSaveEje1(false);
                  },
                  child: FilaPlatosEjes(
                    widget: Column(
                      children: [
                        ejesController.getEje.value == 1 ? Text('EJE SELECCIONADO', style: style): Text('',style: style),
                        EjeWidget(
                          peso1: ejesController.getTotalPlato1.value, 
                          peso2: ejesController.getTotalPlato2.value, 
                          eje: '1'
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: (){
                            ejesController.setSaveEje1(true);
                            ejesController.setTotalPlato1(double.parse(plato1.peso).toStringAsFixed(2));
                            ejesController.setTotalPlato2(double.parse(plato2.peso).toStringAsFixed(2));
                          }, 
                          child: const Text('Guardar Eje DEL')
                        ),

                      ],
                    ),
                    pesoPlato1: ejesController.getTotalPlato1.value,
                    pesoPlato2: ejesController.getTotalPlato2.value,
                    activo: ejes == 1 ? true : false,
                    plato1: plato1, 
                    plato2: plato2, 
                    label1: 'DEL IZQ', 
                    label2: 'DEL DER', 
                    buttonKeyPlato1: ejes == 1 ? const ValueKey('1') : const ValueKey('3'), 
                    buttonKeyPlato2: ejes == 1 ? const ValueKey('2') : const ValueKey('4'),
                    estable1: plato1.estable,
                    estable2: plato2.estable,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: SizeScreen.sc().screenWidth * 0.025),
                child:  SumaLados(
                  pesoIzquierdo:(double.parse( ejesController.getTotalPlato1.value ) + double.parse(ejesController.getTotalPlato3.value)).toStringAsFixed(2),
                  pesoDerecho:  (double.parse( ejesController.getTotalPlato2.value ) + double.parse(ejesController.getTotalPlato4.value )).toStringAsFixed(2),
                ),
              ),
              
              //! Fila de plato trasero  
              Container(
                decoration: BoxDecoration(
                  color: ejes == 2 ? const Color.fromARGB(124, 98, 202, 254) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12)
                ),
                margin: const EdgeInsets.symmetric(horizontal: 5),
                padding: const EdgeInsets.symmetric(vertical: 10),
                //color: ejes == 2 ? const Color.fromARGB(124, 98, 202, 254) : Colors.transparent,
                child: GestureDetector(
                  onTap: (){
                    ejesController.setEje(2);
                    ejesController.setSaveEje2(false);
                  },
                  child: FilaPlatosEjes(
                    widget: Column(
                      children: [
                        ejesController.getEje.value == 2 ? Text('EJE SELECCIONADO', style: style): Text('',style: style),
                        EjeWidget(
                          peso1: ejesController.getTotalPlato3.value, 
                          peso2: ejesController.getTotalPlato4.value, 
                          eje: '2'
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: (){
                            ejesController.setSaveEje2(true);
                            ejesController.setTotalPlato3(double.parse(plato1.peso).toStringAsFixed(2));
                            ejesController.setTotalPlato4(double.parse(plato2.peso).toStringAsFixed(2));
                          }, 
                          child: const Text('Guardar Eje TRAS')
                        ),

                      ],
                    ),
                    pesoPlato1: ejesController.getTotalPlato3.value,
                    pesoPlato2: ejesController.getTotalPlato4.value,
                    activo: ejes == 2 ? true : false,
                    plato1: plato1, 
                    plato2: plato2, 
                    label1: 'TRAS IZQ', 
                    label2: 'TRAS DER', 
                    buttonKeyPlato1: ejes == 2 ? const ValueKey('1') : const ValueKey('3'), 
                    buttonKeyPlato2: ejes == 2 ? const ValueKey('2') : const ValueKey('4'),
                    estable1: plato1.estable, 
                    estable2: plato2.estable,
                  ),
                ),
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
              final payload = await CalculosController.cn.calcularPayloadPorEjes(
                pesosPorPlato: [
                  ejesController.getTotalPlato1.value,
                  ejesController.getTotalPlato2.value,
                  ejesController.getTotalPlato3.value,
                  ejesController.getTotalPlato4.value,
                ],
              );
              showDialogGuardarPesada(payload, context);  
            }
          ),
        ),
        
      );
    });
  }

  showDialogGuardarPesada(PesadaEjesPayload payload, BuildContext context){
    showDialog( 
      context: context, 
      builder: (_){
      
        return DialogWidget(
          onConfirm: (identificacion) {
            return HelpersPesadas.guardarPesadaEjesPayload(
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









