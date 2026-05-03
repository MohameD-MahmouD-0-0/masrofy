import 'package:cloud_firestore/cloud_firestore.dart';

import 'budget_model.dart';

class BudgetService {
  BudgetService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _budgetsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('budgets');
  }

  CollectionReference<Map<String, dynamic>> _transactionsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('transactions');
  }

  Stream<BudgetModel?> watchCurrentMonthBudget(String uid) {
    return watchBudgetByMonth(uid, currentMonthKey());
  }

  Stream<BudgetModel?> watchBudgetByMonth(String uid, String monthKey) {
    return _budgetsRef(uid).doc(monthKey).snapshots().map((document) {
      if (!document.exists) return null;
      return BudgetModel.fromDocument(document);
    });
  }

  Future<void> setMonthlyBudget(
    String uid,
    double amount,
    String monthKey,
  ) async {
    final spent = await calculateMonthlySpent(uid, monthKey);
    await _budgetsRef(uid).doc(monthKey).set({
      'id': monthKey,
      'monthKey': monthKey,
      'amount': amount,
      'spent': spent,
      'remaining': amount - spent,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateMonthlyBudget(
    String uid,
    String budgetId,
    double amount,
  ) async {
    final existing = await _budgetsRef(uid).doc(budgetId).get();
    final monthKey = existing.data()?['monthKey'] as String? ?? budgetId;
    final spent = await calculateMonthlySpent(uid, monthKey);
    await _budgetsRef(uid).doc(budgetId).update({
      'amount': amount,
      'spent': spent,
      'remaining': amount - spent,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteBudget(String uid, String budgetId) async {
    await _budgetsRef(uid).doc(budgetId).delete();
  }

  Future<double> calculateMonthlySpent(String uid, String monthKey) async {
    final snapshot = await _expenseQuery(uid, monthKey).get();
    return _sumExpenses(snapshot.docs);
  }

  Stream<double> watchMonthlySpent(String uid, String monthKey) {
    return _expenseQuery(
      uid,
      monthKey,
    ).snapshots().map((snapshot) => _sumExpenses(snapshot.docs));
  }

  Query<Map<String, dynamic>> _expenseQuery(String uid, String monthKey) {
    final range = _monthRange(monthKey);
    return _transactionsRef(uid)
        .where('type', isEqualTo: 'expense')
        .where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(range.$1),
        )
        .where('createdAt', isLessThan: Timestamp.fromDate(range.$2));
  }

  double _sumExpenses(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    var total = 0.0;
    for (final doc in docs) {
      total += (doc.data()['amount'] as num?)?.toDouble() ?? 0;
    }
    return total;
  }

  (DateTime, DateTime) _monthRange(String monthKey) {
    final parts = monthKey.split('-');
    final year = int.tryParse(parts.isNotEmpty ? parts[0] : '');
    final month = int.tryParse(parts.length > 1 ? parts[1] : '');
    final start = DateTime(
      year ?? DateTime.now().year,
      month ?? DateTime.now().month,
    );
    return (start, DateTime(start.year, start.month + 1));
  }

  static String currentMonthKey() {
    final now = DateTime.now();
    return monthKeyFor(now);
  }

  static String monthKeyFor(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    return '${value.year}-$month';
  }
}
