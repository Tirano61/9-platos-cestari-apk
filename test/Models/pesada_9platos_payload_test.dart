import 'package:flutter_test/flutter_test.dart';

import '../list_pesajes/list_pesaje.dart';

void main() {
  group('Pesada9PlatosPayload.toExportRow', () {
    test('Arma la fila de la hoja 9_platos con cabecera y detalle', () {
      expect(pesada9PlatosEjemplo.toExportRow(), listPesaje.first);
    });

    test('Las columnas salen en el orden de la hoja y sin pesada_id', () {
      final columnas = pesada9PlatosEjemplo.toExportRow().keys.toList();

      expect(columnas, listPesaje.first.keys.toList());
      expect(columnas.length, 35);
      expect(columnas.contains('pesada_id'), isFalse);
    });
  });
}
