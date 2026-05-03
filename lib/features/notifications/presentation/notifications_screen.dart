import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/notification_model.dart';
import '../data/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationService = NotificationService();
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xffF6F8FB),
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            onPressed: user == null || _isBusy
                ? null
                : () => _runAction(
                    () => _notificationService.markAllAsRead(user.uid),
                  ),
            icon: const Icon(Icons.done_all_rounded),
          ),
          IconButton(
            tooltip: 'Clear all',
            onPressed: user == null || _isBusy
                ? null
                : () => _confirmClear(user.uid),
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: user == null
            ? const _StateCard(
                icon: Icons.lock_outline_rounded,
                title: 'You are signed out',
                message: 'Please login again to view notifications.',
              )
            : StreamBuilder<List<NotificationModel>>(
                stream: _notificationService.watchNotifications(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _StateCard(
                      icon: Icons.error_outline_rounded,
                      title: 'Could not load notifications',
                      message: snapshot.error.toString(),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final notifications = snapshot.data!;
                  if (notifications.isEmpty) {
                    return const _StateCard(
                      icon: Icons.notifications_none_rounded,
                      title: 'No notifications',
                      message: 'Transaction updates will appear here.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final item = notifications[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _NotificationCard(
                          notification: item,
                          onTap: item.isRead
                              ? null
                              : () => _runAction(
                                  () => _notificationService.markAsRead(
                                    user.uid,
                                    item.id,
                                  ),
                                ),
                          onDelete: () => _runAction(
                            () => _notificationService.deleteNotification(
                              user.uid,
                              item.id,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }

  Future<void> _confirmClear(String uid) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear all notifications?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear all'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _runAction(() => _notificationService.clearAll(uid));
    }
  }

  Future<void> _runAction(Future<void> Function() action) async {
    if (_isBusy) return;
    setState(() => _isBusy = true);
    try {
      await action();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Notification action failed: $error')),
      );
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  final NotificationModel notification;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(notification.type);

    return Material(
      color: notification.isRead
          ? Colors.white
          : AppColors.primary.withAlpha(8),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: notification.isRead
                  ? const Color(0xffE5E7EB)
                  : AppColors.primary.withAlpha(80),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: color.withAlpha(24),
                child: Icon(_iconForType(notification.type), color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        color: AppColors.littleGrey,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(notification.createdAt),
                      style: const TextStyle(
                        color: AppColors.littleGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded),
                color: AppColors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'transaction_added':
        return Icons.add_circle_outline_rounded;
      case 'transaction_updated':
        return Icons.edit_note_rounded;
      case 'transaction_deleted':
        return Icons.delete_outline_rounded;
      case 'budget_set':
        return Icons.savings_outlined;
      case 'budget_updated':
        return Icons.edit_calendar_outlined;
      case 'budget_deleted':
        return Icons.delete_outline_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Color _colorForType(String type) {
    switch (type) {
      case 'transaction_added':
        return AppColors.success;
      case 'transaction_updated':
        return AppColors.primary;
      case 'transaction_deleted':
        return AppColors.red;
      case 'budget_set':
        return AppColors.success;
      case 'budget_updated':
        return AppColors.primary;
      case 'budget_deleted':
        return AppColors.red;
      default:
        return AppColors.littleGrey;
    }
  }

  String _formatDate(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} ${two(value.hour)}:${two(value.minute)}';
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xffE5E7EB)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 34),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.littleGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
