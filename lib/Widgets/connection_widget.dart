


import 'package:flutter/material.dart';

class ConnectionWidget extends StatelessWidget {
  const ConnectionWidget({
    super.key,
    required this.connection,
    this.colorConectado = Colors.green,
  });
  final bool connection;
  /// Color del icono con conexion (sobre fondos verdes conviene uno mas claro).
  final Color colorConectado;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: Icon(Icons.wifi, color: connection ? colorConectado : Colors.red, size: 12,)
    );
  }
}
