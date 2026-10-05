import 'package:flutter/material.dart';

import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';

/// Resultado de una maniobra: una fila por plato con estatico, maximo, minimo,
/// factor de cresta, % de la capacidad y estado (con color).
///
/// Las columnas toman el ancho de su contenido: en pantallas angostas va dentro
/// de un scroll horizontal.
class TablaManiobra extends StatelessWidget {
  const TablaManiobra({super.key, required this.platos, required this.umbral});

  final List<ManiobraPlato> platos;

  /// Umbral de alarma (%) con el que se calcula el estado.
  final String umbral;

  static const _encabezados = ['Plato', 'Estático', 'Máx', 'Mín', 'FC', '% cap', 'Estado'];

  static Color? colorEstado(EstadoCelda estado) => switch (estado) {
        EstadoCelda.excede => ThemePlatos.errorColor,
        EstadoCelda.alLimite => Colors.amber,
        EstadoCelda.normal => ThemePlatos.positiveColor,
        EstadoCelda.sinDato => null,
      };

  @override
  Widget build(BuildContext context) {
    const estiloTitulo = TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold);
    const estiloCelda = TextStyle(fontSize: 12);

    Widget celda(String texto, {TextStyle estilo = estiloCelda, bool izquierda = false}) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          child: Text(texto, style: estilo, textAlign: izquierda ? TextAlign.left : TextAlign.right),
        );

    return Table(
      defaultColumnWidth: const IntrinsicColumnWidth(),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder.all(color: ThemeApp.shadowColor, width: 0.5),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: ThemeApp.colorTituloPlatos),
          children: [
            for (final (i, titulo) in _encabezados.indexed)
              celda(titulo, estilo: estiloTitulo, izquierda: i == 0),
          ],
        ),
        for (final plato in platos)
          TableRow(
            children: [
              celda(nombrePlato(plato.plato), izquierda: true),
              celda(_guion(plato.estatico)),
              celda(_guion(plato.maximo)),
              celda(_guion(plato.minimo)),
              celda(plato.factorCresta),
              celda(plato.porCapacidad),
              _celdaEstado(plato.estado(umbral)),
            ],
          ),
      ],
    );
  }

  Widget _celdaEstado(EstadoCelda estado) {
    final color = colorEstado(estado);
    // fill: el color ocupa toda la altura de la fila.
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.fill,
      child: Container(
        color: color,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: Text(
          estado.texto,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: estado == EstadoCelda.alLimite || color == null ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  static String _guion(String valor) => valor.isEmpty ? '-' : valor;
}
