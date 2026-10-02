import 'dart:convert';

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
    final String ladoDer;
    final String porLadoDer;
    final String ladoIzq;
    final String porLadoIzq;
    final String total;
    final String tipoPesada;

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
        required this.ladoDer,
        required this.porLadoDer,
        required this.ladoIzq,
        required this.porLadoIzq,
        required this.total,
        this.tipoPesada = '',
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
        ladoDer       : json["ladoDer"],
        porLadoDer    : json["porLadoDer"],
        ladoIzq       : json["ladoIzq"],
        porLadoIzq    : json["porLadoIzq"],
        total         : json["total"],
        tipoPesada    : (json["tipoPesada"] ?? '').toString(),
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
        "ladoDer"       : ladoDer,
        "porLadoDer"    : porLadoDer,
        "ladoIzq"       : ladoIzq,
        "porLadoIzq"    : porLadoIzq,
        "total"         : total,
        "tipoPesada"    : tipoPesada,
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
        "ladoDer",
        "porLadoDer",
        "ladoIzq",
        "porLadoIzq",
        "total"
      ];
      return listaEncabezado;
    }
}
