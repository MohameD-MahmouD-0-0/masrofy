import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../notifications/data/notification_service.dart';
import '../data/transaction_model.dart';
import '../data/transaction_service.dart';

class TransactionDetailsScreen
    extends StatefulWidget {
  const TransactionDetailsScreen({
    super.key,
  });

  @override
  State<
    TransactionDetailsScreen
  >
  createState() =>
      _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState
    extends
        State<
          TransactionDetailsScreen
        > {
  final _transactionService =
      TransactionService();
  final _notificationService =
      NotificationService();
  bool _isDeleting = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    final transaction =
        ModalRoute.of(
          context,
        )?.settings.arguments;
    if (transaction
        is! TransactionModel) {
      return const _InvalidTransactionView();
    }

    final colorScheme =
        Theme.of(
          context,
        ).colorScheme;
    final isDark =
        Theme.of(
          context,
        ).brightness ==
        Brightness.dark;
    final color =
        transaction.isIncome
        ? AppColors.success
        : AppColors.red;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction details',
        ),
        actions: [
          IconButton(
            tooltip: 'Edit',
            onPressed:
                _isDeleting
                ? null
                : () async {
                    final changed = await Navigator.pushNamed(
                      context,
                      AppRoutes
                          .editTransaction,
                      arguments:
                          transaction,
                    );
                    if (changed ==
                            true &&
                        context
                            .mounted) {
                      Navigator.pop(
                        context,
                      );
                    }
                  },
            icon: const Icon(
              Icons
                  .edit_outlined,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                32,
              ),
          children: [
            Container(
              padding:
                  const EdgeInsets.all(
                    20,
                  ),
              decoration: BoxDecoration(
                color: colorScheme
                    .surface,
                borderRadius:
                    BorderRadius.circular(
                      24,
                    ),
                border: Border.all(
                  color:
                      isDark
                      ? AppColors
                            .darkBorder
                      : const Color(
                          0xffE5E7EB,
                        ),
                ),
                boxShadow:
                    isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withAlpha(
                            10,
                          ),
                          blurRadius:
                              18,
                          offset: const Offset(
                            0,
                            8,
                          ),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,
                children: [
                  CircleAvatar(
                    radius:
                        30,
                    backgroundColor:
                        color.withAlpha(
                          24,
                        ),
                    child: Icon(
                      transaction.isIncome
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      color:
                          color,
                      size:
                          30,
                    ),
                  ),
                  const SizedBox(
                    height:
                        16,
                  ),
                  Text(
                    transaction
                        .title,
                    textAlign:
                        TextAlign
                            .center,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w900,
                        ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    '${transaction.isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)}',
                    textAlign:
                        TextAlign
                            .center,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(
                          color:
                              color,
                          fontWeight:
                              FontWeight.w900,
                        ),
                  ),
                  const SizedBox(
                    height:
                        20,
                  ),
                  _DetailRow(
                    label:
                        'Type',
                    value: transaction
                        .type,
                  ),
                  _DetailRow(
                    label:
                        'Category',
                    value: transaction
                        .category,
                  ),
                  _DetailRow(
                    label:
                        'Payment method',
                    value:
                        transaction
                            .paymentMethod
                            .isEmpty
                        ? 'Not set'
                        : transaction.paymentMethod,
                  ),
                  _DetailRow(
                    label:
                        'Note',
                    value:
                        transaction
                            .note
                            .isEmpty
                        ? 'No note'
                        : transaction.note,
                  ),
                  _DetailRow(
                    label:
                        'Created',
                    value: _formatDate(
                      transaction
                          .createdAt,
                    ),
                  ),
                  _DetailRow(
                    label:
                        'Updated',
                    value: _formatDate(
                      transaction
                          .updatedAt,
                    ),
                  ),
                  const SizedBox(
                    height:
                        18,
                  ),
                  FilledButton.icon(
                    onPressed:
                        _isDeleting
                        ? null
                        : () => _confirmDelete(
                            transaction,
                          ),
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          AppColors.red,
                      foregroundColor:
                          Colors.white,
                      minimumSize:
                          const Size.fromHeight(
                            52,
                          ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                    icon:
                        _isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.delete_outline_rounded,
                          ),
                    label: const Text(
                      'Delete',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    TransactionModel
    transaction,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(
                20,
              ),
        ),
        title: const Text(
          'Delete transaction?',
        ),
        content: const Text(
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(
                  context,
                  false,
                ),
            child: const Text(
              'Cancel',
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor:
                  AppColors
                      .red,
            ),
            onPressed: () =>
                Navigator.pop(
                  context,
                  true,
                ),
            child: const Text(
              'Delete',
            ),
          ),
        ],
      ),
    );

    if (confirm != true)
      return;

    final user = FirebaseAuth
        .instance
        .currentUser;
    if (user == null) return;

    setState(
      () =>
          _isDeleting = true,
    );
    try {
      await _transactionService
          .deleteTransaction(
            uid: user.uid,
            transactionId:
                transaction
                    .id,
          );
      await _notificationService
          .createNotification(
            user.uid,
            'Transaction deleted',
            "Your transaction '${transaction.title}' was deleted.",
            'transaction_deleted',
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Transaction deleted.',
          ),
        ),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Could not delete transaction: $error',
          ),
        ),
      );
    } finally {
      if (mounted)
        setState(
          () => _isDeleting =
              false,
        );
    }
  }

  String _formatDate(
    DateTime value,
  ) {
    String two(int n) => n
        .toString()
        .padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} ${two(value.hour)}:${two(value.minute)}';
  }
}

class _DetailRow
    extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
            vertical: 9,
          ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors
                    .littleGrey,
                fontWeight:
                    FontWeight
                        .w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight:
                    FontWeight
                        .w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InvalidTransactionView
    extends StatelessWidget {
  const _InvalidTransactionView();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transaction details',
        ),
      ),
      body: const SafeArea(
        child: Center(
          child: Padding(
            padding:
                EdgeInsets.all(
                  20,
                ),
            child: Text(
              'Transaction details are unavailable.',
            ),
          ),
        ),
      ),
    );
  }
}
