import 'package:get/get.dart';

enum EstadoEje {
  pending,
  active,
  completed,
}

class AxleData {
  const AxleData({
    required this.index,
    required this.leftWeight,
    required this.rightWeight,
    required this.totalWeight,
    required this.status,
  });

  final int index;
  final String leftWeight;
  final String rightWeight;
  final String totalWeight;
  final EstadoEje status;
}

class MultiEjesController extends GetxController {
  MultiEjesController({required this.numEjes}) {
    _totalesPorPlato.assignAll(List<String>.filled(numEjes * 2, '0'));
    _savePorEje.assignAll(List<bool>.filled(numEjes, false));
  }

  final int numEjes;

  final _ejeActivo = 1.obs;
  final _totalesPorPlato = <String>[].obs;
  final _savePorEje = <bool>[].obs;

  RxInt get getEjeActivo => _ejeActivo;
  RxList<String> get getTotalesPorPlato => _totalesPorPlato;
  RxList<bool> get getSavePorEje => _savePorEje;
  int get currentAxleIndex => _ejeActivo.value;

  void setEjeActivo(int eje) {
    if (eje >= 1 && eje <= numEjes) {
      _ejeActivo.value = eje;
    }
  }

  bool isEjeGuardado(int eje) {
    return _savePorEje[eje - 1];
  }

  void setSaveEje(int eje, bool save) {
    _savePorEje[eje - 1] = save;
    _savePorEje.refresh();
  }

  String getPlatoPeso(int platoIndex) {
    return _totalesPorPlato[platoIndex];
  }

  void setPlatoPeso(int platoIndex, String peso) {
    _totalesPorPlato[platoIndex] = peso;
    _totalesPorPlato.refresh();
  }

  int platoIzquierdoIndex(int eje) {
    return (eje - 1) * 2;
  }

  int platoDerechoIndex(int eje) {
    return (eje - 1) * 2 + 1;
  }

  void syncPesosEjeActual({
    required String pesoIzquierdo,
    required String pesoDerecho,
  }) {
    final eje = _ejeActivo.value;
    if (!isEjeGuardado(eje)) {
      setPlatoPeso(platoIzquierdoIndex(eje), pesoIzquierdo);
      setPlatoPeso(platoDerechoIndex(eje), pesoDerecho);
    }
  }

  void guardarEjeActual({
    required String pesoIzquierdo,
    required String pesoDerecho,
  }) {
    final eje = _ejeActivo.value;
    setSaveEje(eje, true);
    setPlatoPeso(platoIzquierdoIndex(eje), pesoIzquierdo);
    setPlatoPeso(platoDerechoIndex(eje), pesoDerecho);

    final siguiente = siguienteEjePendiente(fromEje: eje);
    if (siguiente != null) {
      setEjeActivo(siguiente);
    }
  }

  bool get allEjesGuardados {
    return _savePorEje.every((guardado) => guardado);
  }

  int? siguienteEjePendiente({int? fromEje}) {
    if (allEjesGuardados) {
      return null;
    }

    final inicio = fromEje ?? _ejeActivo.value;

    for (var eje = inicio + 1; eje <= numEjes; eje++) {
      if (!isEjeGuardado(eje)) {
        return eje;
      }
    }

    for (var eje = 1; eje <= numEjes; eje++) {
      if (!isEjeGuardado(eje)) {
        return eje;
      }
    }

    return null;
  }

  List<String> snapshotPesos() {
    return List<String>.from(_totalesPorPlato);
  }

  EstadoEje estadoEje(int eje) {
    if (isEjeGuardado(eje)) {
      return EstadoEje.completed;
    }
    if (eje == currentAxleIndex) {
      return EstadoEje.active;
    }
    return EstadoEje.pending;
  }

  List<AxleData> snapshotEjes() {
    return List<AxleData>.generate(numEjes, (index) {
      final eje = index + 1;
      final left = getPlatoPeso(platoIzquierdoIndex(eje));
      final right = getPlatoPeso(platoDerechoIndex(eje));
      final total = ((double.tryParse(left) ?? 0) + (double.tryParse(right) ?? 0))
          .toStringAsFixed(2);

      return AxleData(
        index: eje,
        leftWeight: left,
        rightWeight: right,
        totalWeight: total,
        status: estadoEje(eje),
      );
    });
  }

  String pesoTotal() {
    final total = _totalesPorPlato.fold<double>(
      0,
      (sum, value) => sum + (double.tryParse(value) ?? 0),
    );
    return total.toStringAsFixed(2);
  }

  void resetPesaje() {
    _ejeActivo.value = 1;
    _totalesPorPlato.assignAll(List<String>.filled(numEjes * 2, '0'));
    _savePorEje.assignAll(List<bool>.filled(numEjes, false));
  }
}
