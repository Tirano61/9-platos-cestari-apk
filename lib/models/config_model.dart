

// To parse this JSON data, do
//
//     final configModel = configModelFromJson(jsonString);

import 'dart:convert';

ConfigModel configModelFromJson(String str) => ConfigModel.fromJson(json.decode(str));

String configModelToJson(ConfigModel data) => json.encode(data.toJson());

class ConnectionType {
  static const String udp = 'udp';
  static const String ble = 'ble';
}

class ConfigModel {
    int? id;
    String plato1;
    String plato2;
    String plato3;
    String plato4;
    String connectionType;
    String plato1BleName;
    String plato2BleName;
    String plato3BleName;
    String plato4BleName;

    ConfigModel({
        this.id,
        required this.plato1,
        required this.plato2,
        required this.plato3,
        required this.plato4,
        this.connectionType = ConnectionType.udp,
        this.plato1BleName = '',
        this.plato2BleName = '',
        this.plato3BleName = '',
        this.plato4BleName = '',
    });

    factory ConfigModel.fromJson(Map<String, dynamic> json) => ConfigModel(
        id: json["id"],
        plato1: json["plato1"] ?? '8001',
        plato2: json["plato2"] ?? '8002',
        plato3: json["plato3"] ?? '8003',
        plato4: json["plato4"] ?? '8004',
        connectionType: (json["connection_type"] ?? ConnectionType.udp).toString(),
        plato1BleName: (json["plato1_ble_name"] ?? json["plato1_ble_device_id"] ?? '').toString(),
        plato2BleName: (json["plato2_ble_name"] ?? json["plato2_ble_device_id"] ?? '').toString(),
        plato3BleName: (json["plato3_ble_name"] ?? json["plato3_ble_device_id"] ?? '').toString(),
        plato4BleName: (json["plato4_ble_name"] ?? json["plato4_ble_device_id"] ?? '').toString(),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "plato1": plato1,
        "plato2": plato2,
        "plato3": plato3,
        "plato4": plato4,
        "connection_type": connectionType,
        "plato1_ble_name": plato1BleName,
        "plato2_ble_name": plato2BleName,
        "plato3_ble_name": plato3BleName,
        "plato4_ble_name": plato4BleName,
    };
}
