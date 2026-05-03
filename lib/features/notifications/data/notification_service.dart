import 'package:cloud_firestore/cloud_firestore.dart';

import 'notification_model.dart';

class NotificationService {
  NotificationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _notificationsRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  Stream<List<NotificationModel>> watchNotifications(String uid) {
    return _notificationsRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(NotificationModel.fromDocument)
              .toList(growable: false),
        );
  }

  Stream<int> watchUnreadCount(String uid) {
    return _notificationsRef(uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> createNotification(
    String uid,
    String title,
    String message,
    String type,
  ) async {
    final document = _notificationsRef(uid).doc();
    await document.set({
      'id': document.id,
      'title': title.trim(),
      'message': message.trim(),
      'type': type,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> markAsRead(String uid, String notificationId) async {
    await _notificationsRef(uid).doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String uid) async {
    final snapshot = await _notificationsRef(
      uid,
    ).where('isRead', isEqualTo: false).get();
    final batch = _firestore.batch();
    for (final document in snapshot.docs) {
      batch.update(document.reference, {'isRead': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String uid, String notificationId) async {
    await _notificationsRef(uid).doc(notificationId).delete();
  }

  Future<void> clearAll(String uid) async {
    final snapshot = await _notificationsRef(uid).get();
    final batch = _firestore.batch();
    for (final document in snapshot.docs) {
      batch.delete(document.reference);
    }
    await batch.commit();
  }
}
