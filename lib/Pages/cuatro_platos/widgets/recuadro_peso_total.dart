import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:flutter/material.dart';

class RecuadroPesoTotal extends StatefulWidget {
  final String suma;
  const RecuadroPesoTotal({
    super.key, required this.suma
  });

  @override
  State<RecuadroPesoTotal> createState() => _RecuadroPesoTotalState();
}

class _RecuadroPesoTotalState extends State<RecuadroPesoTotal> {

  // Los timers de desconexion/reconexion de cada plato los maneja su controller
  // (onInit/onClose). Antes se cancelaban al salir de la pantalla de pesaje y en
  // el Home ningun plato BLE volvia a reconectarse.

  @override
  Widget build(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: SizeScreen.sc().screenWidth * 0.4,
          height: SizeScreen.sc().screenWidth * 0.07,
          decoration: const BoxDecoration(
            color: Color.fromARGB(188, 5, 21, 76),
            borderRadius:  BorderRadius.horizontal(left:  Radius.circular(10)),
          ),
          child:  Center(
            child: Text(
              'Total', 
              style: TextStyle(color: Colors.white, fontSize: SizeScreen.sc().screenWidth < 520 ? 18 : 24),
            )
          )
        ),
        Container(
          width: SizeScreen.sc().screenWidth * 0.4,
          height: SizeScreen.sc().screenWidth * 0.07,
          decoration: const BoxDecoration(
            color: Color.fromARGB(131, 1, 40, 108),
            borderRadius:  BorderRadius.horizontal(right:  Radius.circular(10)),
          ),
          child: Center(
            child: Text(
              '${widget.suma.toString()} kg', 
              style: TextStyle(
                color: Colors.black, 
                fontSize: SizeScreen.sc().screenWidth < 520 ? 18 : 24,
                fontWeight: FontWeight.bold
              ),
            )
          )
        ),
      ],
    );
  }
}