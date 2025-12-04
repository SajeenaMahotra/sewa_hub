import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({super.key,
  required this.controller,
  required this.text,
  required this.errorText});

  final TextEditingController controller;
  final String text;
  final String errorText;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.text,
        hintText: widget.text,
        border: OutlineInputBorder(),
      ),
      controller: widget.controller,
    );
  }
}