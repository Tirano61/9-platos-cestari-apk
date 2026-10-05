import 'package:flutter/material.dart';

import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/helpers/comandos_plato.dart';

/// Barra de acciones del ensayo, debajo del AppBar.
/// Por ahora solo tiene el Cero general.
class BarraEnsayo extends StatefulWidget {
  const BarraEnsayo({super.key});

  @override
  State<BarraEnsayo> createState() => _BarraEnsayoState();
}

class _BarraEnsayoState extends State<BarraEnsayo> {
  /// Mientras se manda el cero general el boton queda deshabilitado,
  /// para no abrir dos veces el socket de Conexion.cn.
  bool _enviandoCero = false;

  Future<void> _ceroGeneral() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _enviandoCero = true);

    final fallidos = await ComandosPlato.enviarCeroGeneral();

    if (mounted) setState(() => _enviandoCero = false);

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          fallidos.isEmpty
              ? 'Cero enviado a los $cantidadPlatos platos.'
              : 'No se pudo enviar cero a: ${fallidos.map(nombrePlato).join(', ')}.',
        ),
        backgroundColor: fallidos.isEmpty ? ThemePlatos.positiveColor : ThemePlatos.errorColor,
        duration: Duration(seconds: fallidos.isEmpty ? 2 : 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: const BoxDecoration(
        color: ThemeApp.colorTarjetaPesaadas,
        boxShadow: [
          BoxShadow(color: ThemeApp.shadowColor, offset: Offset(0, 1), blurRadius: 2),
        ],
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          ElevatedButton.icon(
            onPressed: _enviandoCero ? null : _ceroGeneral,
            icon: _enviandoCero
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.exposure_zero),
            label: const Text('Cero general'),
          ),
        ],
      ),
    );
  }
}
