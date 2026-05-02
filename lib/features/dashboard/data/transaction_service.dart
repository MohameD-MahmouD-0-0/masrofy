import 'package:cloud_firestore/cloud_firestore.dart';

import 'transaction_model.dart';

class TransactionService {
  TransactionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _transactionsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('transactions');
  }

  Stream<List<TransactionModel>> watchTransactions(String uid) {
    return _transactionsRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(TransactionModel.fromDocument)
              .toList(growable: false),
        );
  }

  Future<void> addTransaction({
    required String uid,
    required String title,
    required double amount,
    required String type,
    required String category,
    required String note,
  }) async {
    final document = _transactionsRef(uid).doc();
    await document.set({
      'id': document.id,
      'title': title.trim(),
      'amount': amount,
      'type': type,
      'category': category.trim(),
      'note': note.trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
