import 'package:flutter/material.dart';

/// ----------------- Reusable Circle Widget (Icon or Image) -----------------
class CircleIcon extends StatelessWidget {
  final IconData? icon; // Optional Icon
  final ImageProvider? image; // Optional Image
  final double size; // Icon size
  final Color iconColor; // Icon color
  final double circleSize; // Circle diameter
  final Color circleColor; // Circle background color
  final VoidCallback? onTap; // Optional tap action

  const CircleIcon({
    super.key,
    this.icon,
    this.image,
    this.size = 24,
    this.iconColor = Colors.white,
    this.circleSize = 50,
    this.circleColor = Colors.blue,
    this.onTap,
  }) : assert(icon != null || image != null, 'Either icon or image must be provided');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          color: circleColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ]
        ),
        alignment: Alignment.center,
        child: image != null
            ? ClipOval(
          child: Image(
            image: image!,
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        )
            : Icon(
          icon,
          size: size,
          color: iconColor,
        ),
      ),
    );
  }
}
