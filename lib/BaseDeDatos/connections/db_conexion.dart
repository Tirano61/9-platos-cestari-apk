

import 'dart:io';


import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/settings/config_interfaces.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_config.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_pesadas_4platos.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_pesadas_base.dart';
import 'package:nueve_platos_cestari/models/pesaje_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_4platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';
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
        await db.execute(DBconfig.createTableConfig);
      },
      onUpgrade: (db, oldVersion, newVersion) async {},
    );
  }

  @override
  Future<int> insertPesada(Pesaje pesaje)async{
    try {
      final createdAt = DateTime.now().toIso8601String();
      final base = PesadaBase(
        fecha: pesaje.fecha,
        hora: pesaje.hora,
        identificacion: pesaje.identificacion,
        tipoPesada: '4_platos',
        total: pesaje.total,
        createdAt: createdAt,
      );

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
  Future<List<Pesaje>> getPesadas() => getPesadas4Platos();

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
      ladoDer: detalle.ladoDer,
      porLadoDer: detalle.porLadoDer,
      ladoIzq: detalle.ladoIzq,
      porLadoIzq: detalle.porLadoIzq,
      total: base.total,
      tipoPesada: '4_platos',
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
  

  

}