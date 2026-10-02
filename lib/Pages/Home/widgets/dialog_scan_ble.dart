
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/data/ble/ble_scale_service.dart';
import 'package:flutter/material.dart';

/// Escanea dispositivos BLE y devuelve con Navigator.pop el nombre elegido.
class DialogScanBle extends StatefulWidget {

  const DialogScanBle({super.key});

  @override
  State<DialogScanBle> createState() => _DialogScanBleState();
}

class _DialogScanBleState extends State<DialogScanBle> {

  /// El escaneo se arranca una sola vez. Creado en build, cada rebuild (por
  /// ejemplo cuando un dialogo del sistema muestra y oculta las barras en modo
  /// inmersivo) arrancaba otro escaneo que volvia a pedir permisos y a pedir
  /// encender el Bluetooth, en un ciclo sin fin.
  late final Stream<List<BleDiscoveredDevice>> _scan = BleScaleService.instance.scanDevicesLive();

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
    return 'No se pudo escanear dispositivos BLE.';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Seleccionar dispositivo BLE'),
      content: SizedBox(
        width: SizeScreen.sc().screenWidth * 0.75,
        height: MediaQuery.sizeOf(context).height * 0.45,
        child: StreamBuilder<List<BleDiscoveredDevice>>(
          stream: _scan,
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
              itemBuilder: (_, index) {
                final device = devices[index];
                return ListTile(
                  leading: const Icon(Icons.bluetooth),
                  title: Text(device.displayName),
                  subtitle: Text('ID: ${device.id}'),
                  onTap: () => Navigator.of(context).pop(device.name.trim()),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }

}
