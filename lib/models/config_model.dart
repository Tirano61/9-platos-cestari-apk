

// To parse this JSON data, do
//
//     final configModel = configModelFromJson(jsonString);

import 'dart:convert';

import 'package:nueve_platos_cestari/BaseDeDatos/helpers/settings/first_data.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/tables/db_config.dart';
import 'package:nueve_platos_cestari/config/platos.dart';

ConfigModel configModelFromJson(String str) => ConfigModel.fromJson(json.decode(str));

String configModelToJson(ConfigModel data) => json.encode(data.toJson());

class ConfigModel {
    int? id;
    /// Puerto UDP de cada plato: el indice 0 es el plato 1.
    final List<String> puertos;

    ConfigModel({
        this.id,
        required this.puertos,
    }) : assert(puertos.length == cantidadPlatos);

    /// Puerto del plato [plato] (1..cantidadPlatos).
    String puerto(int plato) => puertos[plato - 1];

    factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
        id: json["id"],
        puertos: [
          for (var n = 1; n <= cantidadPlatos; n++)
            json[DBconfig.fconPlato(n)] ?? puertoPorDefecto(n),
        ],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        for (var n = 1; n <= cantidadPlatos; n++)
          DBconfig.fconPlato(n): puerto(n),
    };
}
