

import 'dart:io';


import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/settings/config_interfaces.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_config.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_pesadas_4platos.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_pesadas_base.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_pesadas_ejes.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_pesadas_ejes_detalle.dart';
import 'package:nueve_platos_cestari/models/pesaje_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_4platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_ejes_model.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/pesadas/pesadas_interfaces.dart';
import 'package:nueve_platos_cestari/models/config_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
/// Base de datos
class DBconeccion extends PesadasInterface implements ConfigInterface {

  static final DBconeccion db = DBconeccion._internal();
  final int dbVersion = 1;
  static Database? _database;

  DBconeccion._internal();

  Future<Database> get getDataBase async{
    if(_database != null) return _database!;
    _database = await initDB();
    return _database!;
  }

  initDB() async{
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String path = p.join(documentDirectory.path, 'platos.db'); 

    return await openDatabase(
      path,
      version: dbVersion,
      onOpen: (db){},
      onCreate: ( Database db, int version )async{
        await db.execute('PRAGMA foreign_keys = ON');
        await db.execute(DBPesadasBase.createTable);
        await db.execute(DBPesadasBase.createIndexFecha);
        await db.execute(DBPesadasBase.createIndexTipo);
        await db.execute(DBPesadas4Platos.createTable);
        await db.execute(DBPesadasEjes.createTable);
        await db.execute(DBPesadasEjesDetalle.createTable);
        await db.execute(DBPesadasEjesDetalle.createIndexPesadaId);
        await db.execute(DBconfig.createTableConfig);
      },
      onUpgrade: (db, oldVersion, newVersion) async {},
    );
  }

  @override
  Future<int> insertPesada(Pesaje pesaje)async{
    try {
      final createdAt = DateTime.now().toIso8601String();
      final isEjes = _isPesajePorEjes(pesaje);
      final base = PesadaBase(
        fecha: pesaje.fecha,
        hora: pesaje.hora,
        identificacion: pesaje.identificacion,
        tipoPesada: isEjes ? '2_platos_ejes' : '4_platos',
        total: pesaje.total,
        createdAt: createdAt,
      );

      if (isEjes) {
        final ejes = _extractEjesFromPesaje(pesaje);
        final cabeceraEjes = PesadaEjesCabecera(
          pesadaId: 0,
          cantidadEjes: ejes.length,
          ladoIzqTotal: pesaje.ladoIzq,
          ladoDerTotal: pesaje.ladoDer,
        );
        final detalleEjes = List<EjeDetalle>.generate(
          ejes.length,
          (index) => EjeDetalle(
            nroEje: index + 1,
            pesoIzq: (ejes[index]['izq'] ?? '').toString(),
            pesoDer: (ejes[index]['der'] ?? '').toString(),
            pesoTotal: (ejes[index]['total'] ?? '').toString(),
          ),
        );
        return insertPesadaPorEjes(
          base: base,
          cabecera: cabeceraEjes,
          detalleEjes: detalleEjes,
        );
      }

      final detalle4Platos = Pesada4PlatosDetalle(
        pesadaId: 0,
        delIzq: pesaje.delIzq,
        delDer: pesaje.delDer,
        trasIzq: pesaje.trasIzq,
        trasDer: pesaje.trasDer,
        ejeDel: pesaje.ejeDel,
        ejeTras: pesaje.ejeTras,
        ladoIzq: pesaje.ladoIzq,
        ladoDer: pesaje.ladoDer,
        porDelIzq: pesaje.porDelIzq,
        porDelDer: pesaje.porDelDer,
        porTrasIzq: pesaje.porTrasIzq,
        porTrasDer: pesaje.porTrasDer,
        porEjeDel: pesaje.porEjeDel,
        porEjeTras: pesaje.porEjeTras,
        porLadoIzq: pesaje.porLadoIzq,
        porLadoDer: pesaje.porLadoDer,
      );
      return insertPesada4Platos(base: base, detalle: detalle4Platos);
    } catch (e) {
      return -1; 
    }
  }

  @override
  Future<int> insertPesada4Platos({
    required PesadaBase base,
    required Pesada4PlatosDetalle detalle,
  }) async {
    final db = await getDataBase;
    return db.transaction<int>((txn) async {
      final basePayload = base.toDb();
      if ((basePayload['created_at'] ?? '').toString().trim().isEmpty) {
        basePayload['created_at'] = DateTime.now().toIso8601String();
      }

      final baseId = await txn.insert(DBPesadasBase.tableName, basePayload);
      final detallePayload = detalle.toDb();
      detallePayload['pesada_id'] = baseId;
      await txn.insert(DBPesadas4Platos.tableName, detallePayload);
      return baseId;
    });
  }

  @override
  Future<int> insertPesadaPorEjes({
    required PesadaBase base,
    required PesadaEjesCabecera cabecera,
    required List<EjeDetalle> detalleEjes,
  }) async {
    final db = await getDataBase;
    return db.transaction<int>((txn) async {
      final basePayload = base.toDb();
      if ((basePayload['created_at'] ?? '').toString().trim().isEmpty) {
        basePayload['created_at'] = DateTime.now().toIso8601String();
      }

      final baseId = await txn.insert(DBPesadasBase.tableName, basePayload);

      final cabeceraPayload = cabecera.toDb();
      cabeceraPayload['pesada_id'] = baseId;
      cabeceraPayload['cantidad_ejes'] = detalleEjes.length;
      await txn.insert(DBPesadasEjes.tableName, cabeceraPayload);

      for (int i = 0; i < detalleEjes.length; i++) {
        final eje = detalleEjes[i];
        final ejePayload = eje.toDb(pesadaId: baseId);
        ejePayload['nro_eje'] = i + 1;
        await txn.insert(DBPesadasEjesDetalle.tableName, ejePayload);
      }

      return baseId;
    });
  }

  @override
  Future<List<Pesaje>> getPesadas()async{
    final db = await getDataBase;
    final baseRows = await db.query(
      DBPesadasBase.tableName,
      orderBy: 'id DESC',
    );

    if (baseRows.isEmpty) return [];

    final List<Pesaje> result = [];

    for (final row in baseRows) {
      final id = row['id'] as int;
      final tipo = (row['tipo_pesada'] ?? '4_platos').toString();

      if (tipo == '4_platos') {
        final detalle = await db.query(
          DBPesadas4Platos.tableName,
          where: 'pesada_id = ?',
          whereArgs: [id],
          limit: 1,
        );

        if (detalle.isEmpty) continue;
        result.add(_map4PlatosToPesaje(row, detalle.first));
        continue;
      }

      final cabeceraEjes = await db.query(
        DBPesadasEjes.tableName,
        where: 'pesada_id = ?',
        whereArgs: [id],
        limit: 1,
      );

      final detallesEjes = await db.query(
        DBPesadasEjesDetalle.tableName,
        where: 'pesada_id = ?',
        whereArgs: [id],
        orderBy: 'nro_eje ASC',
      );

      if (detallesEjes.isEmpty) continue;
      result.add(_mapEjesToPesaje(row, cabeceraEjes.isNotEmpty ? cabeceraEjes.first : null, detallesEjes));
    }

    return result;
  }

  @override
  Future<List<Pesaje>> getPesadas4Platos() async {
    final db = await getDataBase;
    final baseRows = await db.query(
      DBPesadasBase.tableName,
      where: 'tipo_pesada = ?',
      whereArgs: ['4_platos'],
      orderBy: 'id DESC',
    );

    final result = <Pesaje>[];
    for (final row in baseRows) {
      final detalle = await db.query(
        DBPesadas4Platos.tableName,
        where: 'pesada_id = ?',
        whereArgs: [row['id']],
        limit: 1,
      );
      if (detalle.isEmpty) continue;
      result.add(_map4PlatosToPesaje(row, detalle.first));
    }
    return result;
  }

  @override
  Future<List<Pesaje>> getPesadasPorEjes() async {
    final db = await getDataBase;
    final baseRows = await db.query(
      DBPesadasBase.tableName,
      where: 'tipo_pesada = ?',
      whereArgs: ['2_platos_ejes'],
      orderBy: 'id DESC',
    );

    final result = <Pesaje>[];
    for (final row in baseRows) {
      final id = row['id'] as int;
      final cabeceraEjes = await db.query(
        DBPesadasEjes.tableName,
        where: 'pesada_id = ?',
        whereArgs: [id],
        limit: 1,
      );
      final detallesEjes = await db.query(
        DBPesadasEjesDetalle.tableName,
        where: 'pesada_id = ?',
        whereArgs: [id],
        orderBy: 'nro_eje ASC',
      );
      if (detallesEjes.isEmpty) continue;
      result.add(_mapEjesToPesaje(row, cabeceraEjes.isNotEmpty ? cabeceraEjes.first : null, detallesEjes));
    }

    return result;
  }
  @override
  Future<List<Map<String, dynamic>>> getPesadasExportacion()async{
    final pesadas = await getPesadas();
    return pesadas
        .map((e) => {
              'id': e.id,
              ...e.toJson(),
            })
        .toList();
  }
  @override
  Future<int> deletePesadas()async{
    final db = await getDataBase;
    final resp = await db.delete(DBPesadasBase.tableName);
    return resp;
  }
  
  @override
  Future<int> deletePesada(String id)async {
    final db = await getDataBase;
    final resp = await db.delete(DBPesadasBase.tableName,where:'id=?' ,whereArgs: [id]);

    return resp;
  }

  bool _isPesajePorEjes(Pesaje pesaje) {
    if (pesaje.tipoPesada == '2_platos_ejes') return true;
    if (pesaje.tipoPesada == '4_platos') return false;

    return pesaje.detalleEjes.isNotEmpty ||
        pesaje.eje3Izq.isNotEmpty ||
        pesaje.eje3Der.isNotEmpty ||
        pesaje.ejeTer.isNotEmpty;
  }

  List<Map<String, String>> _extractEjesFromPesaje(Pesaje pesaje) {
    if (pesaje.detalleEjes.isNotEmpty) {
      return pesaje.detalleEjes
          .map(
            (e) => {
              'izq': e.pesoIzq,
              'der': e.pesoDer,
              'total': e.pesoTotal,
            },
          )
          .toList();
    }

    final ejes = <Map<String, String>>[];

    void addEje(String izq, String der, String total) {
      if (izq.isEmpty && der.isEmpty && total.isEmpty) return;
      ejes.add({
        'izq': izq,
        'der': der,
        'total': total.isEmpty
            ? ((double.tryParse(izq) ?? 0) + (double.tryParse(der) ?? 0)).toStringAsFixed(2)
            : total,
      });
    }

    addEje(pesaje.delIzq, pesaje.delDer, pesaje.ejeDel);
    addEje(pesaje.trasIzq, pesaje.trasDer, pesaje.ejeTras);
    addEje(pesaje.eje3Izq, pesaje.eje3Der, pesaje.ejeTer);

    return ejes;
  }

  Pesaje _map4PlatosToPesaje(Map<String, dynamic> baseRow, Map<String, dynamic> detalleRow) {
    final base = PesadaBase.fromDb(baseRow);
    final detalle = Pesada4PlatosDetalle.fromDb(detalleRow);

    return Pesaje(
      id: base.id,
      fecha: base.fecha,
      hora: base.hora,
      identificacion: base.identificacion,
      delDer: detalle.delDer,
      porDelDer: detalle.porDelDer,
      delIzq: detalle.delIzq,
      porDelIzq: detalle.porDelIzq,
      trasDer: detalle.trasDer,
      porTrasDer: detalle.porTrasDer,
      trasIzq: detalle.trasIzq,
      porTrasIzq: detalle.porTrasIzq,
      ejeDel: detalle.ejeDel,
      porEjeDel: detalle.porEjeDel,
      ejeTras: detalle.ejeTras,
      porEjeTras: detalle.porEjeTras,
      eje3Izq: '',
      porEje3Izq: '',
      eje3Der: '',
      porEje3Der: '',
      ejeTer: '',
      porEjeTer: '',
      ladoDer: detalle.ladoDer,
      porLadoDer: detalle.porLadoDer,
      ladoIzq: detalle.ladoIzq,
      porLadoIzq: detalle.porLadoIzq,
      total: base.total,
      detalleEjes: const [],
      tipoPesada: '4_platos',
      cantidadEjes: 0,
    );
  }

  Pesaje _mapEjesToPesaje(
    Map<String, dynamic> baseRow,
    Map<String, dynamic>? cabeceraRow,
    List<Map<String, dynamic>> detalleRows,
  ) {
    final base = PesadaBase.fromDb(baseRow);
    final cabecera = cabeceraRow == null ? null : PesadaEjesCabecera.fromDb(cabeceraRow);
    String izq(int index) =>
        index < detalleRows.length ? (detalleRows[index]['peso_izq'] ?? '').toString() : '';
    String der(int index) =>
        index < detalleRows.length ? (detalleRows[index]['peso_der'] ?? '').toString() : '';
    String total(int index) =>
        index < detalleRows.length ? (detalleRows[index]['peso_total_eje'] ?? '').toString() : '';

    final detalleEjes = detalleRows
        .map(
          (row) => EjeDetalle.fromJson(row),
        )
        .toList();

    return Pesaje(
      id: base.id,
      fecha: base.fecha,
      hora: base.hora,
      identificacion: base.identificacion,
      delDer: der(0),
      porDelDer: '',
      delIzq: izq(0),
      porDelIzq: '',
      trasDer: der(1),
      porTrasDer: '',
      trasIzq: izq(1),
      porTrasIzq: '',
      ejeDel: total(0),
      porEjeDel: '',
      ejeTras: total(1),
      porEjeTras: '',
      eje3Izq: izq(2),
      porEje3Izq: '',
      eje3Der: der(2),
      porEje3Der: '',
      ejeTer: total(2),
      porEjeTer: '',
      ladoDer: cabecera?.ladoDerTotal ?? '',
      porLadoDer: '',
      ladoIzq: cabecera?.ladoIzqTotal ?? '',
      porLadoIzq: '',
      total: base.total,
      detalleEjes: detalleEjes,
      tipoPesada: '2_platos_ejes',
      cantidadEjes: cabecera?.cantidadEjes ?? detalleEjes.length,
    );
  }

  @override
  Future<List<ConfigModel>> getConfig()async {
    final db = await getDataBase;
    final resp = await db.query(DBconfig.tableNameConfig,where:'id=?' ,whereArgs: [1]);

    List<ConfigModel> list = resp.isNotEmpty
    ? resp.map((e) => ConfigModel.fromJson(e)).toList()
    : [];

    return list;
  }

  @override
  Future<int> insertConfig(ConfigModel config)async {
    final db = await getDataBase;
    final resp = await db.insert(DBconfig.tableNameConfig, config.toJson());

    return resp;
  }
  
  @override
  Future<int> upDateConfig(ConfigModel config)async {
    final db = await getDataBase;
    config.id = 1;
    final resp = await db.update(DBconfig.tableNameConfig, config.toJson(),where: "id=?", whereArgs: ['1']);

    return resp;
  }

  @override
  Future<int> updateBleNameForPlato({
    required int plato,
    required String bleName,
    bool overwrite = false,
  }) async {
    final db = await getDataBase;
    final rows = await db.query(
      DBconfig.tableNameConfig,
      where: 'id=?',
      whereArgs: [1],
      limit: 1,
    );

    if (rows.isEmpty) return -1;

    final targetColumn = switch (plato) {
      1 => DBconfig.fconplato1BleName,
      2 => DBconfig.fconplato2BleName,
      3 => DBconfig.fconplato3BleName,
      4 => DBconfig.fconplato4BleName,
      _ => '',
    };

    if (targetColumn.isEmpty) return -1;

    final normalized = bleName.trim();
    if (normalized.isEmpty) return -1;

    final current = (rows.first[targetColumn] ?? '').toString().trim();
    if (current.isNotEmpty && !overwrite) {
      return 1;
    }

    final resp = await db.update(
      DBconfig.tableNameConfig,
      {
        targetColumn: normalized,
        DBconfig.fconConnectionType: ConnectionType.ble,
      },
      where: 'id=?',
      whereArgs: [1],
    );

    return resp;
  }
  

  

}