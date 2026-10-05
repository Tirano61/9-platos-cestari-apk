
import 'package:nueve_platos_cestari/Pages/Home/widgets/dialog_config.dart';
import 'package:nueve_platos_cestari/Controllers/config_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso_controller.dart';
import 'package:nueve_platos_cestari/Widgets/botton_bar.dart';
import 'package:nueve_platos_cestari/Widgets/icon_button_bar_widget.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/helpers/exportar_xml.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class HomePage extends StatelessWidget {
   const HomePage({super.key});

  ConfigController get _configController => Get.find<ConfigController>();
  PesoController _pesoController(int plato) => Get.find<PesoController>(tag: 'plato$plato');

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
                          Navigator.pushNamed(context, 'inicioEnsayo');
                        },
                        child: const Text('Iniciar ensayo'),
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
      // Item del plato n: lee puerto y conexion dentro del Obx.
      Widget item(int plato) => _itemConfiguracion(
        nombrePlato(plato),
        _configController.puerto(plato).value,
        conectado: _pesoController(plato).pesoModel.conexion,
      );

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
                // Enganche solo, centrado en la fila.
                Row(
                  children: [
                    const Spacer(),
                    item(1),
                    const Spacer(),
                  ],
                ),
                // Juegos J1..J4: izq en el plato par, der en el impar siguiente.
                for (var izq = 2; izq < cantidadPlatos; izq += 2) ...[
                  SizedBox(height: width * 0.02),
                  Row(
                    children: [
                      item(izq),
                      SizedBox(width: compact ? 8 : 16),
                      item(izq + 1),
                    ],
                  ),
                ],
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









