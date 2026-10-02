

// To parse this JSON data, do
//
//     final configModel = configModelFromJson(jsonString);

import 'dart:convert';

ConfigModel configModelFromJson(String str) => ConfigModel.fromJson(json.decode(str));

String configModelToJson(ConfigModel data) => json.encode(data.toJson());

class ConfigModel {
    int? id;
    String plato1;
    String plato2;
    String plato3;
    String plato4;

    ConfigModel({
        this.id,
        required this.plato1,
        required this.plato2,
        required this.plato3,
        required this.plato4,
    });

    factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
        id: json["id"],
        plato1: json["plato1"] ?? '8001',
        plato2: json["plato2"] ?? '8002',
        plato3: json["plato3"] ?? '8003',
        plato4: json["plato4"] ?? '8004',
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "plato1": plato1,
        "plato2": plato2,
        "plato3": plato3,
        "plato4": plato4,
    };
}
