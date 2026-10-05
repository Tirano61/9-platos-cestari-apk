import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nueve_platos_cestari/Controllers/ensayo_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso_controller.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/helpers/comandos_plato.dart';

/// Barra de acciones del ensayo, debajo del AppBar:
/// Cero general y Tomar estatico.
class BarraEnsayo extends StatefulWidget {
  const BarraEnsayo({super.key});

  @override
  State<BarraEnsayo> createState() => _BarraEnsayoState();
}

class _BarraEnsayoState extends State<BarraEnsayo> {
  final ensayo = Get.find<EnsayoController>();

  /// Mientras se manda el cero general el boton queda deshabilitado,
  /// para no abrir dos veces el socket de Conexion.cn.
  bool _enviandoCero = false;

  Future<void> _ceroGeneral() async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _enviandoCero = true);

    final fallidos = await ComandosPlato.enviarCeroGeneral();

    if (mounted) setState(() => _enviandoCero = false);

    // Si al menos un plato hizo cero, el estatico deja de valer.
    final borrado = fallidos.length < cantidadPlatos && ensayo.borrarEstatico();
    final aviso = borrado ? ' Volvé a tomar el estático.' : '';

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          fallidos.isEmpty
              ? 'Cero enviado a los $cantidadPlatos platos.$aviso'
              : 'No se pudo enviar cero a: ${fallidos.map(nombrePlato).join(', ')}.$aviso',
        ),
        backgroundColor: fallidos.isEmpty ? ThemePlatos.positiveColor : ThemePlatos.errorColor,
        duration: Duration(seconds: fallidos.isEmpty && !borrado ? 2 : 4),
      ),
    );
  }

  Future<void> _tomarEstatico() async {
    final messenger = ScaffoldMessenger.of(context);

    final desconectados = [
      for (var n = 1; n <= cantidadPlatos; n++)
        if (!Get.find<PesoController>(tag: 'plato$n').pesoModel.conexion) n,
    ];
    if (desconectados.isNotEmpty && !await _confirmarDesconectados(desconectados)) return;

    ensayo.tomarEstatico();
    messenger.showSnackBar(
      SnackBar(
        content: const Text('Estático tomado.'),
        backgroundColor: ThemePlatos.positiveColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<bool> _confirmarDesconectados(List<int> desconectados) async {
    final seguir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Platos desconectados'),
        content: Text(
          'Sin conexión: ${desconectados.map(nombrePlato).join(', ')}.\n'
          'Su estático va a ser el último peso recibido (0 si nunca se conectaron).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Tomar igual'),
          ),
        ],
      ),
    );
    return seguir ?? false;
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
      child: Obx(() {
        // Durante una maniobra no se puede hacer cero ni retomar el estatico.
        final registrando = ensayo.estado.value == EstadoEnsayo.registrando;
        return Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ElevatedButton.icon(
              onPressed: _enviandoCero || registrando ? null : _ceroGeneral,
              icon: _enviandoCero
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.exposure_zero),
              label: const Text('Cero general'),
            ),
            ElevatedButton.icon(
              onPressed: _enviandoCero || registrando ? null : _tomarEstatico,
              icon: Icon(ensayo.hayEstatico ? Icons.check_circle : Icons.anchor),
              label: const Text('Tomar estático'),
            ),
          ],
        );
      }),
    );
  }
}
