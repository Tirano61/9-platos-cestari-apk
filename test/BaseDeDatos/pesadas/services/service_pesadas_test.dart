

import 'package:nueve_platos_cestari/BaseDeDatos/services/pesadas/service_pesadas.dart';
import 'package:nueve_platos_cestari/Controllers/calculos_controllers.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../list_pesajes/list_pesaje.dart';
import '../../../moks/db_connection_mock.dart';


void main() {
  group('Prueba la clase ServicePesada', () {
    
    final service = ServicePesadas(DbConnectionMock());
    test('Para exportar debe retornar las filas de la hoja 9_platos', ()async {
      final resp = await service.getPesadasExportacion();

      expect(resp, listPesaje);
    });
    test('El historial debe retornar las pesadas de 9 platos', ()async {
      final resp = await service.getPesadas9Platos();

      expect(resp, [pesada9PlatosEjemplo]);
    });
    test('Al insertar debe retornar el id', ()async {
      final payload = await CalculosController.cn.calcularPayload9Platos(
        pesos: List.filled(9, '10.00'),
      );
      final resp = await service.insertarPesada9Platos(
        base: payload.base,
        detalle: payload.detalle,
      );

      expect(resp, 1);      
    });
    test('deletePesada Debe retornar 1', ()async{
      final resp = await service.deletePesada('1');
      expect(resp, 1);
    });
    test('deletePesadas debe retornar 1', () {
      
    });
  });
}