
import 'dart:io';


class Conexion {
  Socket? socket;  
  static final Conexion cn = Conexion._();
  Conexion._();

  Future<bool> conectar(String ip)async{

    try {
      
        // Con timeout, un plato apagado no frena el cero general.
        socket ??= await Socket.connect(ip, 80, timeout: const Duration(seconds: 3));

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

}

  
  
