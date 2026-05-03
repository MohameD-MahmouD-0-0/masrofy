import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.note,
    required this.paymentMethod,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final String note;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isIncome => type == 'income';

  static TransactionModel fromDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return TransactionModel(
      id: document.id,
      title: data['title'] as String? ?? '',
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      type: data['type'] as String? ?? 'expense',
      category: data['category'] as String? ?? '',
      note: data['note'] as String? ?? '',
      paymentMethod: data['paymentMethod'] as String? ?? '',
      createdAt: _dateFromValue(data['createdAt']),
      updatedAt: _dateFromValue(data['updatedAt']),
    );
  }

  static DateTime _dateFromValue(Object? value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return DateTime.now();
  }
}

class TransactionSummary {
  const TransactionSummary({required this.income, required this.expenses});

  final double income;
  final double expenses;

  double get balance => income - expenses;

  static TransactionSummary fromTransactions(
    List<TransactionModel> transactions,
  ) {
    var income = 0.0;
    var expenses = 0.0;

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expenses += transaction.amount;
      }
    }

    return TransactionSummary(income: income, expenses: expenses);
  }
}