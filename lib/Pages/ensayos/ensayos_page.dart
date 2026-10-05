import 'package:flutter/material.dart';

import 'package:nueve_platos_cestari/BaseDeDatos/connections/db_conexion.dart';
import 'package:nueve_platos_cestari/BaseDeDatos/services/ensayos/service_ensayos.dart';
import 'package:nueve_platos_cestari/Pages/ensayos/widgets/tarjeta_ensayo.dart';
import 'package:nueve_platos_cestari/Providers/ensayos/ensayos_provider.dart';
import 'package:nueve_platos_cestari/Widgets/botton_bar.dart';
import 'package:nueve_platos_cestari/Widgets/dialog_borrar.dart';
import 'package:nueve_platos_cestari/Widgets/icon_button_bar_widget.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/models/ensayos/ensayo_model.dart';

/// Historial de ensayos (ruta 'ensayos'): una TarjetaEnsayo por ensayo, borrar
/// uno deslizandolo y borrar todos desde la barra inferior.
class EnsayosPage extends StatefulWidget {
  const EnsayosPage({super.key, this.ensayos});

  /// Para los tests; por defecto la base real.
  final ServiceEnsayos? ensayos;

  @override
  State<EnsayosPage> createState() => _EnsayosPageState();
}

class _EnsayosPageState extends State<EnsayosPage> {
  late final EnsayosProvider _provider =
      EnsayosProvider(widget.ensayos ?? ServiceEnsayos(DBconeccion.db));

  /// Ensayos deslizados que esperan el SnackBar de confirmacion: no se dibujan.
  final _ocultos = <int>{};

  @override
  void initState() {
    super.initState();
    _provider.getEnsayos();
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ensayos'),
        centerTitle: true,
        backgroundColor: ThemeApp.colorTituloPlatos,
      ),
      body: StreamBuilder<List<EnsayoModel>>(
        stream: _provider.ensayosStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('No se pudieron leer los ensayos'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final ensayos = snapshot.data!.where((e) => !_ocultos.contains(e.id)).toList();
          if (ensayos.isEmpty) {
            return const Center(child: Text('No hay ensayos guardados'));
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(
              SizeScreen.sc().isMinWidth ? 27 : 10, 0, SizeScreen.sc().isMinWidth ? 27 : 10, 20),
            itemCount: ensayos.length,
            itemBuilder: (context, index) {
              final ensayo = ensayos[index];
              return Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Dismissible(
                  key: ValueKey(ensayo.id),
                  background: Container(
                    padding: const EdgeInsets.only(left: 20),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white, size: 30),
                  ),
                  direction: DismissDirection.startToEnd,
                  onDismissed: (_) => _confirmarBorrado(ensayo),
                  child: TarjetaEnsayo(ensayo: ensayo),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
        child: BottonBarApp(
          children: [
            IconBottonBarWidget(
              icon: Icons.delete_forever_outlined,
              iconSize: 30,
              onPressed: () {
                showDialog<bool>(
                  context: context,
                  builder: (_) => DialogBorrar(
                    titulo: 'Borrar Ensayos',
                    mensaje: 'Desea eliminar todos los ensayos guardados?',
                    onBorrar: _provider.borrarEnsayos,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// SnackBar con OK / cancel, como el de las pesadas: OK o timeout borran el
  /// ensayo, cancel lo vuelve a mostrar.
  void _confirmarBorrado(EnsayoModel ensayo) {
    final id = ensayo.id;
    if (id == null) return;
    setState(() => _ocultos.add(id));

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text('Se eliminara el ensayo ${ensayo.tolva}'),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => messenger.removeCurrentSnackBar(),
                    child: const Text('OK'),
                  ),
                  ElevatedButton(
                    onPressed: () => messenger.hideCurrentSnackBar(),
                    child: const Text('cancel'),
                  ),
                ],
              )
            ],
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        backgroundColor: ThemeApp.colorPesoPlatos,
        duration: const Duration(seconds: 5),
      ),
    ).closed.then((reason) async {
      if (reason == SnackBarClosedReason.timeout || reason == SnackBarClosedReason.remove) {
        // Sigue aunque se haya cerrado la pantalla; el provider ya no emite.
        await _provider.borrarEnsayo(id);
      }
      if (mounted) setState(() => _ocultos.remove(id));
    });
  }
}
