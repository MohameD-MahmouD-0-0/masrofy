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

  Future<TransactionModel?> getTransaction({
    required String uid,
    required String transactionId,
  }) async {
    final document = await _transactionsRef(uid).doc(transactionId).get();
    if (!document.exists) return null;
    return TransactionModel.fromDocument(document);
  }

  Future<String> addTransaction({
    required String uid,
    TransactionModel? transaction,
    String? title,
    double? amount,
    String? type,
    String? category,
    String? note,
    String? paymentMethod,
  }) async {
    final document = _transactionsRef(uid).doc();
    await document.set({
      'id': document.id,
      'title': (title ?? transaction?.title ?? '').trim(),
      'amount': amount ?? transaction?.amount ?? 0,
      'type': type ?? transaction?.type ?? 'expense',
      'category': (category ?? transaction?.category ?? '').trim(),
      'note': (note ?? transaction?.note ?? '').trim(),
      'paymentMethod': (paymentMethod ?? transaction?.paymentMethod ?? '')
          .trim(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return document.id;
  }

  Future<void> updateTransaction({
    required String uid,
    required String transactionId,
    Map<String, dynamic>? data,
    String? title,
    double? amount,
    String? type,
    String? category,
    String? note,
    String? paymentMethod,
  }) async {
    final updateData = <String, dynamic>{
      if (data != null) ...data,
      if (title != null) 'title': title.trim(),
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (category != null) 'category': category.trim(),
      if (note != null) 'note': note.trim(),
      if (paymentMethod != null) 'paymentMethod': paymentMethod.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await _transactionsRef(uid).doc(transactionId).update(updateData);
  }

  Future<void> deleteTransaction({
    required String uid,
    required String transactionId,
  }) async {
    await _transactionsRef(uid).doc(transactionId).delete();
  }
}
