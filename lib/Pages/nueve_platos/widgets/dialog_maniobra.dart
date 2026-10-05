import 'package:flutter/material.dart';

import 'package:nueve_platos_cestari/Widgets/tabla_maniobra.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_model.dart';

/// Duracion como m:ss (h:mm:ss si pasa la hora).
String formatoDuracion(Duration duracion) {
  final h = duracion.inHours;
  final m = duracion.inMinutes.remainder(60);
  final s = duracion.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}

/// Horario, duracion y umbral de la maniobra, para el dialogo y el historial.
String descripcionManiobra(ManiobraModel maniobra) =>
    '${maniobra.horaInicio} a ${maniobra.horaFin} '
    '(${formatoDuracion(maniobra.duracion)}) · umbral ${maniobra.umbral} %';

/// Muestra la tabla de resultados de una maniobra recien terminada, con el
/// umbral copiado en la maniobra.
Future<void> mostrarResultadoManiobra(
  BuildContext context, {
  required ManiobraModel maniobra,
}) {
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
            Text('Maniobra ${maniobra.numero}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(descripcionManiobra(maniobra)),
            const SizedBox(height: 12),
            Flexible(
              child: SingleChildScrollView(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: TablaManiobra(platos: maniobra.platos, umbral: maniobra.umbral),
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
