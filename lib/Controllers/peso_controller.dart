
import 'dart:async';
import 'package:nueve_platos_cestari/Controllers/config_controller.dart';
import 'package:nueve_platos_cestari/data/udp/udp_scale_parser.dart';
import 'package:nueve_platos_cestari/models/recibir_peso_model.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:udp/udp.dart';


/// Recibe por UDP el peso de un plato (1..N) en el puerto configurado.
///
/// Se registra con `Get.put(PesoController(plato: n), tag: 'plato$n')`
/// y se busca con `Get.find<PesoController>(tag: 'plato$n')`.
class PesoController extends GetxController{

  PesoController({required this.plato});

  final int plato;
  final RecibirPesoModel pesoModel = RecibirPesoModel();
  final configGetx = Get.find<ConfigController>();
  final UdpScaleParser _parser = const UdpScaleParser();
  UDP? _receiver;
  StreamSubscription? _udpSubscription;

  Future<void> recibirPeso() async {
    final puertoGuardado = int.tryParse(configGetx.puerto(plato).value);
    if (puertoGuardado == null) {
      return;
    }

    final generacion = ++_udpGeneracion;
    await _closeUdpListener();
    final UDP receiver;
    try {
      receiver = await UDP.bind(Endpoint.any(port: Port(puertoGuardado)));
    } catch (e) {
      debugPrint('UDP plato $plato: no se pudo abrir el puerto $puertoGuardado: $e');
      // El timer vuelve a intentar mientras _receiver siga en null.
      return;
    }
    // Otra llamada (OK de nuevo) empezo mientras se abria el socket.
    if (generacion != _udpGeneracion) {
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

      pesoModel.setPeso = reading.peso;
      pesoModel.setEstable = reading.estable;
      pesoModel.setTension = reading.tension;
      pesoModel.setAdreess = reading.sourceId;
      pesoModel.setConexion = true;

      estadoConexion = true;
      contador = 0;
    });
  }

  int contador = 0;
  bool estadoConexion = false;
  bool _isReconnecting = false;
  int _udpGeneracion = 0;
  Timer? timerDato;

  Future<void> _tryReconnect() async {
    if (_isReconnecting) return;
    // El socket sigue abierto: el plato esta apagado, no hay que reabrir.
    if (_receiver != null) return;

    _isReconnecting = true;
    try {
      await recibirPeso();
    } finally {
      _isReconnecting = false;
      // Los 5 s sin datos se cuentan desde que termina el intento.
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
          pesoModel.setConexion = false;
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
    super.onClose();
  }

}
