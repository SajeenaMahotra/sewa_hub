import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  const CustomTextField({super.key,
  required this.controller,
  required this.errorText,
  required this.labelText,
  required this.hintText});

  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final String errorText;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: widget.labelText,
        hintText: widget.hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius:BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Color(0xFFFF7940))        )
      ),
      controller: widget.controller,
    );
  }
}