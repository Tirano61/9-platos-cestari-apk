


import 'package:cuatro_platos/BaseDeDatos/helpers/pesadas/helpers_pesadas.dart';
import 'package:cuatro_platos/Theme/theme.dart';
import 'package:cuatro_platos/config/SizeScreen.dart';
import 'package:cuatro_platos/config/theme.dart';
import 'package:flutter/material.dart';



class DialogBorrar extends StatelessWidget{
  const DialogBorrar({super.key});

  static final anchoBoton = SizeScreen.sc().screenWidth * 0.27;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.32 : 0.52),
        width: SizeScreen.sc().screenWidth * 0.6,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
              child: Text(
                'Borrar Pesadas',
                style: TextStyle(fontSize:  SizeScreen.sc().isMinWidth ?  20 : 14),
              ),
            ),
            const Divider(),
            Padding(
              padding: EdgeInsets.symmetric(vertical:  SizeScreen.sc().screenWidth * 0.02),
              child: SizedBox(
                width: SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.5 :0.55 ),
                child: Center(child: Text('Desea eliminar todas las pesadas guardadas?',style: ThemeApp.fontStandard,)),
              ),
            ),
            // Fila de botones del diálogo
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: anchoBoton,
                    child: ElevatedButton(
                      onPressed: ()async{
                        ///
                        /// Eliminar todas las pesadas
                        ///
                        final navigator = Navigator.of(context);
                        await HelpersPesadas.borrarTodasPesadas();
                        navigator.pop();
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(ThemeApp.colorPesoPlatos),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: SizeScreen.sc().screenWidth * 0.02)
                        ),
                      ), 
                      child: const Text('OK',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: anchoBoton,
                    child: ElevatedButton(
                      onPressed: ()async{
                        // Salir
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(ThemeApp.colorPesoPlatos),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: SizeScreen.sc().screenWidth * 0.02)
                        ),
                      ), 
                      child: Text('Cancel',
                        style: ThemePlatos.cn.textoTitulosPlatos,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

}




