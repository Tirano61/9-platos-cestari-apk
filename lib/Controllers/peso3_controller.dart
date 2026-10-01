

import 'dart:async';

import 'package:cuatro_platos/Controllers/config_controller.dart';
import 'package:cuatro_platos/data/ble/ble_scale_service.dart';
import 'package:cuatro_platos/data/udp/udp_scale_parser.dart';
import 'package:cuatro_platos/models/config_model.dart';
import 'package:cuatro_platos/models/recibir_peso_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:udp/udp.dart';


class Peso3Controller extends GetxController{

  final _pesoModel3 = RecibirPesoModel();
  final configGetx = Get.find<ConfigController>();
  final UdpScaleParser _parser = const UdpScaleParser();
  UDP? _receiver;
  StreamSubscription? _udpSubscription;

  get getPesoModel3{
    return _pesoModel3;
  }

  Future<void> recibirPeso3() async {
    if (configGetx.getConnectionType.value == ConnectionType.ble) {
      _udpGeneracion++;
      await _closeUdpListener();
      final preferred = configGetx.getPlato3BleName.value.trim();
      if (preferred.isEmpty) {
        await BleScaleService.instance.stopListening(3);
        estadoConexion = false;
        _pesoModel3.setConexion = false;
        return;
      }
      _intentosBle++;
      _pesoModel3.setConectando = true;
      try {
        await BleScaleService.instance.startListening(
          plato: 3,
          preferredName: preferred,
          onReading: (reading) {
            _pesoModel3.setPeso = reading.peso;
            _pesoModel3.setEstable = reading.estable;
            _pesoModel3.setTension = reading.tension;
            _pesoModel3.setAdreess = reading.sourceId;
            _pesoModel3.setConexion = true;
            estadoConexion = true;
            contador = 0;
          },
        );
      } finally {
        _intentosBle--;
        _pesoModel3.setConectando = _intentosBle > 0;
      }
      return;
    }

    // Sin await: disconnect() de flutter_blue_plus espera turno en un mutex
    // global y demora segundos; el UDP no tiene que quedar detras. La sesion BLE
    // se invalida igual en el momento.
    unawaited(BleScaleService.instance.stopListening(3));

    final puertoGuardado = int.tryParse(configGetx.getPuerto3.value);
    if (puertoGuardado == null) {
      return;
    }

    final generacion = ++_udpGeneracion;
    await _closeUdpListener();
    final UDP receiver;
    try {
      receiver = await UDP.bind(Endpoint.any(port: Port(puertoGuardado)));
    } catch (e) {
      debugPrint('UDP plato 3: no se pudo abrir el puerto $puertoGuardado: $e');
      // El timer vuelve a intentar mientras _receiver siga en null.
      return;
    }
    // Otra llamada (OK de nuevo, paso a BLE) empezo mientras se abria el socket.
    if (generacion != _udpGeneracion || configGetx.getConnectionType.value != ConnectionType.udp) {
      receiver.close();
      return;
    }
    _receiver = receiver;

    _udpSubscription = receiver.asStream().listen((datagram) {
      if (datagram == null) return;

      final reading = _parser.parse(
        rawData: datagram.data,
        sourceId: datagram.address.host,
      );
      if (reading == null) return;

      _pesoModel3.setPeso = reading.peso;
      _pesoModel3.setEstable = reading.estable;
      _pesoModel3.setTension = reading.tension;
      _pesoModel3.setAdreess = reading.sourceId;
      _pesoModel3.setConexion = true;

      estadoConexion = true;
      contador = 0;
    });
  }
  
  int contador = 0;
  bool estadoConexion = false;
  bool _isReconnecting = false;
  int _udpGeneracion = 0;
  int _intentosBle = 0;
  Timer? timerDato;

  Future<void> _tryReconnect() async {
    if (_isReconnecting) return;
    if (configGetx.getConnectionType.value == ConnectionType.ble) {
      if (configGetx.getPlato3BleName.value.trim().isEmpty) return;
    } else if (_receiver != null) {
      // En UDP el socket sigue abierto: el plato esta apagado, no hay que reabrir.
      return;
    }

    _isReconnecting = true;
    try {
      await recibirPeso3();
    } finally {
      _isReconnecting = false;
      // Los 5 s sin datos se cuentan desde que termina el intento; contados desde
      // que empezo, una conexion lenta se cortaria antes de recibir el primer dato.
      contador = 0;
    }
  }

  void startTimerDatoRecibido() {
    const oneSecPeso = Duration(milliseconds: 1000);
    timerDato?.cancel();
    timerDato = Timer.periodic(oneSecPeso, (timerPeso) async{ 
      
      if( contador < 5 ){
        contador ++;
      }

      if( contador == 5 ){
        if(estadoConexion){
          estadoConexion = false;
          _pesoModel3.setConexion = false;
          contador = 0;
        } else {
          contador = 0;
          await _tryReconnect();
        }
      }     
    });
  }

  Future<void> _closeUdpListener() async {
    await _udpSubscription?.cancel();
    _udpSubscription = null;
    _receiver?.close();
    _receiver = null;
  }

  @override
  void onInit() {
    super.onInit();
    startTimerDatoRecibido();
  }

  @override
  void onClose() {
    timerDato?.cancel();
    _closeUdpListener();
    BleScaleService.instance.stopListening(3);
    super.onClose();
  }

}