import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:nueve_platos_cestari/Controllers/ensayo_controller.dart';
import 'package:nueve_platos_cestari/Pages/inicio_ensayo/widgets/tolva_capacidades.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/helpers/preferencias_ensayo.dart';

/// Inicio del ensayo (ruta 'inicioEnsayo'): identificacion de la tolva,
/// capacidad nominal de cada celda sobre el dibujo y umbral de alarma.
/// Las capacidades y el umbral se precargan de [PreferenciasEnsayo].
class InicioEnsayoPage extends StatefulWidget {
  const InicioEnsayoPage({super.key});

  @override
  State<InicioEnsayoPage> createState() => _InicioEnsayoPageState();
}

class _InicioEnsayoPageState extends State<InicioEnsayoPage> {
  final _tolva = TextEditingController();
  final _capacidades = [
    for (var n = 1; n <= cantidadPlatos; n++) TextEditingController(),
  ];
  final _umbral = TextEditingController();

  bool _cargando = true;
  bool _tolvaVacia = false;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  @override
  void dispose() {
    _tolva.dispose();
    for (final c in _capacidades) {
      c.dispose();
    }
    _umbral.dispose();
    super.dispose();
  }

  Future<void> _cargarPreferencias() async {
    final capacidades = await PreferenciasEnsayo.leerCapacidades();
    final umbral = await PreferenciasEnsayo.leerUmbral();
    if (!mounted) return;
    setState(() {
      for (var i = 0; i < cantidadPlatos; i++) {
        _capacidades[i].text = capacidades[i];
      }
      _umbral.text = umbral;
      _cargando = false;
    });
  }

  /// Acepta la coma como separador decimal.
  String _normalizar(String valor) => valor.trim().replaceAll(',', '.');

  Future<void> _comenzar() async {
    FocusScope.of(context).unfocus();

    final tolva = _tolva.text.trim();
    setState(() => _tolvaVacia = tolva.isEmpty);
    if (tolva.isEmpty) {
      _aviso('Ingresá la identificación de la tolva.');
      return;
    }

    final capacidades = [for (final c in _capacidades) _normalizar(c.text)];
    final invalidas = [
      for (var n = 1; n <= cantidadPlatos; n++)
        if (capacidades[n - 1].isNotEmpty &&
            (double.tryParse(capacidades[n - 1]) ?? -1) < 0)
          n,
    ];
    if (invalidas.isNotEmpty) {
      _aviso('Capacidad inválida en: ${invalidas.map(nombrePlato).join(', ')}.');
      return;
    }

    final umbral = _normalizar(_umbral.text);
    final valorUmbral = double.tryParse(umbral);
    if (valorUmbral == null || valorUmbral <= 0 || valorUmbral > 100) {
      _aviso('El umbral de alarma tiene que ser un % mayor que 0 y hasta 100.');
      return;
    }

    // Una celda sin capacidad no tiene alarma: se avisa pero se deja seguir.
    final vacias = [
      for (var n = 1; n <= cantidadPlatos; n++)
        if (capacidades[n - 1].isEmpty) n,
    ];
    if (vacias.isNotEmpty && !await _confirmarSinCapacidad(vacias)) return;

    await PreferenciasEnsayo.guardar(capacidades: capacidades, umbral: umbral);
    Get.find<EnsayoController>().iniciarEnsayo(
      tolva: tolva,
      capacidades: capacidades,
      umbral: umbral,
    );

    if (!mounted) return;
    // Reemplaza la ruta: "atras" desde los platos vuelve al Home.
    Navigator.pushReplacementNamed(context, 'platos');
  }

  Future<bool> _confirmarSinCapacidad(List<int> vacias) async {
    final seguir = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Celdas sin capacidad'),
        content: Text(
          'No tienen capacidad cargada: ${vacias.map(nombrePlato).join(', ')}.\n'
          'Esas celdas no van a tener alarma.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Seguir'),
          ),
        ],
      ),
    );
    return seguir ?? false;
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: ThemePlatos.errorColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio de ensayo')),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : _formulario(),
      ),
    );
  }

  Widget _formulario() {
    final width = SizeScreen.sc().screenWidth;
    final tablet = SizeScreen.sc().isMinWidth;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 16),
      child: Column(
        children: [
          TextField(
            controller: _tolva,
            maxLength: 40,
            textInputAction: TextInputAction.next,
            onChanged: (_) {
              if (_tolvaVacia) setState(() => _tolvaVacia = false);
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              counterText: '',
              labelText: 'Identificación de la tolva',
              errorText: _tolvaVacia ? 'Obligatorio' : null,
              errorStyle: TextStyle(color: ThemePlatos.errorColor),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Capacidad nominal de cada celda (kg)',
            style: TextStyle(
              fontSize: tablet ? 16 : 14,
              fontWeight: FontWeight.w700,
              color: ThemeApp.colorTituloPlatos,
            ),
          ),
          Text(
            'Vacío = sin alarma para esa celda',
            style: TextStyle(fontSize: tablet ? 13 : 11, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          TolvaCapacidades(capacidades: _capacidades),
          const SizedBox(height: 20),
          SizedBox(
            width: tablet ? 260 : width * 0.6,
            child: TextField(
              controller: _umbral,
              maxLength: 5,
              textAlign: TextAlign.center,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                counterText: '',
                labelText: 'Umbral de alarma (%)',
                suffixText: '%',
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _comenzar,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Comenzar ensayo'),
          ),
        ],
      ),
    );
  }
}
