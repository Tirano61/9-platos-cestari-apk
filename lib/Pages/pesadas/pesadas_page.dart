

import 'package:nueve_platos_cestari/BaseDeDatos/connections/db_conexion.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/services/pesadas/service_pesadas.dart';
import 'package:nueve_platos_cestari/models/pesaje_model.dart';
import 'package:nueve_platos_cestari/Pages/pesadas/widgets/dialog_borrar.dart';
import 'package:nueve_platos_cestari/Pages/pesadas/widgets/items_pesadas.dart';
import 'package:nueve_platos_cestari/Providers/pesadas/connections/pesadas_provider.dart';
import 'package:nueve_platos_cestari/Providers/pesadas/services/service_provider.dart';
import 'package:nueve_platos_cestari/Widgets/botton_bar.dart';
import 'package:nueve_platos_cestari/Widgets/icon_button_bar_widget.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/helpers/exportar_xml.dart';
import 'package:flutter/material.dart';

class PesadasPage extends StatelessWidget {
  PesadasPage({super.key});
    
  final  provider = PesadasProvider(DBconeccion.db);
  final servicioDB = ServicePesadas(DBconeccion.db);
  final GlobalKey<ScaffoldState> scafoldState = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final pesadasProvider = ServiceProvider(provider); 
    pesadasProvider.getPesadas();
    return Scaffold(
      key: scafoldState,
      appBar: AppBar(
        title: const Text('Pesadas'),
        centerTitle: true,
        backgroundColor: ThemeApp.colorTituloPlatos,
      ),
      body: PopScope(
        onPopInvokedWithResult: (didPop, _) {
          if(didPop){
            pesadasProvider.dispose();
          }
        },
        child: StreamBuilder<List<Pesaje>>(
          stream: pesadasProvider.pesadasStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final pesadas = snapshot.data;
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: SizeScreen.sc().isMinWidth ? 27 : 10),
              child: ListView.builder(
                itemCount: pesadas!.length,
                itemBuilder: (context, index){
                  final pesada = pesadas[index];
                  final tipo = pesada.tipoPesada.trim();
                  final isPorEjes = tipo.isNotEmpty
                    ? tipo == '2_platos_ejes'
                    : pesada.detalleEjes.isNotEmpty || pesada.ejeTer.isNotEmpty;
                  final cantidadEjes = pesada.cantidadEjes > 0
                    ? pesada.cantidadEjes
                    : (pesada.detalleEjes.isNotEmpty
                        ? pesada.detalleEjes.length
                        : (pesada.ejeTer.isNotEmpty ? 3 : 2));
                  final altoCard = _altoTarjetaPesada(
                    isPorEjes: isPorEjes,
                    cantidadEjes: cantidadEjes,
                  );

                  return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Dismissible(
                      key: UniqueKey(),
                        resizeDuration: const Duration(seconds: 1),
                        movementDuration: const Duration(seconds: 2),
                        background: Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white,size: 30,),
                        ),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (direction) {
                          ///
                          /// snackbar para eliminacion
                          /// 
                          dimissiblePesada(direction, context, pesadasProvider, pesadas[index].id.toString());
                        },
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset.fromDirection(2.0, 4.0)
                            ),
                          ],
                          color: ThemeApp.colorTarjetaPesaadas,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: SizeScreen.sc().isMinWidth ? 27 : 5 ),
                        
                        width: double.infinity,
                        // Alto minimo: si el contenido necesita mas (pantallas angostas,
                        // letra grande del sistema) ItemsPesadas hace crecer la tarjeta.
                        constraints: BoxConstraints(minHeight: altoCard),
                        child: ItemsPesadas(pesaje: pesada),
                      ),
                    ),
                  );
                } 
              ),
            );
          }
        ),
      ),
  
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        child: BottonBarApp(
          children: [
            IconBottonBarWidget(
              icon: Icons.add_chart_sharp, 
              iconColor: ThemeApp.colorTarjetaPesaadas, 
              iconSize: 30,
              onPressed:()async {
                final scafold = ScaffoldMessenger.of(context);
                final exportar = Exportar();
                final resp = await exportar.writeFile(context);
                if(resp == 1){
                   scafold.showSnackBar( SnackBar(content: const Text('Archivo exportado !!!'),backgroundColor: ThemeApp.positiveColor,));
                }else{
                  scafold.showSnackBar( SnackBar(content: const Text('No se pudo guardar'), backgroundColor: ThemeApp.errorColor,));
                }
              },
            ),
            IconBottonBarWidget(
              icon: Icons.delete_forever_outlined, 
              iconSize: 30,
              onPressed: ()async {
                /// 
                /// llamar al dialogo BorrarPesadas
                /// 
                await showDialog( 
                  context: context, 
                  builder: (_){                  
                    return const DialogBorrar();
                  }
                ).then((value) {
                  pesadasProvider.getPesadas();
                });
              },
            ),
          ],
        ),
      )
    );
  }

  double _altoTarjetaPesada({
    required bool isPorEjes,
    required int cantidadEjes,
  }) {
    final ancho = SizeScreen.sc().screenWidth;
    final isTablet = SizeScreen.sc().isMinWidth;

    if (!isPorEjes) {
      return ancho * (isTablet ? 0.24 : 0.35);
    }

    final ejesExtra = (cantidadEjes - 2).clamp(0, 8);
    final factor = isTablet
        ? (0.21 + (ejesExtra * 0.028)).clamp(0.21, 0.34)
        : (0.30 + (ejesExtra * 0.045)).clamp(0.30, 0.52);

    return ancho * factor;
  }

  dimissiblePesada(DismissDirection direction, BuildContext context, ServiceProvider pesadasProvider, String id){
    if(direction == DismissDirection.startToEnd){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Se eliminara la pesada'),
                Row(
                  mainAxisAlignment:  MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: ()async{
                        ScaffoldMessenger.of(context).removeCurrentSnackBar();
                      }, 
                      child: const Text('OK'),
                    ),
                    ElevatedButton(
                      onPressed: ()async{
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      }, 
                      child: const Text('cancel')
                    ),
                  ],
                )
              ],
            ),
          ), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          backgroundColor: ThemeApp.colorPesoPlatos,
          duration: const Duration(seconds: 5),
        )
      ).closed.then((SnackBarClosedReason reason)async{ 
        switch (reason.name) {
          case 'timeout':
            await servicioDB.deletePesada(id);
            pesadasProvider.getPesadas();
            break;
          case 'remove':
            await servicioDB.deletePesada(id);
            pesadasProvider.getPesadas();
            break;
          case 'hide':
            pesadasProvider.getPesadas();
            break;
        }
      });
    }
  }
}

