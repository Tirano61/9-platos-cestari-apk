import 'package:nueve_platos_cestari/BaseDeDatos/interfaces/ensayos/ensayos_interfaces.dart';
import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_model.dart';

/// Base de ensayos en memoria: ids autoincrementales, id descendente y borrado
/// en cascada, como DBconeccion. Con [fallar] los insert devuelven -1.
class DbEnsayosMock extends EnsayosInterface {
  bool fallar = false;

  final ensayos = <EnsayoModel>[];
  final maniobras = <ManiobraModel>[];
  int _ultimoEnsayo = 0;
  int _ultimaManiobra = 0;

  @override
  Future<int> insertEnsayo(EnsayoModel ensayo) async {
    if (fallar) return -1;
    final id = ++_ultimoEnsayo;
    ensayos.add(EnsayoModel(
      id: id,
      tolva: ensayo.tolva,
      fecha: ensayo.fecha,
      createdAt: ensayo.createdAt,
    ));
    return id;
  }

  @override
  Future<int> insertManiobra(ManiobraModel maniobra) async {
    if (fallar || !ensayos.any((e) => e.id == maniobra.ensayoId)) return -1;
    final id = ++_ultimaManiobra;
    maniobras.add(maniobra.copyWith(id: id));
    return id;
  }

  @override
  Future<List<EnsayoModel>> getEnsayos() async => [
        for (final ensayo in ensayos.reversed)
          EnsayoModel(
            id: ensayo.id,
            tolva: ensayo.tolva,
            fecha: ensayo.fecha,
            createdAt: ensayo.createdAt,
            maniobras: maniobras.where((m) => m.ensayoId == ensayo.id).toList()
              ..sort((a, b) => a.numero.compareTo(b.numero)),
          ),
      ];

  @override
  Future<int> deleteEnsayo(int id) async {
    maniobras.removeWhere((m) => m.ensayoId == id);
    final antes = ensayos.length;
    ensayos.removeWhere((e) => e.id == id);
    return antes - ensayos.length;
  }

  @override
  Future<int> deleteManiobra(int id) async {
    final antes = maniobras.length;
    maniobras.removeWhere((m) => m.id == id);
    return antes - maniobras.length;
  }

  @override
  Future<int> deleteEnsayos() async {
    final antes = ensayos.length;
    ensayos.clear();
    maniobras.clear();
    return antes;
  }
}
