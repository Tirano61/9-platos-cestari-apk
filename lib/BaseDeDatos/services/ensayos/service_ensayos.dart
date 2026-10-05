import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/ensayos/ensayos_interfaces.dart';
import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_model.dart';

class ServiceEnsayos {

  final EnsayosInterface _ensayosInterface;
  ServiceEnsayos(this._ensayosInterface);

  Future<int> insertarEnsayo(EnsayoModel ensayo) {
    return _ensayosInterface.insertEnsayo(ensayo);
  }
  Future<int> insertarManiobra(ManiobraModel maniobra) {
    return _ensayosInterface.insertManiobra(maniobra);
  }
  Future<List<EnsayoModel>> getEnsayos() {
    return _ensayosInterface.getEnsayos();
  }
  Future<int> deleteEnsayo(int id) {
    return _ensayosInterface.deleteEnsayo(id);
  }
  Future<int> deleteManiobra(int id) {
    return _ensayosInterface.deleteManiobra(id);
  }
  Future<int> deleteEnsayos() {
    return _ensayosInterface.deleteEnsayos();
  }
}
