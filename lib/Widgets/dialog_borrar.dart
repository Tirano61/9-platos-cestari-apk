


import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:flutter/material.dart';



/// Dialogo para borrar todo lo guardado. OK espera [onBorrar] y cierra con
/// true; Cancel cierra sin borrar.
class DialogBorrar extends StatelessWidget{
  const DialogBorrar({
    required this.titulo,
    required this.mensaje,
    required this.onBorrar,
    super.key});

  final String titulo;
  final String mensaje;
  final Future<void> Function() onBorrar;

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
                titulo,
                style: TextStyle(fontSize:  SizeScreen.sc().isMinWidth ?  20 : 14),
              ),
            ),
            const Divider(),
            Padding(
              padding: EdgeInsets.symmetric(vertical:  SizeScreen.sc().screenWidth * 0.02),
              child: SizedBox(
                width: SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.5 :0.55 ),
                child: Center(child: Text(mensaje, style: ThemeApp.fontStandard,)),
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
                        final navigator = Navigator.of(context);
                        await onBorrar();
                        navigator.pop(true);
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




