import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:nueve_platos_cestari/Controllers/ensayo_controller.dart';
import 'package:nueve_platos_cestari/Widgets/tabla_maniobra.dart';

/// Duracion como m:ss (h:mm:ss si pasa la hora).
String formatoDuracion(Duration duracion) {
  final h = duracion.inHours;
  final m = duracion.inMinutes.remainder(60);
  final s = duracion.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}

/// Muestra la tabla de resultados de una maniobra recien terminada.
Future<void> mostrarResultadoManiobra(
  BuildContext context, {
  required ResultadoManiobra resultado,
  required String umbral,
}) {
  final hora = DateFormat('HH:mm:ss');
  final duracion = resultado.fin.difference(resultado.inicio);

  return showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Maniobra ${resultado.numero}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${hora.format(resultado.inicio)} a ${hora.format(resultado.fin)} '
              '(${formatoDuracion(duracion)}) · umbral $umbral %',
            ),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: TablaManiobra(platos: resultado.platos, umbral: umbral),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
