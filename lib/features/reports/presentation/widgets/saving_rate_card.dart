import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SavingRateCard extends StatelessWidget {
  const SavingRateCard({super.key, required this.rate});

  final double rate;

  @override
  Widget build(BuildContext context) {
    final percent = (rate * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(45),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.reportWhite.withAlpha(35),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.savings_outlined,
                  size: 17,
                  color: AppColors.reportWhite,
                ),
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Saving Rate',
                  style: TextStyle(
                    color: AppColors.reportWhite,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            '$percent%',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.reportWhite,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: rate.clamp(0, 1),
              minHeight: 7,
              color: AppColors.reportSavingGreen,
              backgroundColor: AppColors.reportWhite.withAlpha(46),
            ),
          ),
        ],
      ),
    );
  }
}
