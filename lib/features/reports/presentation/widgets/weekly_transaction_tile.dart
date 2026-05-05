import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/data/transaction_model.dart';

class WeeklyTransactionTile extends StatelessWidget {
  const WeeklyTransactionTile({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.reportBlueVeryLight,
            child: Icon(
              Icons.receipt_long,
              color: AppColors.reportBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title.isEmpty
                      ? transaction.category
                      : transaction.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.reportDarkText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.category,
                  style: const TextStyle(
                    color: AppColors.littleGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${transaction.amount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.reportRed,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
