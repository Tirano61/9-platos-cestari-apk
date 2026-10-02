import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/connections/db_conexion.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/services/pesadas/service_pesadas.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
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

  Future<File> get _localFile async{
    final path = await _localPath;
    final file = File('$path/pesadas.xlsx'); 
    return file;
  }

  Future<int> writeFile(BuildContext context)async{
    try {
      final sservicePesadas = ServicePesadas(DBconeccion.db);
      final file = await _localFile;
      final rows = await sservicePesadas.getPesadasExportacion();
      if (rows.isEmpty) {
        return -1;
      }

      final libro = Excel.createExcel();
      final defaultSheet = libro.getDefaultSheet();
      if (defaultSheet != null) {
        libro.delete(defaultSheet);
      }

      _buildSheet4Platos(libro, rows);

      if ((libro.tables.keys).isEmpty) {
        return -1;
      }

      final bytes = libro.encode();
      if (bytes == null || bytes.isEmpty) {
        return -1;
      }

      await file.writeAsBytes(Uint8List.fromList(bytes), flush: true);
      return 1;

    } catch (e) {
      return -1;
    }
  }

  void _appendRow(Sheet sheet, List<dynamic> values) {
    sheet.appendRow(values.map((e) => TextCellValue(e.toString())).toList());
  }

  String _v(Map<String, dynamic> row, String key) => (row[key] ?? '').toString();

  void _buildSheet4Platos(Excel libro, List<Map<String, dynamic>> rows) {
    final sheet = libro['4_platos'];
    _appendRow(sheet, [
      'id',
      'fecha',
      'hora',
      'identificacion',
      'total',
      'del_izq',
      'del_der',
      'tras_izq',
      'tras_der',
      'eje_del',
      'eje_tras',
      'lado_izq',
      'lado_der',
      'por_del_izq',
      'por_del_der',
      'por_tras_izq',
      'por_tras_der',
      'por_eje_del',
      'por_eje_tras',
      'por_lado_izq',
      'por_lado_der',
    ]);

    for (final row in rows) {
      _appendRow(sheet, [
        _v(row, 'id'),
        _v(row, 'fecha'),
        _v(row, 'hora'),
        _v(row, 'identificacion'),
        _v(row, 'total'),
        _v(row, 'delIzq'),
        _v(row, 'delDer'),
        _v(row, 'trasIzq'),
        _v(row, 'trasDer'),
        _v(row, 'ejeDel'),
        _v(row, 'ejeTras'),
        _v(row, 'ladoIzq'),
        _v(row, 'ladoDer'),
        _v(row, 'porDelIzq'),
        _v(row, 'porDelDer'),
        _v(row, 'porTrasIzq'),
        _v(row, 'porTrasDer'),
        _v(row, 'porEjeDel'),
        _v(row, 'porEjeTras'),
        _v(row, 'porLadoIzq'),
        _v(row, 'porLadoDer'),
      ]);
    }
  }

  compartirArchivo(BuildContext context) async {
    final scaffold = ScaffoldMessenger.of(context);
    final path = await _localPath;
    final filePath = '${path.toString()}/pesadas.xlsx';
    final file = File(filePath);

    if (!await file.exists()) {
      scaffold.showSnackBar(
        SnackBar(
          content: const Text('No se encontró el archivo para compartir.'),
          backgroundColor: ThemePlatos.errorColor,
        ),
      );
      return;
    }

    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Compartir Pesadas',
        subject: 'Balanzas Hook, 4 platos ',
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
