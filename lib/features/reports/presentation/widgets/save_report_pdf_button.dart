import 'package:flutter/material.dart';

import '../../data/report_data.dart';
import '../../data/report_pdf_service.dart';

class SaveReportPdfButton extends StatelessWidget {
  const SaveReportPdfButton({super.key, required this.report});

  final ReportData report;

  @override
  Widget build(BuildContext context) {
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
      icon: const Icon(Icons.picture_as_pdf_rounded),
      label: const Text('Save report as PDF'),
    );
  }
}
