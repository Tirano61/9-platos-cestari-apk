import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cuatro_platos/BaseDeDatos/helpers/settings/helpers_config.dart';
import 'package:cuatro_platos/data/ble/ble_scale_parser.dart';
import 'package:cuatro_platos/domain/entities/scale_reading.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class BleDiscoveredDevice {
  final String id;
  final String name;

  const BleDiscoveredDevice({
    required this.id,
    required this.name,
  });

  String get displayName => name.isEmpty ? '(Sin nombre)' : name;
}

class _IntentoConexion {
  final String nombre;
  final Future<void> future;

  const _IntentoConexion(this.nombre, this.future);
}

class BleScaleService {
  BleScaleService._();

  static final BleScaleService instance = BleScaleService._();

  static final Guid serviceNotifyUuid = Guid('0000ABF0-0000-1000-8000-00805F9B34FB');
  static final Guid characteristicNotifyUuid = Guid('0000ABF1-0000-1000-8000-00805F9B34FB');
  static final Guid serviceWriteUuid = Guid('0000ABF6-0000-1000-8000-00805F9B34FB');
  static final Guid characteristicWriteUuid = Guid('0000ABF2-0000-1000-8000-00805F9B34FB');

  static const String comandoCero = 'AT+CERO\r\n';
  static const String comandoResetHold = 'AT+RSTHOLD\r\n';

  final BleScaleParser _parser = const BleScaleParser();

  final Map<int, BluetoothDevice> _deviceByPlato = {};
  final Map<int, StreamSubscription<List<int>>> _notifySubs = {};
  final Map<int, BluetoothCharacteristic> _writeCharByPlato = {};
  final Map<String, BluetoothDevice> _knownDevicesByKey = {};

  /// Sesion por plato: startListening y stopListening la incrementan. Un intento
  /// de conexion cuya sesion ya no es la actual (se cambio el nombre o se paso
  /// a WiFi mientras conectaba) se descarta sin suscribirse ni tocar la config.
  final Map<int, int> _sesionPorPlato = {};
  final Map<int, _IntentoConexion> _intentosEnCurso = {};

  /// Turno global: se busca y conecta un plato a la vez. Si los 4 platos
  /// escanean juntos, cada startScan corta el escaneo de los otros y algunos
  /// platos nunca se encuentran.
  Future<void> _colaConexion = Future.value();

  Future<String>? _permisosEnCurso;

  /// La conexion automatica pide los permisos una sola vez por sesion; despues
  /// solo consulta el estado. Si no, con los permisos denegados el timer de
  /// reconexion mostraba el dialogo del sistema cada 5 s.
  bool _permisosPedidosAlConectar = false;

  /// Escaneo compartido: el selector de la configuracion y la reconexion
  /// automatica usan el mismo escaneo en lugar de reiniciarlo o cortarlo.
  int _usuariosEscaneo = 0;

  /// Android deja de entregar resultados (sin avisar) si la app arranca mas de
  /// 5 escaneos en 30 s. La reconexion automatica no escanea si ya se llego a
  /// [_maxEscaneosAutomaticos]; el timer del controller vuelve a intentar.
  final List<DateTime> _iniciosEscaneo = [];
  static const int _maxEscaneosAutomaticos = 4;
  static const Duration _ventanaEscaneos = Duration(seconds: 30);
  static const Duration _duracionBusqueda = Duration(seconds: 5);

  static const _permissionGranted = 'granted';
  static const _permissionDenied = 'denied';
  static const _permissionPermanentlyDenied = 'permanently_denied';

  void _cacheDevice(BluetoothDevice device, {String? fallbackName}) {
    final keys = [
      device.remoteId.str,
      device.platformName,
      device.advName,
      fallbackName ?? '',
    ];
    for (final key in keys) {
      final normalized = key.trim().toLowerCase();
      if (normalized.isNotEmpty) {
        _knownDevicesByKey[normalized] = device;
      }
    }
  }

  BluetoothDevice? _getCachedDevice(String preferredName) {
    final key = preferredName.trim().toLowerCase();
    if (key.isEmpty) return null;
    return _knownDevicesByKey[key];
  }

  /// Saca el dispositivo del cache para que el proximo intento lo busque de
  /// nuevo escaneando (apagado, fuera de alcance o con otra direccion).
  void _olvidarDispositivo(BluetoothDevice device) {
    _knownDevicesByKey.removeWhere((_, cached) => cached == device);
  }

  bool _coincideNombre(String preferredName, List<String> candidatos) {
    final buscado = preferredName.trim().toLowerCase();
    return candidatos.any((c) => c.trim().isNotEmpty && c.trim().toLowerCase() == buscado);
  }

  bool _deviceCoincide(BluetoothDevice device, String preferredName) {
    return _coincideNombre(preferredName, [
      device.remoteId.str,
      device.platformName,
      device.advName,
    ]);
  }

  int _nuevaSesion(int plato) {
    final sesion = (_sesionPorPlato[plato] ?? 0) + 1;
    _sesionPorPlato[plato] = sesion;
    return sesion;
  }

  /// Espera el turno global de conexion. Devuelve la funcion que lo libera.
  Future<void Function()> _esperarTurno() async {
    final anterior = _colaConexion;
    final turno = Completer<void>();
    _colaConexion = turno.future;
    await anterior;
    return turno.complete;
  }

  /// Un solo pedido de permisos a la vez: permission_handler falla si se piden
  /// mientras hay otro pedido abierto. Una consulta con un pedido en curso
  /// espera su respuesta.
  Future<String> _permisosCompartidos({required bool pedir}) {
    final enCurso = _permisosEnCurso;
    if (enCurso != null) return enCurso;
    if (!pedir) return _ensureBlePermissions(pedir: false);

    return _permisosEnCurso = _ensureBlePermissions(pedir: true).whenComplete(() => _permisosEnCurso = null);
  }

  bool _hayCupoEscaneoAutomatico() {
    final ahora = DateTime.now();
    _iniciosEscaneo.removeWhere((t) => ahora.difference(t) >= _ventanaEscaneos);
    return _iniciosEscaneo.length < _maxEscaneosAutomaticos;
  }

  /// Arranca el escaneo o se suma al que ya esta en curso. Cada llamada debe
  /// cerrarse con [_liberarEscaneo].
  Future<void> _tomarEscaneo() async {
    _usuariosEscaneo++;
    final checkLocation = await _shouldCheckLocationServices();
    if (FlutterBluePlus.isScanningNow) return;

    _iniciosEscaneo.add(DateTime.now());
    await FlutterBluePlus.startScan(androidCheckLocationServices: checkLocation);
  }

  Future<void> _liberarEscaneo() async {
    if (_usuariosEscaneo > 0) _usuariosEscaneo--;
    if (_usuariosEscaneo == 0 && FlutterBluePlus.isScanningNow) {
      await FlutterBluePlus.stopScan();
    }
  }

  Future<bool> _adaptadorEncendido() async {
    try {
      final estado = await FlutterBluePlus.adapterState.first.timeout(const Duration(seconds: 3));
      return estado == BluetoothAdapterState.on;
    } catch (_) {
      return false;
    }
  }

  BleDiscoveredDevice _fromScanResult(ScanResult result) {
    final platform = result.device.platformName.trim();
    final adv = result.advertisementData.advName.trim();

    return BleDiscoveredDevice(
      id: result.device.remoteId.str,
      name: platform.isNotEmpty ? platform : adv,
    );
  }

  BleDiscoveredDevice _fromDevice(BluetoothDevice device) {
    return BleDiscoveredDevice(
      id: device.remoteId.str,
      name: device.platformName.trim(),
    );
  }

  List<BleDiscoveredDevice> _sortedDevices(Map<String, BleDiscoveredDevice> devicesById) {
    final list = devicesById.values.toList();
    list.sort((a, b) {
      final byName = a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
      if (byName != 0) return byName;
      return a.id.toLowerCase().compareTo(b.id.toLowerCase());
    });
    return list;
  }

  /// Pide permisos y, si el Bluetooth esta apagado, pide encenderlo: llamarlo
  /// solo por una accion del usuario. Si se deja de escuchar el stream (se
  /// cerro el dialogo) se corta el escaneo.
  Stream<List<BleDiscoveredDevice>> scanDevicesLive({Duration timeout = const Duration(seconds: 8)}) {
    final cancelado = Completer<void>();
    final controller = StreamController<List<BleDiscoveredDevice>>(
      onCancel: () {
        if (!cancelado.isCompleted) cancelado.complete();
      },
    );
    StreamSubscription<List<ScanResult>>? sub;
    var escaneoTomado = false;
    final devicesById = <String, BleDiscoveredDevice>{};

    Future<void> emitCurrent() async {
      if (!controller.isClosed) {
        controller.add(_sortedDevices(devicesById));
      }
    }

    Future<void> run() async {
      try {
        final isSupported = await FlutterBluePlus.isSupported;
        if (!isSupported) {
          throw StateError('ble_not_supported');
        }

        final permissionState = await _permisosCompartidos(pedir: true);
        if (cancelado.isCompleted) return;
        if (permissionState != _permissionGranted) {
          throw StateError(
            permissionState == _permissionPermanentlyDenied
                ? 'ble_permissions_permanently_denied'
                : 'ble_permissions_denied',
          );
        }

        var adapterState = await FlutterBluePlus.adapterState.first;
        if (adapterState != BluetoothAdapterState.on && Platform.isAndroid) {
          try {
            // turnOn espera a que el usuario responda el dialogo del sistema.
            // Con 8 s saltaba el timeout antes de que llegara a tocar Permitir.
            await FlutterBluePlus.turnOn(timeout: 60);
          } catch (_) {
            // Rechazado o sin respuesta: se evalua el estado igual.
          }
          if (cancelado.isCompleted) return;
          adapterState = await FlutterBluePlus.adapterState.first;
        }

        if (adapterState != BluetoothAdapterState.on) {
          throw StateError('ble_adapter_off');
        }

        try {
          final bonded = await FlutterBluePlus.bondedDevices;
          for (final device in bonded) {
            devicesById[device.remoteId.str] = _fromDevice(device);
            _cacheDevice(device);
          }
        } catch (_) {
          // Continue scan even if bonded device query is not available.
        }

        try {
          final system = await FlutterBluePlus.systemDevices(const []);
          for (final device in system) {
            devicesById[device.remoteId.str] = _fromDevice(device);
            _cacheDevice(device);
          }
        } catch (_) {
          // Continue scan even if system device query is not available.
        }

        await emitCurrent();

        sub = FlutterBluePlus.onScanResults.listen((results) {
          var changed = false;
          for (final result in results) {
            final discovered = _fromScanResult(result);
            final current = devicesById[discovered.id];
            final shouldUpdate = current == null || (current.name.isEmpty && discovered.name.isNotEmpty);

            if (shouldUpdate) {
              devicesById[discovered.id] = discovered;
              _cacheDevice(result.device, fallbackName: discovered.name);
              changed = true;
            }
          }

          if (changed && !controller.isClosed) {
            controller.add(_sortedDevices(devicesById));
          }
        });

        if (cancelado.isCompleted) return;

        // Si la reconexion automatica esta escaneando, se aprovecha ese escaneo
        // en lugar de reiniciarlo.
        escaneoTomado = true;
        await _tomarEscaneo();

        await Future.any([Future<void>.delayed(timeout), cancelado.future]);
      } catch (e, st) {
        if (!controller.isClosed) {
          controller.addError(e, st);
        }
      } finally {
        if (escaneoTomado) {
          await _liberarEscaneo();
        }
        await sub?.cancel();
        if (!controller.isClosed) {
          await controller.close();
        }
      }
    }

    unawaited(run());
    return controller.stream;
  }

  Future<List<String>> scanDeviceNames({Duration timeout = const Duration(seconds: 8)}) async {
    final devices = await scanDevicesLive(timeout: timeout).last;
    return devices.map((d) => d.name.isNotEmpty ? d.name : d.id).toList();
  }

  /// Conecta el plato al dispositivo BLE con ese nombre y entrega sus lecturas.
  /// Nunca lanza excepciones: si no se pudo conectar, el timer del controller
  /// vuelve a llamarlo.
  Future<void> startListening({
    required int plato,
    required String preferredName,
    required void Function(ScaleReading reading) onReading,
  }) {
    final normalized = preferredName.trim();
    if (normalized.isEmpty) {
      return stopListening(plato);
    }

    // El arranque, el timer de reconexion y el OK de la configuracion pueden
    // pedir el mismo plato a la vez: se reutiliza el intento en curso.
    final enCurso = _intentosEnCurso[plato];
    if (enCurso != null && enCurso.nombre == normalized) {
      return enCurso.future;
    }

    final sesion = _nuevaSesion(plato);
    final future = _conectarYEscuchar(
      plato: plato,
      preferredName: normalized,
      sesion: sesion,
      onReading: onReading,
    );
    final intento = _IntentoConexion(normalized, future);
    _intentosEnCurso[plato] = intento;
    unawaited(future.whenComplete(() {
      if (identical(_intentosEnCurso[plato], intento)) {
        _intentosEnCurso.remove(plato);
      }
    }));
    return future;
  }

  Future<void> _conectarYEscuchar({
    required int plato,
    required String preferredName,
    required int sesion,
    required void Function(ScaleReading reading) onReading,
  }) async {
    bool vigente() => _sesionPorPlato[plato] == sesion;
    void log(String msg) => debugPrint('BLE plato $plato ($preferredName): $msg');

    void Function()? liberarTurno;
    BluetoothDevice? device;

    try {
      final pedir = !_permisosPedidosAlConectar;
      _permisosPedidosAlConectar = true;
      final permissionState = await _permisosCompartidos(pedir: pedir);
      if (permissionState != _permissionGranted) {
        log('sin permisos ($permissionState)');
        return;
      }
      if (!vigente()) return;

      // Corta la conexion anterior del plato antes de buscar de nuevo.
      await _liberarPlato(plato);

      liberarTurno = await _esperarTurno();
      if (!vigente()) return;
      if (!await _adaptadorEncendido()) {
        log('Bluetooth apagado');
        return;
      }

      log('buscando');
      device = await _findDeviceByName(preferredName);
      if (device == null) {
        log('no encontrado');
        return;
      }
      if (!vigente()) return;
      log('encontrado ${device.remoteId.str}, conectando');

      _cacheDevice(device, fallbackName: preferredName);

      try {
        await _connectIfNeeded(device);
      } catch (e) {
        log('fallo la conexion: $e');
        _olvidarDispositivo(device);
        rethrow;
      }
      if (!vigente()) return;

      final services = await device.discoverServices();
      final characteristic = _findCharacteristic(services, serviceNotifyUuid, characteristicNotifyUuid);
      if (characteristic == null) {
        log('no tiene $serviceNotifyUuid/$characteristicNotifyUuid. Servicios: '
            '${services.map((sv) => '${sv.uuid}[${sv.characteristics.map((c) => c.uuid).join(',')}]').join(' ')}');
        return;
      }
      if (!vigente()) return;

      await characteristic.setNotifyValue(true);
      if (!vigente()) return;

      final currentName = device.platformName.trim().isEmpty ? preferredName : device.platformName.trim();

      _deviceByPlato[plato] = device;
      final writeCharacteristic = _findCharacteristic(services, serviceWriteUuid, characteristicWriteUuid);
      if (writeCharacteristic != null) {
        _writeCharByPlato[plato] = writeCharacteristic;
      }
      // onValueReceived y no lastValueStream: este ultimo reemite al suscribirse
      // el ultimo valor recibido y marcaria el plato conectado con un peso viejo.
      _notifySubs[plato] = characteristic.onValueReceived.listen((bytes) {
        final reading = _parser.parse(rawData: bytes, sourceId: currentName);
        if (reading != null) {
          onReading(reading);
        } else {
          log('dato descartado: "${String.fromCharCodes(bytes)}"');
        }
      });
      log('conectado, notify activo');

      await HelpersConfig.guardarNombreBlePrimerVinculo(plato: plato, bleName: currentName);
    } catch (e) {
      // Sin conexion: el controller marca el plato desconectado y reintenta.
      log('error: $e');
    } finally {
      // Si se conecto pero el intento fallo o quedo viejo, no dejar la conexion
      // abierta: el dispositivo no vuelve a anunciarse mientras este conectado.
      if (device != null && _deviceByPlato[plato] != device) {
        await _desconectarSiNoSeUsa(device);
      }
      liberarTurno?.call();
    }
  }

  /// Envia `AT+CERO` al plato por la caracteristica de escritura BLE.
  /// Devuelve false si el plato no esta conectado por BLE o la escritura falla.
  Future<bool> enviarCero(int plato) => _enviarComando(plato, comandoCero);

  /// Envia `AT+RSTHOLD` al plato por la caracteristica de escritura BLE.
  /// Devuelve false si el plato no esta conectado por BLE o la escritura falla.
  Future<bool> enviarResetHold(int plato) => _enviarComando(plato, comandoResetHold);

  Future<bool> _enviarComando(int plato, String comando) async {
    final device = _deviceByPlato[plato];
    if (device == null || !device.isConnected) return false;

    final characteristic = _writeCharByPlato[plato] ??
        _findCharacteristic(device.servicesList, serviceWriteUuid, characteristicWriteUuid);
    if (characteristic == null) return false;
    _writeCharByPlato[plato] = characteristic;

    final properties = characteristic.properties;
    final withoutResponse = !properties.write && properties.writeWithoutResponse;

    try {
      await characteristic.write(
        utf8.encode(comando),
        withoutResponse: withoutResponse,
        timeout: 5,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> stopListening(int plato) async {
    // Invalida cualquier intento de conexion en curso para este plato.
    _nuevaSesion(plato);
    _intentosEnCurso.remove(plato);
    await _liberarPlato(plato);
  }

  Future<void> _liberarPlato(int plato) async {
    await _notifySubs.remove(plato)?.cancel();
    _writeCharByPlato.remove(plato);

    final device = _deviceByPlato.remove(plato);
    if (device != null) {
      await _desconectarSiNoSeUsa(device);
    }
  }

  Future<void> _desconectarSiNoSeUsa(BluetoothDevice device) async {
    if (_deviceByPlato.containsValue(device)) return;
    try {
      await device.disconnect();
    } catch (_) {
      // Ignore disconnect errors to keep teardown resilient.
    }
  }

  Future<BluetoothDevice?> _findDeviceByName(String preferredName) async {
    final cached = _getCachedDevice(preferredName);
    if (cached != null) {
      return cached;
    }

    for (final connected in FlutterBluePlus.connectedDevices) {
      _cacheDevice(connected);
      if (_deviceCoincide(connected, preferredName)) {
        return connected;
      }
    }

    try {
      final bonded = await FlutterBluePlus.bondedDevices;
      for (final device in bonded) {
        _cacheDevice(device);
        if (_deviceCoincide(device, preferredName)) {
          return device;
        }
      }
    } catch (_) {}

    try {
      final system = await FlutterBluePlus.systemDevices(const []);
      for (final device in system) {
        _cacheDevice(device);
        if (_deviceCoincide(device, preferredName)) {
          return device;
        }
      }
    } catch (_) {}

    // Sin cupo de escaneos se espera al proximo intento; un escaneo bloqueado
    // por Android no devuelve resultados y solo alarga el bloqueo.
    if (!FlutterBluePlus.isScanningNow && !_hayCupoEscaneoAutomatico()) {
      return null;
    }

    final completer = Completer<BluetoothDevice?>();

    // Se cachean todos los dispositivos vistos: si aparecen los de otros platos,
    // sus intentos los encuentran en cache sin volver a escanear.
    final sub = FlutterBluePlus.onScanResults.listen(
      (results) {
        for (final result in results) {
          final advName = result.advertisementData.advName;
          _cacheDevice(result.device, fallbackName: advName);

          final coincide = _coincideNombre(preferredName, [
            result.device.remoteId.str,
            result.device.platformName,
            advName,
          ]);
          if (coincide && !completer.isCompleted) {
            completer.complete(result.device);
          }
        }
      },
      onError: (_) {},
    );

    try {
      await _tomarEscaneo();
      return await completer.future.timeout(
        _duracionBusqueda,
        onTimeout: () => null,
      );
    } finally {
      await _liberarEscaneo();
      await sub.cancel();
    }
  }

  Future<void> _connectIfNeeded(BluetoothDevice device) async {
    try {
      if (device.isConnected) return;
      await device.connect(timeout: const Duration(seconds: 10));
    } catch (_) {
      if (!device.isConnected) rethrow;
    }
  }

  BluetoothCharacteristic? _findCharacteristic(
    List<BluetoothService> services,
    Guid serviceUuid,
    Guid characteristicUuid,
  ) {
    for (final service in services) {
      if (service.uuid != serviceUuid) continue;
      for (final characteristic in service.characteristics) {
        if (characteristic.uuid == characteristicUuid) {
          return characteristic;
        }
      }
    }

    return null;
  }

  /// Con [pedir] en false solo consulta el estado, sin mostrar el dialogo del
  /// sistema.
  Future<String> _ensureBlePermissions({required bool pedir}) async {
    if (!Platform.isAndroid) {
      return _permissionGranted;
    }

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 31) {
      final permisos = [
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
      ];
      final values = pedir
          ? (await permisos.request()).values.toList()
          : [for (final permiso in permisos) await permiso.status];

      final hasPermanent = values.any((s) => s.isPermanentlyDenied || s.isRestricted);
      final allGranted = values.every((s) => s.isGranted);
      if (allGranted) return _permissionGranted;
      if (hasPermanent) return _permissionPermanentlyDenied;
      return _permissionDenied;
    }

    final location = pedir
        ? await Permission.locationWhenInUse.request()
        : await Permission.locationWhenInUse.status;
    if (location.isGranted) return _permissionGranted;
    if (location.isPermanentlyDenied || location.isRestricted) {
      return _permissionPermanentlyDenied;
    }
    return _permissionDenied;
  }

  Future<bool> _shouldCheckLocationServices() async {
    if (!Platform.isAndroid) return false;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    // Android 11 and lower usually require Location Services ON for BLE scan.
    return androidInfo.version.sdkInt < 31;
  }
}
