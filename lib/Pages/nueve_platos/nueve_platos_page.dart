
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/theme.dart';

import 'package:nueve_platos_cestari/Pages/nueve_platos/widgets/export_home_wigets.dart';
import 'package:nueve_platos_cestari/Controllers/controllers_export.dart';
import 'package:nueve_platos_cestari/Controllers/ensayo_controller.dart';




class NuevePlatosPage extends StatelessWidget {
  NuevePlatosPage({super.key});

  final pesoControllers = [
    for (var n = 1; n <= cantidadPlatos; n++) Get.find<PesoController>(tag: 'plato$n'),
  ];
  final ensayo = Get.find<EnsayoController>();

  @override
  Widget build(BuildContext context) {

    return Obx((){
      final pesos = [for (final c in pesoControllers) c.pesoModel.peso];
      CalculosController.cn.setPesoTotalByList(pesos);
      final separacion = SizeScreen.sc().screenWidth * 0.008;
      // Salir siempre pide confirmacion, con un mensaje segun el estado del
      // ensayo; con una maniobra en curso, la descarta.
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _confirmarSalida(context);
        },
        child: Theme(
          data: _temaPesaje(Theme.of(context)),
          child: Scaffold(
            appBar: AppBar(
              // Nombre de la tolva del ensayo en curso.
              title: Text(
                ensayo.tolva.value.isEmpty ? 'Balanzas Hook' : ensayo.tolva.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            body: Column(
              children: [
                // Barra de acciones fija bajo el AppBar
                const BarraEnsayo(),
                Expanded(
                  child: _contenidoPlatos(separacion),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  /// Tema verde claro de la pantalla de pesaje (fondo, AppBar y botones).
  ThemeData _temaPesaje(ThemeData base) => base.copyWith(
        colorScheme: ColorScheme.fromSeed(seedColor: ThemeApp.pesajeTitulos),
        scaffoldBackgroundColor: ThemeApp.pesajeFondo,
        appBarTheme: base.appBarTheme.copyWith(
          backgroundColor: ThemeApp.pesajeTitulos,
          foregroundColor: Colors.white,
          titleTextStyle: base.appBarTheme.titleTextStyle?.copyWith(color: Colors.white),
        ),
        iconTheme: base.iconTheme.copyWith(color: ThemeApp.pesajeTitulos),
      );

  Future<void> _confirmarSalida(BuildContext context) async {
    final salir = await confirmarSalida(context, ensayo);
    if (!salir || !context.mounted) return;
    ensayo.descartarManiobra();
    Navigator.pop(context);
  }

  /// Total, enganche y los 4 juegos, con scroll.
  Widget _contenidoPlatos(double separacion) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          // Recuadro de Peso total sumado
          Padding(
            padding: EdgeInsets.only(top: SizeScreen.sc().screenWidth * 0.015, bottom: SizeScreen.sc().screenWidth * 0.015),
            child: RecuadroPesoTotal(
              suma: CalculosController.cn.pesoTotal
            ),
          ),
          // Enganche, centrado
          _platoWidget(1),
          // Juegos de celdas: J1 = platos 2/3 ... J4 = platos 8/9
          for (var juego = 1; juego <= 4; juego++)
            Padding(
              padding: EdgeInsets.only(top: separacion),
              child: FilaPlatos(
                izq: _platoWidget(juego * 2),
                der: _platoWidget(juego * 2 + 1),
                eje: '$juego',
                label: 'JUEGO $juego',
              ),
            ),
        ],
      ),
    );
  }

  /// PlatoWidget del plato [n] (1..9). La key del boton es el numero
  /// de plato al que se manda el cero.
  PlatoWidget _platoWidget(int n) {
    final controller = pesoControllers[n - 1];
    final plato = controller.pesoModel;
    final registrando = ensayo.registrando;
    // Max / min en vivo durante la maniobra y los de la ultima al terminar;
    // vacios si el ensayo todavia no tuvo ninguna.
    final hayManiobra = ensayo.numeroManiobra.value > 0;
    final maximo = hayManiobra ? controller.maximo.value : '';
    return PlatoWidget(
      numPlato: nombrePlato(n),
      pesoPlato: plato.peso,
      buttonKeyPlato: ValueKey('$n'),
      conexionPlato: plato.conexion,
      batery: plato.tension,
      estable: plato.estable,
      estatico: ensayo.estatico(n),
      maximo: maximo,
      minimo: hayManiobra ? controller.minimo.value : '',
      // Durante la maniobra no se puede mandar cero.
      ceroHabilitado: !registrando,
      // alarma solo usa el maximo mientras se registra.
      nivelAlarma: ensayo.alarma(n, peso: plato.peso, maximo: maximo),
    );
  }
}
