import 'dart:async';

import 'package:cuatro_platos/domain/entities/scale_reading.dart';

abstract class ScaleDataSource {
  Stream<ScaleReading> readings();
  Future<void> start();
  Future<void> stop();
}
