import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/report_period.dart';

class ReportsHeader extends StatelessWidget {
  const ReportsHeader({
    super.key,
    required this.period,
    required this.onPeriodChanged,
  });

  final ReportPeriod period;
  final ValueChanged<ReportPeriod> onPeriodChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial Reports',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.reportText,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Insights and tracking for your spending',
          style: TextStyle(
            color: AppColors.littleGrey,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 42,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.reportHeaderTabs,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: ReportPeriod.values.map((item) {
              final selected = item == period;
              return Expanded(
                child: InkWell(
                  onTap: () => onPeriodChanged(item),
                  borderRadius: BorderRadius.circular(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.reportWhite
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color: AppColors.reportShadow.withAlpha(12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      item.label,
                      style: TextStyle(
                        color: selected
                            ? AppColors.primary
                            : AppColors.littleGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
