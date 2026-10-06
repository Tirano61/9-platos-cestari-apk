
import 'package:nueve_platos_cestari/BaseDeDatos/helpers/settings/first_data.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/helpers/settings/helpers_config.dart';
import 'package:nueve_platos_cestari/Controllers/config_controller.dart';
import 'package:nueve_platos_cestari/Pages/Home/widgets/input_text_config.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/models/config_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogConfig extends StatefulWidget {

  const DialogConfig({super.key});

  @override
  State<DialogConfig> createState() => _DialogConfigState();
}

class _DialogConfigState extends State<DialogConfig> {

  // Un campo por plato: el indice 0 es el plato 1.
  final List<TextEditingController> _platoControllers = [
    for (var n = 1; n <= cantidadPlatos; n++) TextEditingController(),
  ];

  final anchoBoton = SizeScreen.sc().screenWidth * 0.27;
  final puertoGetxController = Get.find<ConfigController>();

  @override
  void initState() {
    super.initState();
    for (var n = 1; n <= cantidadPlatos; n++) {
      _platoControllers[n - 1].text = puertoGetxController.puerto(n).value;
    }
  }

  @override
  void dispose() {
    super.dispose();
    for (final controller in _platoControllers) {
      controller.dispose();
    }
  }

  String _sanitizePort(String value, String fallback) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final screenHeight = media.size.height;
    final screenWidth = media.size.width;
    final dialogHeight = screenHeight * (screenHeight < 700 ? 0.9 : 0.8);
    final dialogWidth = screenWidth * (SizeScreen.sc().isMinWidth ? 0.6 : 0.9);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: SizedBox(
        height: dialogHeight,
        width: dialogWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
              child: Text(
                'Configuración de Conexión',
                style: TextStyle(fontSize:  MediaQuery.of(context).size.height > 920 ?  20 : 14),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeScreen.sc().screenWidth * 0.08,
              ),
              child: Text(
                'Importante: el puerto configurado para cada plato debe coincidir con el puerto configurado en la antena de ese plato.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SizeScreen.sc().isMinWidth ? 13 : 11,
                ),
              ),
            ),
            const Divider(),
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: SizeScreen.sc().screenWidth * 0.1, vertical: SizeScreen.sc().screenWidth * 0.01),
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    for (var n = 1; n <= cantidadPlatos; n++) ...[
                      if (n > 1) const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InputTextConfig(
                              label: 'Puerto Plato $n-${nombrePlato(n)}',
                              controller: _platoControllers[n - 1],
                            ),
                          ),
                          // El dialogo queda abierto debajo: al volver, los
                          // puertos sin guardar siguen como estaban.
                          IconButton(
                            key: ValueKey('calibrar_$n'),
                            icon: const Icon(Icons.tune),
                            color: ThemeApp.colorPesoPlatos,
                            tooltip: 'Calibrar ${nombrePlato(n)}',
                            onPressed: () => Navigator.pushNamed(
                              context,
                              'calibracion',
                              arguments: n,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Fila de botones del diálogo
            SizedBox(
              height: 60,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(
                    width: anchoBoton,
                    child: ElevatedButton(
                      onPressed: (){

                        final configModel = ConfigModel(
                          puertos: [
                            for (var n = 1; n <= cantidadPlatos; n++)
                              _sanitizePort(_platoControllers[n - 1].text, puertoPorDefecto(n)),
                          ],
                        );

                        HelpersConfig.upDateConfig( configModel, context );

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
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

}
