import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  static NotificationModel fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();
    return NotificationModel(
      id: document.id,
      title: data?['title'] as String? ?? '',
      message: data?['message'] as String? ?? '',
      type: data?['type'] as String? ?? '',
      isRead: data?['isRead'] as bool? ?? false,
      createdAt: _dateFromValue(data?['createdAt']),
    );
  }

  static DateTime _dateFromValue(Object? value) {
    if (value is Timestamp) return value.toDate();
    return DateTime.now();
  }
}
