import 'package:flutter/material.dart';

Widget addButton(String title) {
  return InkWell(
    onTap: () {
      // Button click logic yahan ayegi
      print("Add Button Clicked");
    },
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5), // Light grey background
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Jitni zaroorat ho utni width le
        children:  [
          Icon(
            Icons.add,
            color: Colors.black54,
            size: 17,
          ),
          SizedBox(width: 8), // Icon aur text ke beech ka gap
          Text(
            title,
            style: TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}