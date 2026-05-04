import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'insight_item.dart';

class InsightDetailsCard extends StatelessWidget {
  const InsightDetailsCard({super.key, required this.insight});

  final InsightItem insight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 165,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.reportBlueCard,
        borderRadius: BorderRadius.circular(10),
        image: const DecorationImage(
          image: AssetImage('assetes/images/image.png'),
          alignment: Alignment.centerRight,
          opacity: 0.16,
          fit: BoxFit.contain,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 17,
            backgroundColor: AppColors.reportWhite.withAlpha(40),
            child: Icon(insight.icon, color: AppColors.reportWhite, size: 18),
          ),
          const Spacer(),
          Text(
            insight.message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.reportWhite,
              fontSize: 19,
              height: 1.15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            insight.title,
            style: const TextStyle(
              color: AppColors.reportBlueLight,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
