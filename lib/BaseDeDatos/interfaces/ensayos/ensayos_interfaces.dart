import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_model.dart';

abstract class EnsayosInterface {

  /// Inserta la cabecera del ensayo (sin maniobras). Devuelve el id o -1.
  Future<int> insertEnsayo(EnsayoModel ensayo);

  /// Inserta la maniobra (con su ensayoId) y sus platos en una transaccion.
  /// Devuelve el id o -1.
  Future<int> insertManiobra(ManiobraModel maniobra);

  /// Ensayos con sus maniobras, id descendente.
  Future<List<EnsayoModel>> getEnsayos();

  Future<int> deleteEnsayo(int id);
  Future<int> deleteManiobra(int id);
  Future<int> deleteEnsayos();

}
