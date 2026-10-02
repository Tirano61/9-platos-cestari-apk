
import 'package:nueve_platos_cestari/models/pesadas/pesada_payload_model.dart';
import 'package:nueve_platos_cestari/Pages/pesadas/widgets/plato_pesada.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:flutter/material.dart';

class ItemsPesadas extends StatelessWidget {
  final Pesada9PlatosPayload pesada;
  const ItemsPesadas({
    super.key,
    required this.pesada,
  });
  
  @override
  Widget build(BuildContext context) {
    // La tarjeta toma el alto de su contenido: la columna de datos tiene un alto
    // fijo en pixeles y con alturas proporcionales al ancho de pantalla se cortaba
    // el Total.
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: SizeScreen.sc().isMinWidth ? 8.0 : 3),
                    child: Row(
                      children: [
                        Text('Nº : ', style: ThemeApp.fontStandard),
                        Text(pesada.base.id.toString(), style: ThemeApp.fontStandard),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: EdgeInsets.only(left: SizeScreen.sc().isMinWidth ? 8.0 : 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha : ${pesada.base.fecha}', style: ThemeApp.fontStandard),
                        Text('Hora   : ${pesada.base.hora}' , style: ThemeApp.fontStandard),
                         
                        SizedBox(height: SizeScreen.sc().screenWidth * 0.003),
                        Row(
                          children: [
                            Text('Ident. : ', style: ThemeApp.fontStandard),
                            _valorAjustado(pesada.base.identificacion),
                          ],
                        ),
                        SizedBox(height: SizeScreen.sc().screenWidth * 0.003),
                        Row(
                          children: [
                            Text('Total. : ', style: ThemeApp.fontStandard),
                            _valorAjustado(pesada.base.total),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const VerticalDivider(width: 1,),
          ///
          /// Columna de la tolva: enganche, juegos y lados
          /// 
          Expanded(
            flex: 2,
            child: _buildNuevePlatos(),
          )
        ],
      ),
    );
  }

  /// Valor en negrita de la columna de datos. Si no entra en el ancho (pantalla
  /// angosta o letra grande del sistema) se achica en lugar de desbordar, asi el
  /// total se sigue leyendo completo.
  Widget _valorAjustado(String valor) {
    return Flexible(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        // maxLines: 1 para que IntrinsicHeight no calcule el alto como si el
        // texto se partiera en varias lineas (FittedBox lo dibuja en una).
        child: Text(valor, maxLines: 1, style: ThemeApp.fontIdentificacionPesadas),
      ),
    );
  }

  Widget _buildNuevePlatos() {
    final d = pesada.detalle;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _fila([
            PlatoPesadas(title: 'Enganche', peso: d.enganche, porcentaje: d.porEnganche),
          ]),
          _filaJuego('J1', 'Juego 1', d.j1Izq, d.porJ1Izq, d.juego1, d.porJuego1, d.j1Der, d.porJ1Der),
          _filaJuego('J2', 'Juego 2', d.j2Izq, d.porJ2Izq, d.juego2, d.porJuego2, d.j2Der, d.porJ2Der),
          _filaJuego('J3', 'Juego 3', d.j3Izq, d.porJ3Izq, d.juego3, d.porJuego3, d.j3Der, d.porJ3Der),
          _filaJuego('J4', 'Juego 4', d.j4Izq, d.porJ4Izq, d.juego4, d.porJuego4, d.j4Der, d.porJ4Der),
          _fila([
            PlatoPesadas(title: 'Lado Izq.', peso: d.ladoIzq, porcentaje: d.porLadoIzq),
            PlatoPesadas(title: 'Lado Der.', peso: d.ladoDer, porcentaje: d.porLadoDer),
          ], mainAxisAlignment: MainAxisAlignment.spaceAround),
        ],
      ),
    );
  }

  /// Fila de un juego: plato izq | subtotal del juego | plato der.
  Widget _filaJuego(String juego, String label,
      String izq, String porIzq, String total, String porTotal, String der, String porDer) {
    return _fila([
      PlatoPesadas(title: '$juego Izq.', peso: izq, porcentaje: porIzq),
      PlatoPesadas(title: label, peso: total, porcentaje: porTotal),
      PlatoPesadas(title: '$juego Der.', peso: der, porcentaje: porDer),
    ]);
  }

  Widget _fila(List<Widget> children,
      {MainAxisAlignment mainAxisAlignment = MainAxisAlignment.spaceEvenly}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        children: children,
      ),
    );
  }
}
