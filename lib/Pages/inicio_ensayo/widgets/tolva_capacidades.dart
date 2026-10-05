import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/config/theme.dart';

/// Dibujo de la tolva con un campo de capacidad (kg) junto a cada celda.
/// El dibujo va centrado y mas angosto que el ancho disponible, para que los
/// campos tengan lugar a los costados. La posicion de cada campo sale de
/// [posicionCelda], asi queda en su lugar con cualquier tamaño de pantalla.
class TolvaCapacidades extends StatelessWidget {
  const TolvaCapacidades({super.key, required this.capacidades});

  /// Un controller por plato (indice 0 = plato 1).
  final List<TextEditingController> capacidades;

  /// Tamaño maximo del dibujo: fraccion del ancho disponible y del alto de la pantalla.
  static const fraccionAncho = 0.55;
  static const fraccionAlto = 0.65;

  @override
  Widget build(BuildContext context) {
    final altoPantalla = MediaQuery.sizeOf(context).height;

    return LayoutBuilder(
      builder: (context, constraints) {
        final ancho = constraints.maxWidth;
        final anchoDibujo = min(
          ancho * fraccionAncho,
          altoPantalla * fraccionAlto * proporcionTolva,
        );
        final altoDibujo = anchoDibujo / proporcionTolva;
        final margen = (ancho - anchoDibujo) / 2;
        final anchoCampo = (ancho * 0.19).clamp(60.0, 110.0);

        return SizedBox(
          width: ancho,
          height: altoDibujo,
          child: Stack(
            children: [
              Positioned(
                left: margen,
                top: 0,
                width: anchoDibujo,
                height: altoDibujo,
                child: Image.asset(imagenTolva, fit: BoxFit.contain),
              ),
              for (var n = 1; n <= cantidadPlatos; n++)
                _campo(n, ancho, margen, anchoDibujo, altoDibujo, anchoCampo),
            ],
          ),
        );
      },
    );
  }

  Widget _campo(
    int plato,
    double ancho,
    double margen,
    double anchoDibujo,
    double altoDibujo,
    double anchoCampo,
  ) {
    final posicion = posicionCelda(plato);
    final x = margen + posicion.x * anchoDibujo;
    // Lado der: el campo arranca en x. Enganche y lado izq: termina en x.
    final izquierda = esLadoDerecho(plato) ? x : x - anchoCampo;

    return Positioned(
      left: izquierda.clamp(0.0, ancho - anchoCampo),
      top: posicion.y * altoDibujo,
      width: anchoCampo,
      // Centrado en la linea de la celda.
      child: FractionalTranslation(
        translation: const Offset(0, -0.5),
        child: _CampoCapacidad(
          label: nombrePlato(plato),
          controller: capacidades[plato - 1],
        ),
      ),
    );
  }
}

/// Etiqueta con el nombre del plato y campo numerico chico (kg).
class _CampoCapacidad extends StatelessWidget {
  const _CampoCapacidad({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final tablet = SizeScreen.sc().isMinWidth;

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ThemeApp.colorTituloPlatos.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: tablet ? 13 : 11,
              fontWeight: FontWeight.w700,
              color: ThemeApp.colorTituloPlatos,
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            maxLength: 7,
            textAlign: TextAlign.center,
            textInputAction: TextInputAction.next,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
            style: TextStyle(fontSize: tablet ? 15 : 13),
            decoration: InputDecoration(
              isDense: true,
              counterText: '',
              hintText: 'kg',
              contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
