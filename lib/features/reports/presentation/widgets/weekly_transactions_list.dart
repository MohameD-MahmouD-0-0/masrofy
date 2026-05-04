import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../dashboard/data/transaction_model.dart';
import 'weekly_transaction_tile.dart';

class WeeklyTransactionsList extends StatelessWidget {
  const WeeklyTransactionsList({super.key, required this.transactions});

  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
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
          const Text(
            'What you spent on',
            style: TextStyle(
              color: AppColors.reportDarkText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            const Text(
              'No expenses found this week.',
              style: TextStyle(color: AppColors.littleGrey),
            )
          else
            ...transactions.map((item) {
              return WeeklyTransactionTile(transaction: item);
            }),
        ],
      ),
    );
  }
}
