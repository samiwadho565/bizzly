import 'package:flutter/cupertino.dart'; // Cupertino use karne ke liye
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double height;
  final Color color;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 56.0, // Default height
    this.color = const Color(0xFF0D5D5D), // Default Teal color
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // Hamesha full width lega
      height: height,         // Height control karne ka option
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: color,
        borderRadius: BorderRadius.circular(15),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}