import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/config/theme.dart';

/// Dibujo de la tolva con un campo de capacidad (kg) junto a cada celda.
/// Se dibuja al ancho disponible; la posicion de cada campo sale de
/// [posicionCelda], asi queda en su lugar con cualquier ancho de pantalla.
class TolvaCapacidades extends StatelessWidget {
  const TolvaCapacidades({super.key, required this.capacidades});

  /// Un controller por plato (indice 0 = plato 1).
  final List<TextEditingController> capacidades;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: proporcionTolva,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final ancho = constraints.maxWidth;
          final alto = constraints.maxHeight;
          final anchoCampo = (ancho * 0.19).clamp(60.0, 110.0);

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(imagenTolva, fit: BoxFit.contain),
              ),
              for (var n = 1; n <= cantidadPlatos; n++)
                _campo(n, ancho, alto, anchoCampo),
            ],
          );
        },
      ),
    );
  }

  Widget _campo(int plato, double ancho, double alto, double anchoCampo) {
    final posicion = posicionCelda(plato);
    final x = posicion.x * ancho;
    // Lado der: el campo arranca en x. Enganche y lado izq: termina en x.
    final izquierda = esLadoDerecho(plato) ? x : x - anchoCampo;

    return Positioned(
      left: izquierda.clamp(0.0, ancho - anchoCampo),
      top: posicion.y * alto,
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
