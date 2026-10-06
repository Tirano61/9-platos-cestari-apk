import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nueve_platos_cestari/Providers/calibracion_wifi.dart';
import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/config/platos.dart';
import 'package:nueve_platos_cestari/config/theme.dart';
import 'package:nueve_platos_cestari/helpers/comandos_plato.dart';
import 'package:nueve_platos_cestari/models/calibracion/calibracion_model.dart';

/// Un campo editable del formulario. [clave] es el parametro de `/save`.
class _Campo {
  const _Campo(this.clave, this.etiqueta, {required this.decimal, required this.valor});

  final String clave;
  final String etiqueta;
  final bool decimal;
  final num? Function(CalibracionModel c) valor;
}

/// Los 10 campos que se envian, en el orden de `/save`.
final _campos = <_Campo>[
  _Campo('celdas', 'Total de celdas', decimal: false, valor: (c) => c.totalCelda),
  _Campo('sensibilidad', 'Sensibilidad', decimal: false, valor: (c) => c.sensibilidad),
  _Campo('division', 'División', decimal: true, valor: (c) => c.division),
  _Campo('conversiones', 'Conversiones', decimal: false, valor: (c) => c.conversiones),
  _Campo('recortes', 'Recortes', decimal: false, valor: (c) => c.recortes),
  _Campo('ventanam', 'Ventana móvil', decimal: false, valor: (c) => c.ventanaMovil),
  _Campo('gkfiltro', 'Kg filtro', decimal: false, valor: (c) => c.kgFiltro),
  _Campo('correccion', 'Corrección', decimal: true, valor: (c) => c.correccion),
  _Campo('tiempoestable', 'Tiempo estable', decimal: false, valor: (c) => c.tiempoEstable),
  _Campo('resethold', 'Kg reset hold', decimal: true, valor: (c) => c.kgResetHold),
];

/// Calibracion de un plato por WiFi (ruta 'calibracion', el numero de plato va
/// en los `arguments`): lee la calibracion del indicador, deja editarla y la
/// envia. Los tests inyectan [servicio] e [ipPlato].
class CalibracionPage extends StatefulWidget {
  const CalibracionPage({super.key, required this.plato, this.servicio, this.ipPlato});

  final int plato;
  final CalibracionWifi? servicio;

  /// IP del plato o null si todavia no mando datos. Por defecto
  /// [ComandosPlato.ipPlato].
  final String? Function(int plato)? ipPlato;

  @override
  State<CalibracionPage> createState() => _CalibracionPageState();
}

class _CalibracionPageState extends State<CalibracionPage> {
  late final CalibracionWifi _servicio = widget.servicio ?? CalibracionWifi();
  final _controllers = {for (final campo in _campos) campo.clave: TextEditingController()};
  final _capacidadMaxima = TextEditingController();

  String? _ip;
  CalibracionModel? _leida;
  bool _cargando = true;
  bool _errorLectura = false;
  bool _enviando = false;
  Set<String> _invalidos = {};

  @override
  void initState() {
    super.initState();
    _leer();
  }

  @override
  void dispose() {
    // El servicio inyectado lo cierra quien lo creo.
    if (widget.servicio == null) _servicio.cerrar();
    for (final c in _controllers.values) {
      c.dispose();
    }
    _capacidadMaxima.dispose();
    super.dispose();
  }

  Future<void> _leer() async {
    final ip = (widget.ipPlato ?? ComandosPlato.ipPlato)(widget.plato);
    setState(() {
      _ip = ip;
      _cargando = ip != null;
      _errorLectura = false;
    });
    if (ip == null) return;

    final calibracion = await _servicio.leer(ip);
    if (!mounted) return;
    setState(() {
      _cargando = false;
      _errorLectura = calibracion == null;
      if (calibracion == null) return;
      _leida = calibracion;
      _invalidos = {};
      for (final campo in _campos) {
        _controllers[campo.clave]!.text = _texto(campo.valor(calibracion));
      }
      _capacidadMaxima.text = _texto(calibracion.capacidadMaxima);
    });
  }

  /// Un campo que el firmware no mando queda vacio.
  String _texto(num? valor) => valor == null ? '' : '$valor';

  /// Acepta la coma como separador decimal.
  String _normalizar(String valor) => valor.trim().replaceAll(',', '.');

  num? _valor(_Campo campo) {
    final texto = _normalizar(_controllers[campo.clave]!.text);
    if (!campo.decimal) return int.tryParse(texto);
    final valor = double.tryParse(texto);
    return valor != null && valor.isFinite ? valor : null;
  }

  /// El modelo con lo que hay en el formulario. null (y los campos vacios o
  /// invalidos marcados) si falta alguno.
  CalibracionModel? _calibracionEditada() {
    final valores = {for (final campo in _campos) campo.clave: _valor(campo)};
    setState(() => _invalidos = {
          for (final e in valores.entries)
            if (e.value == null) e.key,
        });
    if (_invalidos.isNotEmpty) return null;

    return CalibracionModel(
      firmware: _leida!.firmware,
      totalCelda: valores['celdas'] as int,
      sensibilidad: valores['sensibilidad'] as int,
      division: valores['division'] as double,
      conversiones: valores['conversiones'] as int,
      recortes: valores['recortes'] as int,
      ventanaMovil: valores['ventanam'] as int,
      kgFiltro: valores['gkfiltro'] as int,
      correccion: valores['correccion'] as double,
      tiempoEstable: valores['tiempoestable'] as int,
      kgResetHold: valores['resethold'] as double,
      capacidadMaxima: _leida!.capacidadMaxima,
    );
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();

    final calibracion = _calibracionEditada();
    if (calibracion == null) {
      final etiquetas = [
        for (final campo in _campos)
          if (_invalidos.contains(campo.clave)) campo.etiqueta,
      ];
      _aviso('Revisá los campos: ${etiquetas.join(', ')}.', error: true);
      return;
    }
    if (!await _confirmarEnvio()) return;

    setState(() => _enviando = true);
    final enviado = await _servicio.enviar(_ip!, calibracion);
    if (!mounted) return;
    setState(() => _enviando = false);
    _aviso(
      enviado
          ? 'Calibración enviada. El indicador se reinicia.'
          : 'No se pudo enviar la calibración.',
      error: !enviado,
    );

    // Con exito o con error, se muestra lo que realmente quedo en el equipo.
    await _leer();
  }

  Future<bool> _confirmarEnvio() async {
    final enviar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enviar calibración'),
        content: Text(
          'Se va a guardar la calibración en ${nombrePlato(widget.plato)}.\n'
          'El indicador se va a reiniciar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
    return enviar ?? false;
  }

  void _aviso(String texto, {required bool error}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? ThemePlatos.errorColor : ThemePlatos.positiveColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text('Calibración ${nombrePlato(widget.plato)}'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_ip != null) _encabezado(),
            Expanded(child: _contenido()),
          ],
        ),
      ),
    );
  }

  Widget _encabezado() {
    final firmware = switch (_leida?.firmware) {
      FirmwareCalibracion.clasico => ' · Firmware clásico',
      FirmwareCalibracion.esp32 => ' · Firmware ESP32',
      null => '',
    };
    return Container(
      width: double.infinity,
      color: ThemeApp.colorTarjetaPesaadas,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'IP: $_ip$firmware',
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.w600, color: ThemeApp.colorTituloPlatos),
      ),
    );
  }

  Widget _contenido() {
    if (_ip == null) {
      return _mensaje(
        icono: Icons.wifi_off,
        texto: 'El plato todavía no mandó datos: no se conoce su IP.',
        boton: 'Reintentar',
      );
    }
    if (_cargando) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Leyendo la calibración...'),
          ],
        ),
      );
    }
    if (_errorLectura) {
      return _mensaje(
        icono: Icons.error_outline,
        texto: 'No se pudo leer la calibración del plato.',
        boton: 'Leer de nuevo',
      );
    }
    return _formulario();
  }

  Widget _mensaje({required IconData icono, required String texto, required String boton}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 48, color: ThemePlatos.errorColor),
            const SizedBox(height: 12),
            Text(texto, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _leer,
              icon: const Icon(Icons.refresh),
              label: Text(boton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formulario() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final campo in _campos) ...[
                _campoEditable(campo),
                const SizedBox(height: 12),
              ],
              TextField(
                key: const ValueKey('campo_capacidad_maxima'),
                controller: _capacidadMaxima,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                  filled: true,
                  fillColor: ThemeApp.colorTarjetaPesaadas,
                  labelText: 'Capacidad máxima (solo lectura)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _enviando ? null : _enviar,
                icon: _enviando
                    ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send),
                label: const Text('Enviar calibración'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _enviando ? null : _leer,
                icon: const Icon(Icons.refresh),
                label: const Text('Leer de nuevo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoEditable(_Campo campo) {
    final invalido = _invalidos.contains(campo.clave);
    return TextField(
      key: ValueKey('campo_${campo.clave}'),
      controller: _controllers[campo.clave],
      enabled: !_enviando,
      maxLength: 12,
      keyboardType: TextInputType.numberWithOptions(decimal: campo.decimal),
      inputFormatters: [
        campo.decimal
            ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))
            : FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (_) {
        if (invalido) setState(() => _invalidos = {..._invalidos}..remove(campo.clave));
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        counterText: '',
        labelText: campo.etiqueta,
        errorText: invalido ? 'Valor inválido' : null,
        errorStyle: TextStyle(color: ThemePlatos.errorColor),
      ),
    );
  }
}
