import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/report_data.dart';

class CategoryRow extends StatelessWidget {
  const CategoryRow({super.key, required this.category, required this.color});

  final CategorySpend category;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final percent = (category.share * 100).round();

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.reportText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$percent%',
          style: const TextStyle(
            color: AppColors.reportText,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
