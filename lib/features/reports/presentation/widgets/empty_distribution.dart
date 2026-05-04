import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class EmptyDistribution extends StatelessWidget {
  const EmptyDistribution({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.reportEmptyCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.reportBorder),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.pie_chart_outline_rounded,
            color: AppColors.littleGrey,
            size: 38,
          ),
          SizedBox(height: 10),
          Text(
            'No expenses in this period yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.littleGrey,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
