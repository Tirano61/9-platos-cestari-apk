


import 'package:flutter/material.dart';

class ConnectionWidget extends StatelessWidget {
  const ConnectionWidget({
    super.key,
    required this.connection,
  });
  final bool connection;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: Icon(Icons.wifi, color: connection ? Colors.green : Colors.red, size: 12,)
    );
  }
}
