import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/connections/db_conexion.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/services/ensayos/service_ensayos.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';


class Exportar{

  Exportar();

  Future<String?> get _localPath async {
    try {
      Directory? appDocDir;
      String direccion = '';

      var status = await Permission.storage.status;
      if(!status.isGranted){
        await Permission.storage.request();
      }
      /* if (Platform.isAndroid) {
        final androidVersion = await DeviceInfoPlugin().androidInfo;
        if ((androidVersion.version.sdkInt) >= 30){
          //final  downloadsDirectory = await getExternalStorageDirectories();
          //direccion = downloadsDirectory;
          //Esta es una libreria nueva para guardar en Downloads
          direccion = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
        } else{
          Directory? downloadsDirectory = await getDownloadsDirectory();
          direccion = downloadsDirectory!.path;
        } 
        
      } else { */
      if(Platform.isAndroid){
        appDocDir = await getExternalStorageDirectory();
      }else{
        appDocDir = await getApplicationDocumentsDirectory();
      }
      direccion = appDocDir!.path;

      return direccion;
    } catch (e) {
      return e.toString();
    }
  }

  Future<File> _localFile(String nombre) async{
    final path = await _localPath;
    final file = File('$path/$nombre');
    return file;
  }

  /// Filas de la hoja 'maniobras': una por maniobra y plato, de los ensayos
  /// mas viejos a los mas nuevos (getEnsayos los da por id descendente).
  static List<Map<String, dynamic>> filasEnsayos(List<EnsayoModel> ensayos) => [
        for (final ensayo in ensayos.reversed)
          for (final maniobra in ensayo.maniobras)
            ...maniobra.toExportRows(tolva: ensayo.tolva, fecha: ensayo.fecha),
      ];

  /// Genera ensayos.xlsx con la hoja 'maniobras'. Devuelve 1 si lo genero,
  /// 0 si no hay maniobras guardadas y -1 si fallo.
  Future<int> writeFileEnsayos({ServiceEnsayos? ensayos}) async {
    try {
      final service = ensayos ?? ServiceEnsayos(DBconeccion.db);
      final rows = filasEnsayos(await service.getEnsayos());
      if (rows.isEmpty) {
        return 0;
      }

      final libro = Excel.createExcel();
      final defaultSheet = libro.getDefaultSheet();
      if (defaultSheet != null) {
        libro.delete(defaultSheet);
      }
      _buildSheet(libro, 'maniobras', rows);

      final bytes = libro.encode();
      if (bytes == null || bytes.isEmpty) {
        return -1;
      }

      final file = await _localFile(archivoEnsayos);
      await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);
      return 1;
    } catch (e) {
      return -1;
    }
  }

  static const archivoEnsayos = 'ensayos.xlsx';

  void _appendRow(Sheet sheet, List<dynamic> values) {
    sheet.appendRow(values.map((e) => TextCellValue(e.toString())).toList());
  }

  String _v(Map<String, dynamic> row, String key) => (row[key] ?? '').toString();

  /// Hoja [nombre]: el encabezado son las claves de la fila
  /// (ManiobraModel.toExportRows), que salen todas con el mismo orden.
  void _buildSheet(Excel libro, String nombre, List<Map<String, dynamic>> rows) {
    final sheet = libro[nombre];
    final columnas = rows.first.keys.toList();
    _appendRow(sheet, columnas);

    for (final row in rows) {
      _appendRow(sheet, columnas.map((c) => _v(row, c)).toList());
    }
  }

  /// Genera ensayos.xlsx con las maniobras guardadas y lo comparte.
  Future<void> compartirArchivo(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    final resp = await writeFileEnsayos();
    if (resp != 1) {
      scaffold.showSnackBar(
        SnackBar(
          content: Text(resp == 0
              ? 'No hay maniobras guardadas para exportar.'
              : 'No se pudo generar el archivo.'),
          backgroundColor: ThemePlatos.errorColor,
        ),
      );
      return;
    }
    final file = await _localFile(archivoEnsayos);

    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Compartir ensayos',
        subject: 'Balanzas Hook, ensayo 9 platos',
      );
    } catch (e) {
      scaffold.showSnackBar(
        SnackBar(
          content: const Text('No se pudo compartir el archivo.'),
          backgroundColor: ThemePlatos.errorColor,
        ),
      );
    }
  }
}
