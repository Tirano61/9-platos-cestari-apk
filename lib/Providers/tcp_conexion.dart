
import 'dart:io';


class Conexion {
  Socket? socket;  
  static final Conexion cn = Conexion._();
  Conexion._();

  Future<bool> conectar(String ip)async{

    try {
      
        socket ??= await Socket.connect(ip, 80);

    } catch (e) {
      return false;
    }
    return true;
  }

  Future cerrarSocket()async{
    socket!.close();
    socket!.destroy();
    socket = null;
    //print('CERRO EL SOCKET');
  }

  Future<bool> enviarCero() async {
    try {
      socket!.write("GET /peso?cero=1 HTTP/1.1\r\n\r\n");
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> enviarHold() async {
    try {
      socket!.write("GET /peso?resethold=1 HTTP/1.1\r\n\r\n");
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> enviarCalibracion(String celdas, String sensibilidad, String division, String conversiones, String recortes, String ventana, String kgfiltro, String tiempoestable)async{
    try {
      socket!.write(
        'GET /save?celdas=$celdas&sensibilidad=$sensibilidad&division=$division&conversiones=$conversiones&recortes=$recortes&ventanam=$ventana&gkfiltro=$kgfiltro&tiempoestable=$tiempoestable HTTP/1.1\r\n\r\n',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

}

  
  
