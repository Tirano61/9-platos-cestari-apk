

import 'dart:io';


import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/ensayos/ensayos_interfaces.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/settings/config_interfaces.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_config.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_ensayos.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_maniobras.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_maniobras_platos.dart';
import 'package:nueve_platos_cestari/models/config_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
/// Base de datos
class DBconeccion implements ConfigInterface, EnsayosInterface {

  static final DBconeccion db = DBconeccion._internal();
  final int dbVersion = 4;
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
      // los ON DELETE CASCADE (maniobras y sus platos) funcionen siempre.
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (db){},
      onCreate: ( Database db, int version )async{
        await db.execute(DBconfig.createTableConfig);
        await _crearTablasEnsayos(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // v2: ensayos y maniobras. tconfig no se toca.
        if (oldVersion < 2) await _crearTablasEnsayos(db);
        // v3: se borran las pesadas (primero el detalle, que apunta a la cabecera).
        if (oldVersion < 3) {
          await db.execute('DROP TABLE IF EXISTS tpesadas_9platos');
          await db.execute('DROP TABLE IF EXISTS tpesadas_base');
        }
        // v4: tconfig de una base creada con 4 platos: faltan plato5..plato9.
        if (oldVersion < 4) await _completarConfig(db);
      },
    );
  }

  /// Agrega a tconfig las columnas de plato que falten.
  static Future<void> _completarConfig(Database db) async {
    final columnas = await db.rawQuery('PRAGMA table_info(${DBconfig.tableNameConfig})');
    final nombres = columnas.map((c) => c['name'] as String);
    for (final sql in DBconfig.completarColumnas(nombres)) {
      await db.execute(sql);
    }
  }

  static Future<void> _crearTablasEnsayos(Database db) async {
    await db.execute(DBEnsayos.createTable);
    await db.execute(DBManiobras.createTable);
    await db.execute(DBManiobras.createIndexEnsayo);
    await db.execute(DBManiobrasPlatos.createTable);
  }

  @override
  Future<int> insertEnsayo(EnsayoModel ensayo) async {
    try {
      final db = await getDataBase;
      return await db.insert(DBEnsayos.tableName, ensayo.toDb());
    } catch (e) {
      return -1;
    }
  }

  @override
  Future<int> insertManiobra(ManiobraModel maniobra) async {
    try {
      final db = await getDataBase;
      return await db.transaction<int>((txn) async {
        final maniobraId = await txn.insert(DBManiobras.tableName, maniobra.toDb());
        for (final plato in maniobra.platos) {
          await txn.insert(DBManiobrasPlatos.tableName, {
            ...plato.toDb(),
            'maniobra_id': maniobraId,
          });
        }
        return maniobraId;
      });
    } catch (e) {
      return -1;
    }
  }

  @override
  Future<List<EnsayoModel>> getEnsayos() async {
    final db = await getDataBase;
    final ensayos = await db.query(DBEnsayos.tableName, orderBy: 'id DESC');

    final result = <EnsayoModel>[];
    for (final ensayo in ensayos) {
      final maniobras = await db.query(
        DBManiobras.tableName,
        where: 'ensayo_id = ?',
        whereArgs: [ensayo['id']],
        orderBy: 'numero ASC',
      );
      final listaManiobras = <ManiobraModel>[];
      for (final maniobra in maniobras) {
        final platos = await db.query(
          DBManiobrasPlatos.tableName,
          where: 'maniobra_id = ?',
          whereArgs: [maniobra['id']],
          orderBy: 'plato ASC',
        );
        listaManiobras.add(ManiobraModel.fromDb(
          maniobra,
          platos: platos.map(ManiobraPlato.fromDb).toList(),
        ));
      }
      result.add(EnsayoModel.fromDb(ensayo, maniobras: listaManiobras));
    }
    return result;
  }

  // El borrado confia en el ON DELETE CASCADE.
  @override
  Future<int> deleteEnsayo(int id) async {
    final db = await getDataBase;
    return await db.delete(DBEnsayos.tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> deleteManiobra(int id) async {
    final db = await getDataBase;
    return await db.delete(DBManiobras.tableName, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> deleteEnsayos() async {
    final db = await getDataBase;
    return await db.delete(DBEnsayos.tableName);
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