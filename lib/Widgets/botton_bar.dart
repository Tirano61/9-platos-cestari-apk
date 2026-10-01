

import 'package:flutter/material.dart';

class BottonBarApp extends StatefulWidget {

  final List<Widget> children;
  final Color?       backgroundColor;
  const BottonBarApp({
    required this.children,
    this.backgroundColor,
    super.key
  });

  @override
  State<BottonBarApp> createState() => _BottonBarAppState();
}

class _BottonBarAppState extends State<BottonBarApp> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromARGB(255, 238, 238, 238),
      shadowColor: const Color.fromARGB(255, 0, 0, 0),
      notchMargin: 6.0,
      shape:  const CircularNotchedRectangle(),
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: widget.children
        ),
      ),
    );
  }
}
