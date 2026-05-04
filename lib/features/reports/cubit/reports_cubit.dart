import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../dashboard/data/transaction_model.dart';
import '../../dashboard/data/transaction_service.dart';
import '../data/report_data.dart';
import '../data/report_period.dart';
import 'reports_state.dart';

class ReportsCubit extends Cubit<ReportsState> {
  ReportsCubit() : super(InitialReportsState());

  final TransactionService transactionService = TransactionService();
  StreamSubscription<List<TransactionModel>>? subscription;

  List<TransactionModel> transactions = [];
  ReportPeriod selectedPeriod = ReportPeriod.monthly;

  void start(String uid) {
    emit(LoadingReportsState());

    subscription = transactionService
        .watchTransactions(uid)
        .listen(
          (newTransactions) {
            transactions = newTransactions;
            calculateReport();
          },
          onError: (error) {
            emit(ErrorReportsState(message: error.toString()));
          },
        );
  }

  void changePeriod(ReportPeriod period) {
    selectedPeriod = period;
    calculateReport();
  }

  void calculateReport() {
    double income = 0;
    double expenses = 0;
    Map<String, double> categories = {};
    List<TransactionModel> reportTransactions = [];
    List<TransactionModel> weekTransactions = [];

    for (var transaction in transactions) {
      if (isThisWeek(transaction.createdAt)) {
        weekTransactions.add(transaction);
      }

      if (!isInSelectedPeriod(transaction.createdAt)) {
        continue;
      }

      reportTransactions.add(transaction);

      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expenses += transaction.amount;

        String categoryName = transaction.category.trim();
        if (categoryName.isEmpty) {
          categoryName = 'Other';
        }

        categories[categoryName] =
            (categories[categoryName] ?? 0) + transaction.amount;
      }
    }

    List<CategorySpend> categorySpends = [];

    categories.forEach((name, amount) {
      if (amount > 0 && expenses > 0) {
        categorySpends.add(
          CategorySpend(name: name, amount: amount, share: amount / expenses),
        );
      }
    });

    categorySpends.sort((a, b) => b.amount.compareTo(a.amount));

    ReportData report = ReportData(
      income: income,
      expenses: expenses,
      categories: categorySpends,
      transactions: reportTransactions,
      weekTransactions: weekTransactions,
      period: selectedPeriod,
    );

    emit(SuccessReportsState(report: report));
  }

  bool isInSelectedPeriod(DateTime date) {
    DateTime now = DateTime.now();

    if (selectedPeriod == ReportPeriod.weekly) {
      DateTime startOfWeek = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));

      return !date.isBefore(startOfWeek);
    }

    if (selectedPeriod == ReportPeriod.monthly) {
      DateTime startOfMonth = DateTime(now.year, now.month);
      return !date.isBefore(startOfMonth);
    }

    DateTime startOfYear = DateTime(now.year);
    return !date.isBefore(startOfYear);
  }

  bool isThisWeek(DateTime date) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    return !date.isBefore(startOfWeek);
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}
