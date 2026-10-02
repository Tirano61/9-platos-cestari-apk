
import 'package:nueve_platos_cestari/models/pesaje_model.dart';
import 'package:nueve_platos_cestari/Pages/pesadas/widgets/plato_pesada.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:flutter/material.dart';

class ItemsPesadas extends StatelessWidget {
  final Pesaje pesaje ;
  const ItemsPesadas({
    super.key,
    required this.pesaje,
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
                        Text(pesaje.id.toString(), style: ThemeApp.fontStandard),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: EdgeInsets.only(left: SizeScreen.sc().isMinWidth ? 8.0 : 3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha : ${pesaje.fecha}', style: ThemeApp.fontStandard),
                        Text('Hora   : ${pesaje.hora}' , style: ThemeApp.fontStandard),
                         
                        SizedBox(height: SizeScreen.sc().screenWidth * 0.003),
                        Row(
                          children: [
                            Text('Ident. : ', style: ThemeApp.fontStandard),
                            _valorAjustado(pesaje.identificacion),
                          ],
                        ),
                        SizedBox(height: SizeScreen.sc().screenWidth * 0.003),
                        Row(
                          children: [
                            Text('Total. : ', style: ThemeApp.fontStandard),
                            _valorAjustado(pesaje.total),
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
          /// Columna del tractor
          /// 
          Expanded(
            flex: 2,
            child: _buildCuatroPlatos(),
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

  Widget _buildCuatroPlatos() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PlatoPesadas(
                title: 'Del. Izq.',
                peso: pesaje.delIzq,
                porcentaje: pesaje.porDelIzq,
              ),
              PlatoPesadas(
                title: 'Eje  Del.',
                peso: pesaje.ejeDel,
                porcentaje: pesaje.porEjeDel,
              ),
              PlatoPesadas(
                title: 'Del. Der.',
                peso: pesaje.delDer,
                porcentaje: pesaje.porDelDer,
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              PlatoPesadas(
                title: 'Lado Izq.',
                peso: pesaje.ladoIzq,
                porcentaje: pesaje.porLadoIzq,
              ),
              PlatoPesadas(
                title: 'Lado Der.',
                peso: pesaje.ladoDer,
                porcentaje: pesaje.porLadoDer,
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              PlatoPesadas(
                title: 'Tra. Izq.',
                peso: pesaje.trasIzq,
                porcentaje: pesaje.porTrasIzq,
              ),
              PlatoPesadas(
                title: 'Eje Tras.',
                peso: pesaje.ejeTras,
                porcentaje: pesaje.porEjeTras,
              ),
              PlatoPesadas(
                title: 'Tra. Der.',
                peso: pesaje.trasDer,
                porcentaje: pesaje.porTrasDer,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
