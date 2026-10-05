import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nueve_platos_cestari/BaseDeDatos/helpers/ensayos/helpers_ensayos.dart';
import 'package:nueve_platos_cestari/Controllers/ensayo_controller.dart';
import 'package:nueve_platos_cestari/Controllers/peso_controller.dart';
import 'package:nueve_platos_cestari/Pages/nueve_platos/widgets/dialog_maniobra.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/helpers/comandos_plato.dart';

/// Barra de acciones del ensayo, debajo del AppBar:
/// Cero general, Tomar estatico y Registrar / Terminar maniobra.
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

  void _registrarManiobra() => ensayo.iniciarManiobra();

  /// Corta el registro, guarda la maniobra y muestra el resultado.
  Future<void> _terminarManiobra() async {
    final messenger = ScaffoldMessenger.of(context);
    final maniobra = await ensayo.terminarManiobra();
    if (maniobra == null) return;
    HelpersEnsayos.avisarGuardado(messenger, maniobra);
    if (!mounted) return;
    await mostrarResultadoManiobra(context, maniobra: maniobra);
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
        final estado = ensayo.estado.value;
        final registrando = estado == EstadoEnsayo.registrando;
        final inicio = ensayo.inicioManiobra.value;
        return Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
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
            // Solo con el estatico tomado; mientras corre pasa a Terminar.
            registrando
                ? ElevatedButton.icon(
                    onPressed: _terminarManiobra,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ThemePlatos.errorColor,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.stop),
                    label: const Text('Terminar maniobra'),
                  )
                : ElevatedButton.icon(
                    onPressed: _enviandoCero || estado != EstadoEnsayo.listo ? null : _registrarManiobra,
                    icon: const Icon(Icons.fiber_manual_record),
                    label: const Text('Registrar maniobra'),
                  ),
            if (registrando && inicio != null)
              _Cronometro(numero: ensayo.numeroManiobra.value, inicio: inicio),
          ],
        );
      }),
    );
  }
}

/// Numero de maniobra y tiempo transcurrido desde [inicio], cada 1 s.
class _Cronometro extends StatefulWidget {
  const _Cronometro({required this.numero, required this.inicio});

  final int numero;
  final DateTime inicio;

  @override
  State<_Cronometro> createState() => _CronometroState();
}

class _CronometroState extends State<_Cronometro> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.timer_outlined, size: 18, color: Colors.red),
        const SizedBox(width: 4),
        Text(
          'Maniobra ${widget.numero} · ${formatoDuracion(DateTime.now().difference(widget.inicio))}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
