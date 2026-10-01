
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
    final tipo = pesaje.tipoPesada.trim();
    final isPorEjes = tipo.isNotEmpty
      ? tipo == '2_platos_ejes'
      : pesaje.detalleEjes.isNotEmpty || pesaje.ejeTer.isNotEmpty;
    final cantidadEjes = pesaje.cantidadEjes > 0
      ? pesaje.cantidadEjes
      : (pesaje.detalleEjes.isNotEmpty
        ? pesaje.detalleEjes.length
        : (pesaje.ejeTer.isNotEmpty ? 3 : 2));
    final tipoPesada = isPorEjes ? '$cantidadEjes ejes' : '4 platos';

    // La tarjeta toma el alto de su contenido: la columna de datos tiene un alto
    // fijo en pixeles y con alturas proporcionales al ancho de pantalla se cortaba
    // el Total (sobre todo en pesadas de 2 ejes, que tienen la tarjeta mas baja).
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
                            Text('Tipo  : ', style: ThemeApp.fontStandard),
                            _valorAjustado(tipoPesada),
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
            child: isPorEjes ? _buildEjesDinamicos(context) : _buildCuatroPlatos(),
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

  Widget _buildEjesDinamicos(BuildContext context) {
    final ejes = pesaje.detalleEjes.isNotEmpty ? pesaje.detalleEjes : _legacyEjes();
    final filas = ejes.map(_buildFilaEje).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildEncabezadoEjes(),
        const SizedBox(height: 4),
        for (int i = 0; i < filas.length; i++) ...[
          filas[i],
          if (i < filas.length - 1) const SizedBox(height: 4),
        ],
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            PlatoPesadas(title: 'Lado Izq.' , peso: pesaje.ladoIzq, porcentaje: ''),
            PlatoPesadas(title: 'Lado Der.' , peso: pesaje.ladoDer, porcentaje: ''),
          ],
        ),
      ],
    );
  }

  Widget _buildEncabezadoEjes() {
    return Container(
      decoration: BoxDecoration(
        color: ThemeApp.colorTituloPlatos,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('Eje', style: ThemeApp.fontWithtitlePlatosPesadas, textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text('Izq', style: ThemeApp.fontWithtitlePlatosPesadas, textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text('Total', style: ThemeApp.fontWithtitlePlatosPesadas, textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text('Der', style: ThemeApp.fontWithtitlePlatosPesadas, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildFilaEje(EjeDetalle eje) {
    return Container(
      decoration: BoxDecoration(
        color: ThemeApp.colorPesoPlatos,
        borderRadius: BorderRadius.circular(6),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '${eje.nroEje}',
              textAlign: TextAlign.center,
              style: ThemeApp.fontStandard,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              eje.pesoIzq,
              textAlign: TextAlign.center,
              style: ThemeApp.fontPlatosPesadas,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              eje.pesoTotal,
              textAlign: TextAlign.center,
              style: ThemeApp.fontPlatosPesadas,
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              eje.pesoDer,
              textAlign: TextAlign.center,
              style: ThemeApp.fontPlatosPesadas,
            ),
          ),
        ],
      ),
    );
  }

  List<EjeDetalle> _legacyEjes() {
    final ejes = <EjeDetalle>[];

    void add(int nroEje, String izq, String der, String total) {
      if (izq.isEmpty && der.isEmpty && total.isEmpty) return;
      ejes.add(
        EjeDetalle(
          nroEje: nroEje,
          pesoIzq: izq,
          pesoDer: der,
          pesoTotal: total,
        ),
      );
    }

    add(1, pesaje.delIzq, pesaje.delDer, pesaje.ejeDel);
    add(2, pesaje.trasIzq, pesaje.trasDer, pesaje.ejeTras);
    add(3, pesaje.eje3Izq, pesaje.eje3Der, pesaje.ejeTer);

    return ejes;
  }
}






