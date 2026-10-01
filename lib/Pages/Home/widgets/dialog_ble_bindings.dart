import 'package:cuatro_platos/BaseDeDatos/connections/db_conexion.dart';
import 'package:cuatro_platos/BaseDeDatos/services/settings/service_config.dart';
import 'package:cuatro_platos/Controllers/config_controller.dart';
import 'package:cuatro_platos/Theme/theme.dart';
import 'package:cuatro_platos/data/ble/ble_scale_service.dart';
import 'package:cuatro_platos/models/config_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogBleBindings extends StatefulWidget {
  const DialogBleBindings({super.key});

  @override
  State<DialogBleBindings> createState() => _DialogBleBindingsState();
}

class _DialogBleBindingsState extends State<DialogBleBindings> {
  final ConfigController _config = Get.find<ConfigController>();

  late String _ble1;
  late String _ble2;
  late String _ble3;
  late String _ble4;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _ble1 = _config.getPlato1BleName.value;
    _ble2 = _config.getPlato2BleName.value;
    _ble3 = _config.getPlato3BleName.value;
    _ble4 = _config.getPlato4BleName.value;
  }

  bool get _isComplete {
    return _ble1.trim().isNotEmpty &&
        _ble2.trim().isNotEmpty &&
        _ble3.trim().isNotEmpty &&
        _ble4.trim().isNotEmpty;
  }

  Future<void> _scanAndSelect(int plato) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Seleccionar BLE Plato $plato'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.75,
          height: MediaQuery.of(context).size.height * 0.45,
          child: StreamBuilder<List<BleDiscoveredDevice>>(
            stream: BleScaleService.instance.scanDevicesLive(),
            initialData: const [],
            builder: (_, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    _buildBleErrorMessage(snapshot.error),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final devices = (snapshot.data ?? const [])
                  .where((d) => d.name.trim().isNotEmpty)
                  .toList();

              if (devices.isEmpty && snapshot.connectionState == ConnectionState.done) {
                return const Center(
                  child: Text(
                    'No se encontraron dispositivos BLE con nombre.\n\n'
                    'Verifique que esten encendidos y visibles, y vuelva a intentar.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              if (devices.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 10),
                      Text('Escaneando dispositivos...'),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: devices.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final device = devices[i];
                  return ListTile(
                    leading: const Icon(Icons.bluetooth),
                    title: Text(device.displayName),
                    subtitle: Text('ID: ${device.id}'),
                    onTap: () => Navigator.of(ctx).pop(device.name.trim()),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );

    if (selected == null || selected.trim().isEmpty) return;

    setState(() {
      switch (plato) {
        case 1:
          _ble1 = selected.trim();
          break;
        case 2:
          _ble2 = selected.trim();
          break;
        case 3:
          _ble3 = selected.trim();
          break;
        case 4:
          _ble4 = selected.trim();
          break;
      }
    });
  }

  String _buildBleErrorMessage(Object? error) {
    if (error is StateError) {
      if (error.message == 'ble_permissions_denied') {
        return 'Permisos Bluetooth denegados. Habilitelos para escanear.';
      }
      if (error.message == 'ble_permissions_permanently_denied') {
        return 'Permisos Bluetooth bloqueados permanentemente. Habilitelos en Ajustes de la app.';
      }
      if (error.message == 'ble_adapter_off') {
        return 'Bluetooth esta apagado. Enciendalo y vuelva a intentar.';
      }
      if (error.message == 'ble_not_supported') {
        return 'Este dispositivo no soporta Bluetooth LE.';
      }
    }
    return 'No se pudo escanear BLE.';
  }

  Future<void> _saveAndContinue() async {
    if (!_isComplete || _saving) return;

    setState(() => _saving = true);

    final config = ConfigModel(
      plato1: _config.getPuerto1.value,
      plato2: _config.getPuerto2.value,
      plato3: _config.getPuerto3.value,
      plato4: _config.getPuerto4.value,
      connectionType: ConnectionType.ble,
      plato1BleName: _ble1.trim(),
      plato2BleName: _ble2.trim(),
      plato3BleName: _ble3.trim(),
      plato4BleName: _ble4.trim(),
    );

    final service = ServiceConfig(DBconeccion.db);
    final resp = await service.upDateConfig(config);
    if (resp == -1) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo guardar la vinculación BLE.'),
          backgroundColor: ThemePlatos.errorColor,
        ),
      );
      return;
    }

    _config.setConnectionType(ConnectionType.ble);
    _config.setPlato1BleName(_ble1.trim());
    _config.setPlato2BleName(_ble2.trim());
    _config.setPlato3BleName(_ble3.trim());
    _config.setPlato4BleName(_ble4.trim());

    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Widget _rowPlato(int plato, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: ThemePlatos.backgroundPeso,
        child: Text('$plato'),
      ),
      title: Text('Plato $plato'),
      subtitle: Text(
        value.trim().isEmpty ? 'Sin vincular' : value,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        tooltip: 'Escanear',
        icon: const Icon(Icons.bluetooth_searching),
        onPressed: _saving ? null : () => _scanAndSelect(plato),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Vincular Bluetooth por Plato'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Escanee y seleccione un dispositivo BLE para cada plato.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            _rowPlato(1, _ble1),
            _rowPlato(2, _ble2),
            _rowPlato(3, _ble3),
            _rowPlato(4, _ble4),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isComplete ? _saveAndContinue : null,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Continuar'),
        ),
      ],
    );
  }
}
