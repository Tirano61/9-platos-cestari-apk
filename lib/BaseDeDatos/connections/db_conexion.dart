

import 'dart:io';


import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/settings/config_interfaces.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_config.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_pesadas_9platos.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_pesadas_base.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_9platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_payload_model.dart';
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
      // foreign_keys es por conexion: se activa en cada apertura para que
      // el ON DELETE CASCADE de tpesadas_9platos funcione siempre.
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (db){},
      onCreate: ( Database db, int version )async{
        await db.execute(DBPesadasBase.createTable);
        await db.execute(DBPesadasBase.createIndexFecha);
        await db.execute(DBPesadasBase.createIndexTipo);
        await db.execute(DBPesadas9Platos.createTable);
        await db.execute(DBconfig.createTableConfig);
      },
      onUpgrade: (db, oldVersion, newVersion) async {},
    );
  }

  @override
  Future<int> insertPesada9Platos({
    required PesadaBase base,
    required Pesada9PlatosDetalle detalle,
  }) async {
    try {
      final db = await getDataBase;
      return await db.transaction<int>((txn) async {
        final basePayload = base.toDb();
        if ((basePayload['created_at'] ?? '').toString().trim().isEmpty) {
          basePayload['created_at'] = DateTime.now().toIso8601String();
        }

        final baseId = await txn.insert(DBPesadasBase.tableName, basePayload);
        final detallePayload = detalle.toDb();
        detallePayload['pesada_id'] = baseId;
        await txn.insert(DBPesadas9Platos.tableName, detallePayload);
        return baseId;
      });
    } catch (e) {
      return -1;
    }
  }

  @override
  Future<List<Pesada9PlatosPayload>> getPesadas9Platos() async {
    final db = await getDataBase;
    final baseRows = await db.query(
      DBPesadasBase.tableName,
      where: 'tipo_pesada = ?',
      whereArgs: ['9_platos'],
      orderBy: 'id DESC',
    );

    final result = <Pesada9PlatosPayload>[];
    for (final row in baseRows) {
      final detalle = await db.query(
        DBPesadas9Platos.tableName,
        where: 'pesada_id = ?',
        whereArgs: [row['id']],
        limit: 1,
      );
      if (detalle.isEmpty) continue;
      result.add(Pesada9PlatosPayload(
        base: PesadaBase.fromDb(row),
        detalle: Pesada9PlatosDetalle.fromDb(detalle.first),
      ));
    }
    return result;
  }

  @override
  Future<List<Map<String, dynamic>>> getPesadasExportacion()async{
    final pesadas = await getPesadas9Platos();
    return pesadas.map((e) => e.toExportRow()).toList();
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