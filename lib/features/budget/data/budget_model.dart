import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.monthKey,
    required this.amount,
    required this.spent,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String monthKey;
  final double amount;
  final double spent;
  final DateTime createdAt;
  final DateTime updatedAt;

  double get remaining => amount - spent;

  double get progress {
    if (amount <= 0) return 0;
    return spent / amount;
  }

  BudgetStatus get status {
    if (amount <= 0) return BudgetStatus.none;
    if (spent > amount) return BudgetStatus.over;
    if (spent >= amount * 0.8) return BudgetStatus.near;
    return BudgetStatus.safe;
  }

  BudgetModel copyWithSpent(double value) {
    return BudgetModel(
      id: id,
      monthKey: monthKey,
      amount: amount,
      spent: value,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static BudgetModel fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return BudgetModel(
      id: doc.id,
      monthKey: data?['monthKey'] as String? ?? doc.id,
      amount: (data?['amount'] as num?)?.toDouble() ?? 0,
      spent: (data?['spent'] as num?)?.toDouble() ?? 0,
      createdAt: _dateFromValue(data?['createdAt']),
      updatedAt: _dateFromValue(data?['updatedAt']),
    );
  }

  static DateTime _dateFromValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }
}

enum BudgetStatus { none, safe, near, over }
