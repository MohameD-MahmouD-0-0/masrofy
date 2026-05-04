import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class TrendCard extends StatelessWidget {
  const TrendCard({super.key});

  @override
  Widget build(BuildContext context) {
    final bars = [20.0, 30.0, 24.0, 42.0, 34.0, 52.0, 64.0];

    return Container(
      height: 175,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.reportWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.reportBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppColors.reportBlueLight,
                child: Icon(
                  Icons.trending_up,
                  size: 14,
                  color: AppColors.reportBlue,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '7-Day Trend',
                style: TextStyle(color: AppColors.reportSecondText),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Active Spending',
            style: TextStyle(
              color: AppColors.reportDarkText,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: bars.map((height) {
              final isLast = height == bars.last;

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: isLast
                          ? AppColors.reportBlue
                          : AppColors.reportBlueLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
