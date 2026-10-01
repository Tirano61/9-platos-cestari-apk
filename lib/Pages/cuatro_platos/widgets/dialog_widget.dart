
import 'package:cuatro_platos/Theme/theme.dart';
import 'package:cuatro_platos/config/SizeScreen.dart';
import 'package:cuatro_platos/config/theme.dart';
import 'package:flutter/material.dart';

class DialogWidget extends StatefulWidget {
  final Future<bool> Function(String identificacion)? onConfirm;
  const DialogWidget({this.onConfirm, super.key});

  @override
  State<DialogWidget> createState() => _DialogWidgetState();
}

class _DialogWidgetState extends State<DialogWidget> {

  final TextEditingController _controller = TextEditingController();
  final anchoBoton = SizeScreen.sc().screenWidth * 0.27;
  
  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

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
                'Ingreso de Datos',
                style: TextStyle(fontSize:  MediaQuery.of(context).size.height > 920 ?  20 : 14),
              ),
            ),
            const Divider(),
            Padding(
              padding: EdgeInsets.symmetric(vertical:  SizeScreen.sc().screenWidth * 0.02),
              child: SizedBox(
                width: SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.5 :0.55 ),
                child: TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15)
                    ),
                    hintText:  'Identificación',
                    labelText: 'Identificación',
                    suffixIcon: Icon(Icons.legend_toggle_sharp,
                        color:  ThemePlatos.backgroundPeso, size: 18),
                    errorStyle: TextStyle(color: ThemePlatos.errorColor),
                  ),
                  controller: _controller,
                ),
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
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        if (widget.onConfirm == null) {
                          navigator.pop(false);
                          return;
                        }

                        final success = await widget.onConfirm!(_controller.text.trim());
                        if (!mounted) return;
                        navigator.pop(success);
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




