import 'dart:convert';
import 'package:cuatro_platos/models/pesadas/pesada_eje_detalle_model.dart';
export 'package:cuatro_platos/models/pesadas/pesada_eje_detalle_model.dart';

class Pesaje {
    final int? id;
    String identificacion;
    final String fecha;
    final String hora;
    final String delDer;
    final String porDelDer;
    final String delIzq;
    final String porDelIzq;
    final String trasDer;
    final String porTrasDer;
    final String trasIzq;
    final String porTrasIzq;
    final String ejeDel;
    final String porEjeDel;
    final String ejeTras;
    final String porEjeTras;
    final String eje3Izq;
    final String porEje3Izq;
    final String eje3Der;
    final String porEje3Der;
    final String ejeTer;
    final String porEjeTer;
    final String ladoDer;
    final String porLadoDer;
    final String ladoIzq;
    final String porLadoIzq;
    final String total;
    final List<EjeDetalle> detalleEjes;
    final String tipoPesada;
    final int cantidadEjes;

    Pesaje({
        this.id,
        required this.fecha,
        required this.hora,
        required this.identificacion,
        required this.delDer,
        required this.porDelDer,
        required this.delIzq,
        required this.porDelIzq,
        required this.trasDer,
        required this.porTrasDer,
        required this.trasIzq,
        required this.porTrasIzq,
        required this.ejeDel,
        required this.porEjeDel,
        required this.ejeTras,
        required this.porEjeTras,
        this.eje3Izq = '',
        this.porEje3Izq = '',
        this.eje3Der = '',
        this.porEje3Der = '',
        this.ejeTer = '',
        this.porEjeTer = '',
        required this.ladoDer,
        required this.porLadoDer,
        required this.ladoIzq,
        required this.porLadoIzq,
        required this.total,
        this.detalleEjes = const [],
        this.tipoPesada = '',
        this.cantidadEjes = 0,
    });

    factory Pesaje.fromRawJson(String str) => Pesaje.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory Pesaje.fromJson(Map<String, dynamic> json) => Pesaje(
        id            : json["id"],
        fecha         : json["fecha"],
        hora          : json["hora"],
        identificacion: json["identificacion"],
        delDer        : json["delDer"],
        porDelDer     : json["porDelDer"],
        delIzq        : json["delIzq"],
        porDelIzq     : json["porDelIzq"],
        trasDer       : json["trasDer"],
        porTrasDer    : json["porTrasDer"],
        trasIzq       : json["trasIzq"],
        porTrasIzq    : json["porTrasIzq"],
        ejeDel        : json["ejeDel"],
        porEjeDel     : json["porEjeDel"],
        ejeTras       : json["ejeTras"],
        porEjeTras    : json["porEjeTras"],
        eje3Izq       : json["eje3Izq"] ?? '',
        porEje3Izq    : json["porEje3Izq"] ?? '',
        eje3Der       : json["eje3Der"] ?? '',
        porEje3Der    : json["porEje3Der"] ?? '',
        ejeTer        : json["ejeTer"] ?? '',
        porEjeTer     : json["porEjeTer"] ?? '',
        ladoDer       : json["ladoDer"],
        porLadoDer    : json["porLadoDer"],
        ladoIzq       : json["ladoIzq"],
        porLadoIzq    : json["porLadoIzq"],
        total         : json["total"],
        detalleEjes   : (json["detalleEjes"] as List<dynamic>? ?? [])
          .map((e) => EjeDetalle.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
        tipoPesada    : (json["tipoPesada"] ?? '').toString(),
        cantidadEjes  : (json["cantidadEjes"] ?? 0) is int
            ? (json["cantidadEjes"] ?? 0) as int
            : int.tryParse((json["cantidadEjes"] ?? '0').toString()) ?? 0,
    );

    Map<String, dynamic> toJson() => {
        //"id"          : id,
        "fecha"         : fecha,
        "hora"          : hora,
        "identificacion": identificacion,
        "delDer"        : delDer,
        "porDelDer"     : porDelDer,
        "delIzq"        : delIzq,
        "porDelIzq"     : porDelIzq,
        "trasDer"       : trasDer,
        "porTrasDer"    : porTrasDer,
        "trasIzq"       : trasIzq,
        "porTrasIzq"    : porTrasIzq,
        "ejeDel"        : ejeDel,
        "porEjeDel"     : porEjeDel,
        "ejeTras"       : ejeTras,
        "porEjeTras"    : porEjeTras,
        "eje3Izq"       : eje3Izq,
        "porEje3Izq"    : porEje3Izq,
        "eje3Der"       : eje3Der,
        "porEje3Der"    : porEje3Der,
        "ejeTer"        : ejeTer,
        "porEjeTer"     : porEjeTer,
        "ladoDer"       : ladoDer,
        "porLadoDer"    : porLadoDer,
        "ladoIzq"       : ladoIzq,
        "porLadoIzq"    : porLadoIzq,
        "total"         : total,
        "detalleEjes"   : detalleEjes.map((e) => e.toJson()).toList(),
        "tipoPesada"    : tipoPesada,
        "cantidadEjes"  : cantidadEjes,
    };

    List<String> listaEncabezado = [
      "id",
      "fecha",
      "hora",
      "identificacion",
      "delDer",
      "porDelDer",
      "delIzq",
      "porDelIzq",
      "trasDer",
      "porTrasDer",
      "trasIzq",
      "porTrasIzq",
      "ejeDel",
      "porEjeDel",
      "ejeTras",
      "porEjeTras",
      "eje3Izq",
      "porEje3Izq",
      "eje3Der",
      "porEje3Der",
      "ejeTer",
      "porEjeTer",
      "ladoDer",
      "porLadoDer",
      "ladoIzq",
      "porLadoIzq",
      "total"
    ];

    static listaEncabezados(){
      List<String> listaEncabezado = [
        "id",
        "fecha",
        "hora",
        "identificacion",
        "delDer",
        "porDelDer",
        "delIzq",
        "porDelIzq",
        "trasDer",
        "porTrasDer",
        "trasIzq",
        "porTrasIzq",
        "ejeDel",
        "porEjeDel",
        "ejeTras",
        "porEjeTras",
        "eje3Izq",
        "porEje3Izq",
        "eje3Der",
        "porEje3Der",
        "ejeTer",
        "porEjeTer",
        "ladoDer",
        "porLadoDer",
        "ladoIzq",
        "porLadoIzq",
        "total"
      ];
      return listaEncabezado;
    }
}
