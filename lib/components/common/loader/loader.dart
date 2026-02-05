import 'dart:math';
import 'package:flutter/material.dart';

class FinancePulseLoader extends StatefulWidget {
  final Color color;
  final double size;

  const FinancePulseLoader({
    super.key,
    this.color = const Color(0xFF2ECC71),
    this.size = 80,
  });

  @override
  State<FinancePulseLoader> createState() => _FinancePulseLoaderState();
}

class _FinancePulseLoaderState extends State<FinancePulseLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildBar(double heightFactor, int index) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final value = sin((_controller.value * 2 * pi) + index);
        return Container(
          width: 6,
          height: widget.size * 0.25 * (0.6 + value.abs()),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Center(
            child: Transform.scale(
              scale: 0.9 + (_controller.value * 0.1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(0.6, 1),
                  _buildBar(0.8, 2),
                  _buildBar(1.0, 3),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
