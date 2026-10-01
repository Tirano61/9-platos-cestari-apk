



import 'package:cuatro_platos/BaseDeDatos/tables/db_pesadas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Creaciion de tabla pesadas', () {
    test('Probando el nombre de la tabla', () {
      expect(DBpesadas.tableNamePesadas, 'tpesadas');
    });
    test('Probando la cantidad de columnas de la tpesada', () {
      expect(DBpesadas.fpesId          , 'id');
      expect(DBpesadas.fpFecha         , 'fecha');
      expect(DBpesadas.fpHora          , 'hora');
      expect(DBpesadas.fpidentificacion, 'identificacion');
      expect(DBpesadas.fpdelDer        , 'delDer');
      expect(DBpesadas.fpporDelDer     , 'porDelDer');
      expect(DBpesadas.fpdelIzq        , 'delIzq');
      expect(DBpesadas.fpporDelIzq     , 'porDelIzq');
      expect(DBpesadas.fptrasDer       , 'trasDer');
      expect(DBpesadas.fpporTrasDer    , 'porTrasDer');
      expect(DBpesadas.fptrasIzq       , 'trasIzq');
      expect(DBpesadas.fpporTrasIzq    , 'porTrasIzq');
      expect(DBpesadas.fpejeDel        , 'ejeDel');
      expect(DBpesadas.fpporEjeDel     , 'porEjeDel');
      expect(DBpesadas.fpejeTras       , 'ejeTras');
      expect(DBpesadas.fpporEjeTras    , 'porEjeTras');
      expect(DBpesadas.fpladoDer       , 'ladoDer');
      expect(DBpesadas.fpporLadoDer    , 'porLadoDer');
      expect(DBpesadas.fpladoIzq       , 'ladoIzq');
      expect(DBpesadas.fpporLadoIzq    , 'porLadoIzq');
      expect(DBpesadas.fptotal         , 'total');

    });
    test('Prueba el largo de Create Table', () {
      expect(DBpesadas.createTablePesadas.length, 481);
    });
  });
}