import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/report_data.dart';
import 'category_row.dart';
import 'distribution_chart.dart';
import 'distribution_colors.dart';
import 'empty_distribution.dart';

class ExpenseDistributionCard extends StatelessWidget {
  const ExpenseDistributionCard({super.key, required this.report});

  final ReportData report;

  @override
  Widget build(BuildContext context) {
    final categories = report.categories;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.reportWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.reportBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.reportShadow.withAlpha(8),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Expense Distribution',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.reportText,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A detailed breakdown of your ${report.periodLabel.toLowerCase()} spending categories.',
            style: const TextStyle(
              color: AppColors.littleGrey,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          if (categories.isEmpty)
            const EmptyDistribution()
          else ...[
            ...List.generate(categories.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: CategoryRow(
                  category: categories[index],
                  color: distributionColors[index % distributionColors.length],
                ),
              );
            }),
            const SizedBox(height: 14),
            DistributionChart(
              categories: categories,
              colors: distributionColors,
              total: report.expenses,
            ),
          ],
        ],
      ),
    );
  }
}
