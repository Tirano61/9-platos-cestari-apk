import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputTextConfig extends StatelessWidget {
  const InputTextConfig({
    super.key,
    required TextEditingController controller,
    required String label
  }) : _controller = controller, _label = label;

  final TextEditingController _controller;
  final String _label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: 4,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))],
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15)
        ),
        counterText: '',
        hintText:  _label,
        labelText: _label,
        
        suffixIcon: Icon(Icons.legend_toggle_sharp,
            color:  ThemePlatos.backgroundPeso, size: 18),
        errorStyle: TextStyle(color: ThemePlatos.errorColor),
      ),
      controller: _controller,
    );
  }
}