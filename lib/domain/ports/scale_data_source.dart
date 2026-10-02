import 'dart:async';

import 'package:nueve_platos_cestari/domain/entities/scale_reading.dart';

abstract class ScaleDataSource {
  Stream<ScaleReading> readings();
  Future<void> start();
  Future<void> stop();
}
