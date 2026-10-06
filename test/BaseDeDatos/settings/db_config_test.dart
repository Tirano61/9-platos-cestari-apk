import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Tabla de 4 platos: agrega plato5..plato9 con el puerto por defecto', () {
    final sql = DBconfig.completarColumnas(['id', 'plato1', 'plato2', 'plato3', 'plato4']);

    expect(sql, [
      for (var n = 5; n <= 9; n++) ...[
        'ALTER TABLE tconfig ADD COLUMN plato$n text;',
        "UPDATE tconfig SET plato$n = '${8000 + n}';",
      ],
    ]);
  });

  test('Tabla completa: no hay nada que agregar', () {
    expect(DBconfig.completarColumnas(['id', for (var n = 1; n <= 9; n++) 'plato$n']), isEmpty);
  });
}
