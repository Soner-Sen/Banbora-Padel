import 'package:flutter/material.dart';
import 'package:sonrize_padel/core/design_system/design_system.dart';

class HalfCourtPainter extends CustomPainter {
  const HalfCourtPainter({required this.isTopHalf});

  final bool isTopHalf;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.courtLine.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final serviceBoxWidth = size.width / 2;
    final serviceBoxHeight = size.height / 2;

    final serviceY = serviceBoxHeight;
    canvas.drawLine(
      Offset(serviceBoxWidth / 2, serviceY),
      Offset(serviceBoxWidth * 1.5, serviceY),
      paint,
    );

    canvas.drawLine(
      Offset(serviceBoxWidth, 0),
      Offset(serviceBoxWidth, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
