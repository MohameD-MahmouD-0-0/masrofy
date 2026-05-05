import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/report_data.dart';

class WeeklyCategoryCard extends StatelessWidget {
  const WeeklyCategoryCard({super.key, required this.category});

  final CategorySpend? category;

  @override
  Widget build(BuildContext context) {
    final name = category?.name ?? 'No spending yet';
    final amount = category?.amount ?? 0;
    final share = category?.share ?? 0;

    return Container(
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
                backgroundColor: AppColors.reportGreen,
                child: Icon(
                  Icons.restaurant,
                  size: 14,
                  color: AppColors.reportDarkText,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Highest This Week',
                style: TextStyle(color: AppColors.reportSecondText),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            name,
            style: const TextStyle(
              color: AppColors.reportDarkText,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '\$${amount.toStringAsFixed(0)} spent this week',
            style: const TextStyle(
              color: AppColors.reportSecondText,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: share.clamp(0, 1),
              minHeight: 6,
              color: AppColors.reportBlue,
              backgroundColor: AppColors.reportBlueLight,
            ),
          ),
        ],
      ),
    );
  }
}
