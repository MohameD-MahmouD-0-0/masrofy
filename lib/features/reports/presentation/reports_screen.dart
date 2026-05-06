import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../cubit/reports_cubit.dart';
import '../cubit/reports_state.dart';
import 'insight_detail_screen.dart';
import 'widgets/expense_distribution_card.dart';
import 'widgets/insight_item.dart';
import 'widgets/insights_list.dart';
import 'widgets/metric_card.dart';
import 'widgets/reports_header.dart';
import 'widgets/reports_state_message.dart';
import 'widgets/save_report_pdf_button.dart';
import 'widgets/saving_rate_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldColor =
        isDark ? AppColors.darkBackground : AppColors.reportLightBackground;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: SafeArea(
          child: ReportsStateMessage(
            icon: Icons.lock_outline_rounded,
            title: 'Sign in required',
            message: 'Please sign in to view your reports.',
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => ReportsCubit()..start(user.uid),
      child: Scaffold(
        backgroundColor: scaffoldColor,
        appBar: AppBar(
          title: const Text('Reports'),
          backgroundColor: scaffoldColor,
        ),
        body: SafeArea(
          child: BlocBuilder<ReportsCubit, ReportsState>(
            builder: (context, state) {
              if (state is LoadingReportsState || state is InitialReportsState) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is ErrorReportsState) {
                return ReportsStateMessage(
                  icon: Icons.error_outline_rounded,
                  title: 'Failed to load reports',
                  message: state.message,
                );
              }

              if (state is! SuccessReportsState) {
                return const ReportsStateMessage(
                  icon: Icons.info_outline_rounded,
                  title: 'No data',
                  message: 'There is no report data yet.',
                );
              }

              final report = state.report;
              final hasAnyReportData = report.transactions.isNotEmpty ||
                  report.expenses > 0 ||
                  report.income > 0;
              if (!hasAnyReportData) {
                return const _EmptyReportsView();
              }

              final insights = buildInsights(report);
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ReportsHeader(
                      period: report.period,
                      onPeriodChanged: (period) {
                        context.read<ReportsCubit>().changePeriod(period);
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            title: 'Income',
                            amount: report.income,
                            icon: Icons.arrow_downward_rounded,
                            color: AppColors.reportGreen,
                            accentColor: AppColors.reportGreen,
                            helper: '${report.periodLabel} total income',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: MetricCard(
                            title: 'Expenses',
                            amount: report.expenses,
                            icon: Icons.arrow_upward_rounded,
                            color: AppColors.reportRed,
                            accentColor: AppColors.reportSoftRed,
                            helper: '${report.periodLabel} total expenses',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SavingRateCard(rate: report.savingRate),
                    const SizedBox(height: 12),
                    ExpenseDistributionCard(report: report),
                    const SizedBox(height: 12),
                    InsightsList(
                      insights: insights,
                      selectedIndex: 0,
                      onTap: (index) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => InsightDetailScreen(
                              report: report,
                              insight: insights[index],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    SaveReportPdfButton(report: report),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyReportsView extends StatelessWidget {
  const _EmptyReportsView();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.darkPrimaryText : AppColors.primaryText;
    final subColor = isDark ? AppColors.darkSecondaryText : AppColors.littleGrey;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assetes/images/empty_budget.png',
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 26),
            Text(
              'No budget set',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Plan your spending and reach your goals faster by setting a monthly budget.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: subColor,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.budget),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Set Monthly Budget'),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
