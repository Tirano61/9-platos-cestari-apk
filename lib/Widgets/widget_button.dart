
import 'package:flutter/material.dart';

class WidgetButton extends StatelessWidget {
  final String texto;
  final double? ancho;
  final double? alto;
  final double? fontSize;
  final IconData? icon;
  final Color? iconColor;
  final double? separador;
  final double? borderRadius;
  final double? iconSize;
  final void Function() onPress;
  final Color? color1;
  final Color? color2;
  const WidgetButton(
      {super.key,
      required this.onPress,
      required this.texto,
      this.ancho,
      this.alto,
      this.fontSize,
      this.icon,
      this.iconColor,
      this.separador,
      this.borderRadius,
      this.iconSize,
      this.color1,
      this.color2});

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        onPress();
      },
      child: Container(
        width: ancho ,
        height: alto ,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? 8),
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color1 ?? const Color.fromARGB(112, 33, 149, 243),
                color2 ?? const Color.fromARGB(156, 28, 70, 91),
              ])
          ),
        child: Center(child: Text( texto, style: TextStyle(fontSize: fontSize ?? 20, color: Colors.black, fontWeight: FontWeight.bold) )),
      ),
    );
  }
}
