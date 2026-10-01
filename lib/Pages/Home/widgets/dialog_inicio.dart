
import 'package:cuatro_platos/Theme/theme.dart';
import 'package:cuatro_platos/config/SizeScreen.dart';
import 'package:cuatro_platos/config/theme.dart';
import 'package:flutter/material.dart';

class DialogInicio extends StatelessWidget {

  final anchoBoton = SizeScreen.sc().screenWidth * 0.27;
  DialogInicio({super.key});

  @override
  Widget build(BuildContext context) {
    final rootNavigator = Navigator.of(context, rootNavigator: true);
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
                'Selección de Pesaje',
                style: TextStyle(fontSize:  MediaQuery.of(context).size.height > 920 ?  20 : 14),
              ),
            ),
            const Divider(),
            Padding(
              padding: EdgeInsets.symmetric(vertical:  SizeScreen.sc().screenWidth * 0.02),
              child: SizedBox(
                width: SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.5 :0.55 ),
                child: const Center(child: Text('Seleccione el tipo de pesaje a realizar !!!'))
              ),
            ),
            // Fila de botones del diálogo
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment : MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: anchoBoton,
                    child: ElevatedButton(
                      onPressed: () async {
                        final nextContext = rootNavigator.context;
                        rootNavigator.pop();
                        if (!nextContext.mounted) return;
                        _showDialogTipoEjes(nextContext);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(ThemeApp.colorPesoPlatos),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                            EdgeInsets.symmetric(horizontal: SizeScreen.sc().screenWidth * 0.02)
                        ),
                      ), 
                      child: const Text('2 PLATOS',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: anchoBoton,
                    child: ElevatedButton(
                      onPressed: ()async{
                        final nextContext = rootNavigator.context;
                        final nextNavigator = Navigator.of(nextContext, rootNavigator: true);
                        rootNavigator.pop();
                        if (!nextContext.mounted) return;
                        nextNavigator.pushNamed('platos');
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.all<Color>(ThemeApp.colorPesoPlatos),
                        padding: WidgetStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: SizeScreen.sc().screenWidth * 0.02)
                        ),
                      ), 
                      child: Text('4 PLATOS',
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

  void _showDialogTipoEjes(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return _DialogTipoEjesDinamico(anchoBoton: anchoBoton);
      },
    );
  }
}

class _DialogTipoEjesDinamico extends StatefulWidget {
  const _DialogTipoEjesDinamico({required this.anchoBoton});

  final double anchoBoton;

  @override
  State<_DialogTipoEjesDinamico> createState() => _DialogTipoEjesDinamicoState();
}

class _DialogTipoEjesDinamicoState extends State<_DialogTipoEjesDinamico> {
  static const int _minEjes = 2;
  static const int _maxEjes = 6;
  int _selectedEjes = _minEjes;

  void _cambiarEjes(int delta) {
    setState(() {
      _selectedEjes = (_selectedEjes + delta).clamp(_minEjes, _maxEjes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.28 : 0.46),
        width: SizeScreen.sc().screenWidth * 0.56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const Text('Seleccione la cantidad de ejes'),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: _selectedEjes > _minEjes ? () => _cambiarEjes(-1) : null,
                  icon: const Icon(Icons.remove_circle_outline),
                  color: ThemeApp.colorPesoPlatos,
                ),
                Container(
                  width: SizeScreen.sc().screenWidth * (SizeScreen.sc().isMinWidth ? 0.11 : 0.16),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: ThemeApp.colorPesoPlatos),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '$_selectedEjes',
                      style: TextStyle(
                        fontSize: SizeScreen.sc().isMinWidth ? 24 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _selectedEjes < _maxEjes ? () => _cambiarEjes(1) : null,
                  icon: const Icon(Icons.add_circle_outline),
                  color: ThemeApp.colorPesoPlatos,
                ),
              ],
            ),
            Text('Ejes: $_minEjes - $_maxEjes', style: const TextStyle(fontSize: 12)),
            SizedBox(
              width: widget.anchoBoton,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context, rootNavigator: true).pushNamed('ejes$_selectedEjes');
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(ThemeApp.colorPesoPlatos),
                  padding: WidgetStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: SizeScreen.sc().screenWidth * 0.02)
                  ),
                ),
                // Fuente proporcional al ancho; FittedBox evita el salto de línea con escala de texto del sistema
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'CONTINUAR',
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: (SizeScreen.sc().screenWidth * 0.032 as double).clamp(10.0, 16.0),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




