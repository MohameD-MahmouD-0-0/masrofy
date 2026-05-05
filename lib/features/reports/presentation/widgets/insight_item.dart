import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/report_data.dart';

class InsightItem {
  const InsightItem({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
  });

  final String title;
  final String message;
  final IconData icon;
  final Color color;
}

List<InsightItem> buildInsights(ReportData report) {
  final topCategory = report.topWeekCategory?.name ?? 'your spending';
  final amount = report.topWeekCategory?.amount ?? 0;

  return [
    InsightItem(
      title: 'High Spend',
      message: 'Your highest spend this week is $topCategory.',
      icon: Icons.restaurant,
      color: AppColors.reportSoftRed,
    ),
    InsightItem(
      title: 'Weekly Total',
      message: 'You spent \$${amount.toStringAsFixed(0)} on $topCategory.',
      icon: Icons.payments_outlined,
      color: AppColors.reportGreen,
    ),
    InsightItem(
      title: 'Smart Tip',
      message: 'Try moving 5% from $topCategory to savings.',
      icon: Icons.lightbulb_outline,
      color: AppColors.reportBlue,
    ),
  ];
}
