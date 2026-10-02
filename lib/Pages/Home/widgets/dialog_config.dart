
import 'package:nueve_platos_cestari/BaseDeDatos/helpers/settings/helpers_config.dart';
import 'package:nueve_platos_cestari/Controllers/config_controller.dart';
import 'package:nueve_platos_cestari/Pages/Home/widgets/input_text_config.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
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

  final TextEditingController _plato1controller = TextEditingController();
  final TextEditingController _plato2controller = TextEditingController();
  final TextEditingController _plato3controller = TextEditingController();
  final TextEditingController _plato4controller = TextEditingController();

  final anchoBoton = SizeScreen.sc().screenWidth * 0.27;
  final puertoGetxController = Get.find<ConfigController>();

  @override
  void initState() {
    super.initState();
    _plato1controller.text = puertoGetxController.getPuerto1.value;
    _plato2controller.text = puertoGetxController.getPuerto2.value;
    _plato3controller.text = puertoGetxController.getPuerto3.value;
    _plato4controller.text = puertoGetxController.getPuerto4.value;
  }

  @override
  void dispose() {
    super.dispose();
    _plato1controller.dispose();
    _plato2controller.dispose();
    _plato3controller.dispose();
    _plato4controller.dispose();
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
                    InputTextConfig(label: 'Puerto Plato 1-DEL IZQ', controller: _plato1controller),
                    const SizedBox(height: 12),
                    InputTextConfig(label: 'Puerto Plato 2-DEL DER', controller: _plato2controller),
                    const SizedBox(height: 12),
                    InputTextConfig(label: 'Puerto Plato 3-TRAS IZQ', controller: _plato3controller),
                    const SizedBox(height: 12),
                    InputTextConfig(label: 'Puerto Plato 4-TRAS DER', controller: _plato4controller),
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
                          plato1: _sanitizePort(_plato1controller.text, '8001'),
                          plato2: _sanitizePort(_plato2controller.text, '8002'),
                          plato3: _sanitizePort(_plato3controller.text, '8003'),
                          plato4: _sanitizePort(_plato4controller.text, '8004'),
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
