import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/report_data.dart';

class DistributionChart extends StatelessWidget {
  const DistributionChart({
    super.key,
    required this.categories,
    required this.colors,
    required this.total,
  });

  final List<CategorySpend> categories;
  final List<Color> colors;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 168,
        height: 168,
        child: CustomPaint(
          painter: DistributionPainter(categories: categories, colors: colors),
          child: Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: const BoxDecoration(
                color: AppColors.reportWhite,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'TOTAL',
                    style: TextStyle(
                      color: AppColors.littleGrey,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${total.toStringAsFixed(0)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.reportText,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DistributionPainter extends CustomPainter {
  const DistributionPainter({required this.categories, required this.colors});

  final List<CategorySpend> categories;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius - 7);
    var startAngle = -math.pi / 2;

    final backgroundPaint = Paint()
      ..color = AppColors.reportChartBackground
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 24;

    canvas.drawArc(rect, 0, math.pi * 2, false, backgroundPaint);

    for (var i = 0; i < categories.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 24;

      final angle = math.pi * 2 * categories[i].share;
      canvas.drawArc(rect, startAngle, angle, false, paint);
      startAngle += angle;
    }
  }

  @override
  bool shouldRepaint(DistributionPainter oldDelegate) {
    return oldDelegate.categories != categories;
  }
}
