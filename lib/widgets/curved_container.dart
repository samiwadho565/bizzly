import 'package:flutter/material.dart';
import 'package:proste_bezier_curve/proste_bezier_curve.dart';

import '../utils/app_colors.dart';

class   CurvedContainer  extends StatelessWidget {
  final Widget? child;

  const   CurvedContainer ({Key? key,  this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      color: Colors.white.withOpacity(0.2),
      child: Column(
        children: [
          ClipPath(
            clipper: ProsteBezierCurve(
              position: ClipPosition.bottom, // curve at bottom
              list: [
                BezierCurveSection(
                  start: Offset(0, 140), // left start
                  top: Offset(screenWidth / 1.7, 210), // center highest point
                  end: Offset(screenWidth, 210), // right end
                ),
              ],
            ),
            child: Container(
              height: MediaQuery.of(context).size.height/3,
              decoration:  BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF307B80),
                    AppColors.primaryTeal, // Darkest Blue (Shuruat)
                   // Light "Shine" Color (Darmiyan mein)
                  AppColors.primaryLightTeal // Deep Blue (Ikhtitam)
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  // Stops ko adjust karke shine ki position control karein
                  stops: [0.2, 1.25, 0.9],
                ),
              ),
              child: child,
            ),

          ),


        ],
      ),
    );
  }
}
