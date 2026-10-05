import 'package:nueve_platos_cestari/helpers/exportar_xml.dart';
import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';
import 'package:flutter_test/flutter_test.dart';

ManiobraModel _maniobra({int? ensayoId, int numero = 1}) => ManiobraModel(
      id: 10 + numero,
      ensayoId: ensayoId,
      numero: numero,
      horaInicio: '10:00:00',
      horaFin: '10:01:30',
      duracionMs: 90250,
      umbral: '85',
      platos: [
        // Ejemplo del documento: FC 2,48, 119,6 % y EXCEDE.
        const ManiobraPlato(
          plato: 2,
          estatico: '2410.00',
          maximo: '5980.00',
          minimo: '1800.00',
          lecturas: 250,
          capacidad: '5000',
        ),
        // Sin capacidad ni lecturas.
        const ManiobraPlato(
          plato: 9,
          estatico: '0.00',
          maximo: '',
          minimo: '',
          lecturas: 0,
          capacidad: '',
        ),
      ],
    );

void main() {
  test('Las columnas salen en el orden de la hoja maniobras', () {
    final filas = _maniobra(ensayoId: 3).toExportRows(tolva: 'TC-1', fecha: '05/10/2026');
    for (final fila in filas) {
      expect(fila.keys.toList(), [
        'ensayo_id',
        'tolva',
        'fecha',
        'maniobra',
        'hora_inicio',
        'hora_fin',
        'duracion_s',
        'plato',
        'nombre',
        'capacidad',
        'estatico',
        'maximo',
        'minimo',
        'lecturas',
        'factor_cresta',
        'por_cap',
        'estado',
      ]);
    }
  });

  test('Una fila por plato con los calculos de la maniobra', () {
    final filas = _maniobra(ensayoId: 3, numero: 4).toExportRows(tolva: 'TC-1', fecha: '05/10/2026');
    expect(filas, hasLength(2));
    expect(filas[0], {
      'ensayo_id': 3,
      'tolva': 'TC-1',
      'fecha': '05/10/2026',
      'maniobra': 4,
      'hora_inicio': '10:00:00',
      'hora_fin': '10:01:30',
      'duracion_s': '90.3',
      'plato': 2,
      'nombre': 'J1 IZQ',
      'capacidad': '5000',
      'estatico': '2410.00',
      'maximo': '5980.00',
      'minimo': '1800.00',
      'lecturas': 250,
      'factor_cresta': '2.48',
      'por_cap': '119.6',
      'estado': 'EXCEDE',
    });
    expect(filas[1]['nombre'], 'J4 DER');
    expect(filas[1]['factor_cresta'], '-');
    expect(filas[1]['por_cap'], '-');
    expect(filas[1]['estado'], '-');
  });

  test('Sin ensayo_id la columna queda vacia', () {
    final filas = _maniobra().toExportRows(tolva: 'TC-1', fecha: '05/10/2026');
    expect(filas.first['ensayo_id'], '');
  });

  test('filasEnsayos: de los ensayos mas viejos a los mas nuevos', () {
    // getEnsayos los devuelve por id descendente.
    final ensayos = [
      EnsayoModel(
        id: 2,
        tolva: 'Tolva 2',
        fecha: '05/10/2026',
        createdAt: '2026-10-05T10:00:00',
        maniobras: [_maniobra(ensayoId: 2)],
      ),
      EnsayoModel(
        id: 1,
        tolva: 'Tolva 1',
        fecha: '01/10/2026',
        createdAt: '2026-10-01T10:00:00',
        maniobras: [_maniobra(ensayoId: 1), _maniobra(ensayoId: 1, numero: 2)],
      ),
      const EnsayoModel(id: 3, tolva: 'Vacio', fecha: '05/10/2026', createdAt: '2026-10-05T11:00:00'),
    ];

    final filas = Exportar.filasEnsayos(ensayos);
    expect(filas, hasLength(6));
    expect(
      filas.map((f) => '${f['tolva']} ${f['maniobra']} ${f['plato']}').toList(),
      ['Tolva 1 1 2', 'Tolva 1 1 9', 'Tolva 1 2 2', 'Tolva 1 2 9', 'Tolva 2 1 2', 'Tolva 2 1 9'],
    );
    expect(Exportar.filasEnsayos(const []), isEmpty);
  });
}
