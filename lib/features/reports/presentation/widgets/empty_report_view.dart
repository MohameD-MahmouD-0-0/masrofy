import 'package:flutter/material.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class EmptyReportView extends StatelessWidget {
  const EmptyReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              height: 150,
              child: Image.asset('assetes/images/empty_budget.png'),
            ),
            const SizedBox(height: 42),
            const Text(
              'No transactions yet',
              style: TextStyle(
                color: AppColors.reportText,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add your first transaction to start seeing your financial reports.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.littleGrey,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.addTransaction),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Add Transaction'),
            ),
          ],
        ),
      ),
    );
  }
}
