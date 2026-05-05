import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/report_data.dart';
import 'widgets/insight_details_card.dart';
import 'widgets/insight_item.dart';
import 'widgets/smart_saving_card.dart';
import 'widgets/trend_card.dart';
import 'widgets/weekly_category_card.dart';
import 'widgets/weekly_transactions_list.dart';

class InsightDetailScreen extends StatelessWidget {
  const InsightDetailScreen({
    super.key,
    required this.report,
    required this.insight,
  });

  final ReportData report;
  final InsightItem insight;

  @override
  Widget build(BuildContext context) {
    final category = report.topWeekCategory;
    final transactions = category == null
        ? report.weekTransactions
        : report.transactionsFor(category.name);

    return Scaffold(
      backgroundColor: AppColors.reportLightBackground,
      appBar: AppBar(
        title: Text(insight.title),
        backgroundColor: AppColors.reportLightBackground,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          child: Column(
            children: [
              InsightDetailsCard(insight: insight),
              const SizedBox(height: 14),
              WeeklyCategoryCard(category: category),
              const SizedBox(height: 14),
              const TrendCard(),
              const SizedBox(height: 14),
              SmartSavingCard(report: report),
              const SizedBox(height: 14),
              WeeklyTransactionsList(transactions: transactions),
            ],
          ),
        ),
      ),
    );
  }
}
