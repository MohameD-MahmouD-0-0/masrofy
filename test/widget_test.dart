import 'package:flutter_test/flutter_test.dart';

import 'package:masrofy/features/dashboard/data/transaction_model.dart';

void main() {
  test(
    'TransactionSummary calculates income, expenses, and balance',
    () {
      final transactions = [
        TransactionModel(
          id: '1',
          title: 'Salary',
          amount: 1000,
          type: 'income',
          category: 'Salary',
          note: '',
          paymentMethod: '',
          createdAt: DateTime(
            2026,
          ),
          updatedAt: DateTime(
            2026,
          ),
        ), // TransactionModel
        TransactionModel(
          id: '2',
          title: 'Groceries',
          amount: 250,
          type: 'expense',
          category: 'Food',
          note: '',
          paymentMethod: '',
          createdAt: DateTime(
            2026,
          ),
          updatedAt: DateTime(
            2026,
          ),
        ), // TransactionModel
      ];

      final summary =
          TransactionSummary.fromTransactions(
            transactions,
          );

      expect(
        summary.income,
        1000,
      );
      expect(
        summary.expenses,
        250,
      );
      expect(
        summary.balance,
        750,
      );
    },
  );
}
