import 'package:flutter/material.dart';

import 'package:nueve_platos_cestari/Pages/nueve_platos/widgets/dialog_maniobra.dart';
import 'package:nueve_platos_cestari/Widgets/tabla_maniobra.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_model.dart';

/// Ensayo del historial: tolva, fecha y cantidad de maniobras. Al expandirse
/// muestra una TablaManiobra por maniobra, con su numero, horario y duracion.
class TarjetaEnsayo extends StatelessWidget {
  const TarjetaEnsayo({super.key, required this.ensayo});

  final EnsayoModel ensayo;

  @override
  Widget build(BuildContext context) {
    final cantidad = ensayo.maniobras.length;
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black26,
            blurRadius: 5,
            offset: Offset.fromDirection(2.0, 4.0)
          ),
        ],
        color: ThemeApp.colorTarjetaPesaadas,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        // Sin las lineas que ExpansionTile dibuja al expandirse.
        shape: const Border(),
        collapsedShape: const Border(),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        title: Text(
          ensayo.tolva,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: ThemeApp.fontIdentificacionPesadas,
        ),
        subtitle: Text('${ensayo.fecha} · $cantidad ${cantidad == 1 ? 'maniobra' : 'maniobras'}'),
        children: [
          if (ensayo.maniobras.isEmpty) const Text('Sin maniobras guardadas'),
          for (final maniobra in ensayo.maniobras) _maniobra(context, maniobra),
        ],
      ),
    );
  }

  Widget _maniobra(BuildContext context, ManiobraModel maniobra) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Maniobra ${maniobra.numero}', style: Theme.of(context).textTheme.titleMedium),
          Text(descripcionManiobra(maniobra), style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ColoredBox(
              color: Colors.white,
              child: TablaManiobra(platos: maniobra.platos, umbral: maniobra.umbral),
            ),
          ),
        ],
      ),
    );
  }
}
