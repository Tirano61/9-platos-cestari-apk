
import 'package:nueve_platos_cestari/Pages/Home/widgets/dialog_config.dart';
import 'package:nueve_platos_cestari/Controllers/config_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso1_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso2_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso3_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso4_controller.dart';
import 'package:nueve_platos_cestari/Widgets/botton_bar.dart';
import 'package:nueve_platos_cestari/Widgets/icon_button_bar_widget.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/helpers/exportar_xml.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class HomePage extends StatelessWidget {
   const HomePage({super.key});

  ConfigController get _configController => Get.find<ConfigController>();
  Peso1Controller get _peso1Controller => Get.find<Peso1Controller>();
  Peso2Controller get _peso2Controller => Get.find<Peso2Controller>();
  Peso3Controller get _peso3Controller => Get.find<Peso3Controller>();
  Peso4Controller get _peso4Controller => Get.find<Peso4Controller>();

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final logoWidth = SizeScreen.sc().isMinWidth ? 350.0 : 250.0;
    final verticalSpacing = media.size.height < 700 ? 16.0 : 24.0;

    return Scaffold(
      appBar: AppBar(
        //backgroundColor: ThemePlatos.backgroundTitulos,
        title: const Text( 'Balanzas Hook'),
        actions: [
          IconButton(
            onPressed: (){
              showDialogPlatosConfig( context );
            }, 
            icon: const Icon(Icons.settings)
          )
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: media.size.width * 0.04,
                    vertical: 12,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                        child: Image.asset(
                          'assets/splash.png',
                          width: logoWidth,
                        ),
                      ),
                      SizedBox(height: verticalSpacing),
                      _cardPuertosConfigurados(),
                      SizedBox(height: verticalSpacing),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, 'platos');
                        },
                        child: const Text('Iniciar Pesaje'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(20)),
        child: BottonBarApp(
          children: [
            IconBottonBarWidget(
              icon: Icons.search_rounded, 
              iconColor: ThemeApp.colorTituloPlatos, 
              iconSize: 30,
              onPressed: (){
                // Ver las pesadas guardadas
                Navigator.pushNamed(context, 'pesadas');  
              }
            ),
            IconBottonBarWidget(
              iconColor: ThemeApp.colorTarjetaPesaadas, 
              iconSize: 30,
              onPressed: (){
                // Compartir las pesadas
                final exportar = Exportar();
                //exportarPesadas();
                exportar.compartirArchivo(context);
              }, 
              icon: Icons.share
            ),
          ],
        ),
      ),
    );
  }

  showDialogPlatosConfig(BuildContext context ){
    showDialog( 
      context: context, 
      builder: (_){
        return const DialogConfig();
      }
    );
  }

  Widget _cardPuertosConfigurados() {
    final width = SizeScreen.sc().screenWidth;
    final cardWidth = width * (SizeScreen.sc().isMinWidth ? 0.72 : 0.9);

    return Obx(() {
      final puerto1 = _configController.getPuerto1.value;
      final puerto2 = _configController.getPuerto2.value;
      final puerto3 = _configController.getPuerto3.value;
      final puerto4 = _configController.getPuerto4.value;

      final conectado1 = _peso1Controller.getPesoModel1.conexion;
      final conectado2 = _peso2Controller.getPesoModel2.conexion;
      final conectado3 = _peso3Controller.getPesoModel3.conexion;
      final conectado4 = _peso4Controller.getPesoModel4.conexion;

      return Container(
        width: cardWidth,
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: width * 0.03,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ThemeApp.colorTituloPlatos.withValues(alpha: 0.15)),
          boxShadow: const [
            BoxShadow(
              color: ThemeApp.shadowColor,
              blurRadius: 6,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 280;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Platos y Puertos Configurados',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: SizeScreen.sc().isMinWidth ? 15 : 13,
                    fontWeight: FontWeight.w700,
                    color: ThemeApp.colorTituloPlatos,
                  ),
                ),
                SizedBox(height: width * 0.02),
                Row(
                  children: [
                    _itemConfiguracion(
                      'Del Izq',
                      puerto1,
                      conectado: conectado1,
                    ),
                    SizedBox(width: compact ? 8 : 16),
                    _itemConfiguracion(
                      'Del Der',
                      puerto2,
                      conectado: conectado2,
                    ),
                  ],
                ),
                SizedBox(height: width * 0.02),
                Row(
                  children: [
                    _itemConfiguracion(
                      'Tras Izq',
                      puerto3,
                      conectado: conectado3,
                    ),
                    SizedBox(width: compact ? 8 : 16),
                    _itemConfiguracion(
                      'Tras Der',
                      puerto4,
                      conectado: conectado4,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      );
    });
  }

  Widget _itemConfiguracion(
    String posicion,
    String valor, {
    required bool conectado,
  }) {
    final valorNormalizado = valor.trim();
    final textoValor = valorNormalizado.isEmpty
        ? 'Sin puerto asignado'
        : valorNormalizado;
    final estadoTexto = conectado ? 'Conectado' : 'Desconectado';
    final estadoColor = conectado ? Colors.green : Colors.red;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              posicion,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: SizeScreen.sc().isMinWidth ? 14 : 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Puerto: $textoValor',
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: SizeScreen.sc().isMinWidth ? 13 : 11,
                color: Colors.black87,
              ),
            ),
            // conexion es true mientras llegan datos del plato.
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: estadoColor,
                ),
                const SizedBox(width: 6),
                Text(
                  estadoTexto,
                  style: TextStyle(
                    fontSize: SizeScreen.sc().isMinWidth ? 12 : 10,
                    fontWeight: FontWeight.w600,
                    color: estadoColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}









