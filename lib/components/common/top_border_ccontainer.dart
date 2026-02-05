import 'package:flutter/material.dart';
import 'package:bizly/utils/app_colors.dart';

class TopBorderContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final double radius;

  const TopBorderContainer({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.backgroundColor = Colors.white,
    this.borderColor = AppColors.primaryDense,
    this.borderWidth = 1.5,
    this.radius = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        color: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(radius),
            topRight: Radius.circular(radius),
          ),
          side: BorderSide(
            color: borderColor,
            width: borderWidth,
          ),
        ),
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
