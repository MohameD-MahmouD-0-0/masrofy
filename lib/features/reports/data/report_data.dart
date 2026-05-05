import '../../dashboard/data/transaction_model.dart';
import 'report_period.dart';

class ReportData {
  const ReportData({
    required this.income,
    required this.expenses,
    required this.categories,
    required this.transactions,
    required this.weekTransactions,
    required this.period,
  });

  final double income;
  final double expenses;
  final List<CategorySpend> categories;
  final List<TransactionModel> transactions;
  final List<TransactionModel> weekTransactions;
  final ReportPeriod period;

  String get periodLabel => period.label;

  CategorySpend? get topCategory {
    if (categories.isEmpty) return null;
    return categories.first;
  }

  CategorySpend? get topWeekCategory {
    double total = 0;
    final totals = <String, double>{};

    for (final transaction in weekTransactions) {
      if (transaction.isIncome) continue;

      final name = transaction.category.trim().isEmpty
          ? 'Other'
          : transaction.category.trim();

      total += transaction.amount;
      totals[name] = (totals[name] ?? 0) + transaction.amount;
    }

    if (totals.isEmpty || total == 0) return null;

    final categories = totals.entries.map((entry) {
      return CategorySpend(
        name: entry.key,
        amount: entry.value,
        share: entry.value / total,
      );
    }).toList();

    categories.sort((a, b) => b.amount.compareTo(a.amount));
    return categories.first;
  }

  List<TransactionModel> transactionsFor(String category) {
    return weekTransactions.where((transaction) {
      final name = transaction.category.trim().isEmpty
          ? 'Other'
          : transaction.category.trim();

      return !transaction.isIncome && name == category;
    }).toList();
  }

  double get savingRate {
    if (income <= 0) return 0;
    return ((income - expenses) / income).clamp(0, 1);
  }
}

class CategorySpend {
  const CategorySpend({
    required this.name,
    required this.amount,
    required this.share,
  });

  final String name;
  final double amount;
  final double share;
}
