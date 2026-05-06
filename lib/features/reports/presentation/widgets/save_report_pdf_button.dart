import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/report_data.dart';
import '../../data/report_pdf_service.dart';

class SaveReportPdfButton extends StatelessWidget {
  const SaveReportPdfButton({super.key, required this.report});

  final ReportData report;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FilledButton.icon(
      onPressed: () async {
        try {
          await saveReportPdf(report);
        } catch (error) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Restart the app and try again.')),
          );
        }
      },
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: isDark ? AppColors.primary : const Color(0xff1565C0),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
      label: const Text(
        'Save report as PDF',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      ),
    );
  }
}
