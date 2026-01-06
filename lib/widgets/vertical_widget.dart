import 'package:flutter/material.dart';

class VerticalIndicatorWidget extends StatelessWidget {
  const VerticalIndicatorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [

          /// 🔹 Dashed rounded border
          CustomPaint(
            size: const Size(80, 360),
            painter: _DashedRoundedPainter(),
          ),

          /// 🔹 Glowing dot (top)
          Positioned(
            top: 70,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 18,
                    spreadRadius: 4,
                  ),
                ],
              ),
            ),
          ),
          /// 🔹 Bottom outlined circle
          Positioned(
            bottom: 70,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _DashedRoundedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const dashLength = 8.0;
    const dashSpace = 4.0;

    final radius = size.width / 2;

    final path = Path()
    // 🔹 LEFT side (straight)
      ..moveTo(0, radius)
      ..lineTo(0, size.height)

    // 🔹 TOP curve (PURE TOP)
      ..moveTo(0, radius)
      ..arcToPoint(
        Offset(size.width, radius),
        radius: Radius.circular(radius),
        clockwise: true,
      )

    // 🔹 RIGHT side (straight)
      ..moveTo(size.width, radius)
      ..lineTo(size.width, size.height);

    _drawDashedPath(canvas, path, paint, dashLength, dashSpace);
  }

  void _drawDashedPath(
      Canvas canvas,
      Path path,
      Paint paint,
      double dashLength,
      double dashSpace,
      ) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dashLength),
          paint,
        );
        distance += dashLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
