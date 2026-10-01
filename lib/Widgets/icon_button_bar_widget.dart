

import 'package:flutter/material.dart';

class IconBottonBarWidget extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final void Function()? onPressed;
  final double? iconSize;
  const IconBottonBarWidget({
    required this.icon,
    this.iconColor,
    required this.onPressed,
    this.iconSize,
    super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Exportar',
      padding: const EdgeInsets.all(12.0),
      onPressed: onPressed,
      icon: Icon(
        icon, 
        size: iconSize ?? 20,  
      ),
    );
  }
}