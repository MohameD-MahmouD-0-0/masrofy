import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'insight_item.dart';

class InsightsList extends StatelessWidget {
  const InsightsList({
    super.key,
    required this.insights,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<InsightItem> insights;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(insights.length, (index) {
        final item = insights[index];
        final selected = index == selectedIndex;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => onTap(index),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.reportSelectedBlue
                    : AppColors.reportWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.reportBorder),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: item.color.withAlpha(45),
                    child: Icon(item.icon, size: 16, color: item.color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.reportDarkText,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          item.message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.littleGrey,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
