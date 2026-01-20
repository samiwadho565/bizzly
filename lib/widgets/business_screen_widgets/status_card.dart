import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Widget icon;
  final Color backgroundColor;
  final Color contentColor;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.backgroundColor,
    required this.contentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.size.height*0.14,
      width: Get.size.width*0.42,
      // padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24), // Extra rounded corners as per image
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              // const SizedBox(width: 5),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: contentColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}