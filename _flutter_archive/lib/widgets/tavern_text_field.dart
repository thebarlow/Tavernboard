import 'package:flutter/material.dart';

class TavernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool required;
  final String? errorText;
  final int maxLines;
  final TextInputType keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final String? hintText;

  const TavernTextField({
    super.key,
    required this.controller,
    required this.label,
    this.required = false,
    this.errorText,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hintText,
        errorText: errorText,
      ),
    );
  }
}
