import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/report_data.dart';

class SmartSavingCard extends StatelessWidget {
  const SmartSavingCard({super.key, required this.report});

  final ReportData report;

  @override
  Widget build(BuildContext context) {
    final savedPercent = (report.savingRate * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.reportSelectedBlue,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.reportBlueLight),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.reportWhite,
            child: Icon(Icons.savings_outlined, color: AppColors.reportRed),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Smart Saving',
                  style: TextStyle(
                    color: AppColors.reportDarkText,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You saved $savedPercent% this period. Keep it up!',
                  style: const TextStyle(
                    color: AppColors.reportSecondText,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
