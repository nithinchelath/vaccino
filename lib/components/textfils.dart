import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  final TextEditingController
  controller; // Use TextEditingController for text field
  final String hintText;
  final bool obscureText;

  const MyText({
    Key? key, // Use Key? instead of super.key
    required this.controller,
    required this.hintText,
    required this.obscureText,
  }) : super(key: key); // Call super constructor with key

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          hintText: hintText, // Add hintText to the decoration
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white70),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blueGrey),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
      ),
    );
  }
}
