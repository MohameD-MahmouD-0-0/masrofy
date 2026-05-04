import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'report_data.dart';

Future<void> saveReportPdf(ReportData report) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text('Masrofy Report', style: pw.TextStyle(fontSize: 28)),
        pw.SizedBox(height: 20),

        pw.Text('Period: ${report.periodLabel}'),
        pw.Text('Income: ${money(report.income)}'),
        pw.Text('Expenses: ${money(report.expenses)}'),
        pw.Text('Saving Rate: ${(report.savingRate * 100).round()}%'),

        pw.SizedBox(height: 20),
        pw.Text('Categories', style: pw.TextStyle(fontSize: 20)),
        pw.SizedBox(height: 10),
        ...report.categories.map((category) {
          final percent = (category.share * 100).round();
          return pw.Text(
            '${category.name}: ${money(category.amount)} ($percent%)',
          );
        }),

        pw.SizedBox(height: 20),
        pw.Text('Transactions', style: pw.TextStyle(fontSize: 20)),
        pw.SizedBox(height: 10),
        ...report.transactions.map((transaction) {
          final title = transaction.title.isEmpty
              ? transaction.category
              : transaction.title;

          return pw.Text('$title: ${money(transaction.amount)}');
        }),
      ],
    ),
  );

  await Printing.sharePdf(
    bytes: await pdf.save(),
    filename: 'masrofy-report.pdf',
  );
}

String money(double value) {
  return '\$${value.toStringAsFixed(2)}';
}
