import 'package:cuatro_platos/domain/entities/scale_reading.dart';
import 'package:flutter/foundation.dart';

class UdpScaleParser {
  const UdpScaleParser();

  ScaleReading? parse({
    required List<int> rawData,
    required String sourceId,
  }) {
    if (rawData.isEmpty) return null;

    // Trama del plato: "ADC = peso,estable,x,tension" + terminador.
    final payload = String.fromCharCodes(rawData);
    final adc = payload.indexOf('ADC');
    final igual = adc < 0 ? -1 : payload.indexOf('=', adc + 3);
    if (igual < 0) return _descartar(payload, sourceId);

    // Se descarta cualquier terminador final (\r, \n, '>', etc.).
    final body = payload
        .substring(igual + 1)
        .trim()
        .replaceFirst(RegExp(r'[^0-9.\-]+$'), '');
    final parts = body.split(',');
    if (parts.length < 4) return _descartar(payload, sourceId);

    return ScaleReading(
      peso: parts[0].trim(),
      estable: parts[1].trim(),
      tension: parts[3].trim(),
      sourceId: sourceId,
    );
  }

  ScaleReading? _descartar(String payload, String sourceId) {
    debugPrint('UdpScaleParser: trama descartada de $sourceId: ${payload.codeUnits.length} bytes "$payload"');
    return null;
  }
}
