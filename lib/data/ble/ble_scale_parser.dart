import 'dart:convert';

import 'package:nueve_platos_cestari/domain/entities/scale_reading.dart';

class BleScaleParser {
  const BleScaleParser();

  ScaleReading? parse({
    required List<int> rawData,
    required String sourceId,
  }) {
    if (rawData.isEmpty) return null;

    try {
      final payload = utf8.decode(rawData, allowMalformed: true).trim();
      if (payload.isEmpty || !payload.startsWith('{')) return null;

      final map = jsonDecode(payload);
      if (map is! Map<String, dynamic>) return null;

      final peso = (map['peso'] ?? '0').toString();
      final estBalanza = _toInt(map['estBalanza']);
      final estable = _mapEstable(estBalanza);
      final tension = (map['vbat'] ?? '0').toString();
      final nombre = (map['nombre'] ?? sourceId).toString();

      return ScaleReading(
        peso: peso,
        estable: estable,
        tension: tension,
        sourceId: nombre,
      );
    } catch (_) {
      return null;
    }
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _mapEstable(int estBalanza) {
    if (estBalanza == 1) return '1';
    if (estBalanza == 5) return '5';
    return '0';
  }
}
