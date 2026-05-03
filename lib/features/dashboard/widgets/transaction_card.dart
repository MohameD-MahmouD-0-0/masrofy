import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/transaction_model.dart';
import '../data/transaction_service.dart';
import '../presentation/add_transaction_screen.dart';

class TransactionCard
    extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
  });

  final TransactionModel
  transaction;

  Future<void> _confirmDelete(
    BuildContext context,
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
        title: const Row(
          children: [
            Icon(
              Icons
                  .delete_outline_rounded,
              color: AppColors
                  .red,
            ),
            SizedBox(
              width: 8,
            ),
            Text(
              'Delete Transaction',
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
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
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
              ),
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

    if (confirm != true ||
        !context.mounted)
      return;

    final user = FirebaseAuth
        .instance
        .currentUser;
    if (user == null) return;

    try {
      await TransactionService()
          .deleteTransaction(
            uid: user.uid,
            transactionId:
                transaction
                    .id,
          );
      if (!context.mounted)
        return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Transaction deleted.',
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted)
        return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            'Could not delete: $e',
          ),
        ),
      );
    }
  }

  void _openEdit(
    BuildContext context,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            AddTransactionScreen(
              transaction:
                  transaction,
            ),
      ),
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final color =
        transaction.isIncome
        ? AppColors.success
        : AppColors.red;
    final sign =
        transaction.isIncome
        ? '+'
        : '-';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
              18,
            ),
        side:
            const BorderSide(
              color: Color(
                0xffE5E7EB,
              ),
            ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
        leading: CircleAvatar(
          backgroundColor:
              color.withAlpha(
                24,
              ),
          child: Icon(
            transaction
                    .isIncome
                ? Icons
                      .arrow_downward
                : Icons
                      .arrow_upward,
            color: color,
          ),
        ),
        title: Text(
          transaction.title,
          maxLines: 1,
          overflow:
              TextOverflow
                  .ellipsis,
          style:
              const TextStyle(
                fontWeight:
                    FontWeight
                        .w700,
              ),
        ),
        subtitle: Text(
          transaction
              .category,
          maxLines: 1,
          overflow:
              TextOverflow
                  .ellipsis,
        ),
        trailing: Row(
          mainAxisSize:
              MainAxisSize
                  .min,
          children: [
            Text(
              '$sign${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: color,
                fontWeight:
                    FontWeight
                        .w800,
              ),
            ),
            const SizedBox(
              width: 4,
            ),
            PopupMenuButton<
              String
            >(
              icon: const Icon(
                Icons
                    .more_vert_rounded,
                size: 20,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
              ),
              onSelected: (value) {
                if (value ==
                    'edit')
                  _openEdit(
                    context,
                  );
                if (value ==
                    'delete')
                  _confirmDelete(
                    context,
                  );
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value:
                      'edit',
                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .edit_outlined,
                        size:
                            18,
                      ),
                      SizedBox(
                        width:
                            10,
                      ),
                      Text(
                        'Edit',
                      ),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value:
                      'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons
                            .delete_outline_rounded,
                        size:
                            18,
                        color:
                            AppColors.red,
                      ),
                      SizedBox(
                        width:
                            10,
                      ),
                      Text(
                        'Delete',
                        style: TextStyle(
                          color:
                              AppColors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
