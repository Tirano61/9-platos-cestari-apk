

import 'dart:io';


import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/ensayos/ensayos_interfaces.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/settings/config_interfaces.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_config.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_ensayos.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_maniobras.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_maniobras_platos.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_pesadas_9platos.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_pesadas_base.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_9platos_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_base_model.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_payload_model.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/pesadas/pesadas_interfaces.dart';
import 'package:nueve_platos_cestari/models/config_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_plato.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
/// Base de datos
class DBconeccion extends PesadasInterface implements ConfigInterface, EnsayosInterface {

  static final DBconeccion db = DBconeccion._internal();
  final int dbVersion = 2;
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
      // los ON DELETE CASCADE (pesadas, maniobras y sus platos) funcionen siempre.
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
        await _crearTablasEnsayos(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // v2: ensayos y maniobras. tconfig y las pesadas no se tocan.
        if (oldVersion < 2) await _crearTablasEnsayos(db);
      },
    );
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