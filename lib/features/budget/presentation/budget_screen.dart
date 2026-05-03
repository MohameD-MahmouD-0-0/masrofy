import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../notifications/data/notification_service.dart';
import '../data/budget_model.dart';
import '../data/budget_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _budgetService = BudgetService();
  final _notificationService = NotificationService();
  late String _monthKey;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _monthKey = BudgetService.currentMonthKey();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      appBar: AppBar(
        title: const Text('Monthly Budget'),
        backgroundColor: const Color(0xffF6F8FB),
      ),
      body: SafeArea(
        child: user == null
            ? const _StateCard(
                icon: Icons.lock_outline_rounded,
                title: 'You are signed out',
                message: 'Please login again to manage your budget.',
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                children: [
                  _MonthSelector(
                    monthKey: _monthKey,
                    onChanged: (value) => setState(() => _monthKey = value),
                  ),
                  const SizedBox(height: 16),
                  StreamBuilder<BudgetModel?>(
                    stream: _budgetService.watchBudgetByMonth(
                      user.uid,
                      _monthKey,
                    ),
                    builder: (context, budgetSnapshot) {
                      if (budgetSnapshot.hasError) {
                        return _StateCard(
                          icon: Icons.error_outline_rounded,
                          title: 'Could not load budget',
                          message: budgetSnapshot.error.toString(),
                        );
                      }

                      if (!budgetSnapshot.hasData &&
                          budgetSnapshot.connectionState ==
                              ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final budget = budgetSnapshot.data;

                      return StreamBuilder<double>(
                        stream: _budgetService.watchMonthlySpent(
                          user.uid,
                          _monthKey,
                        ),
                        builder: (context, spentSnapshot) {
                          if (spentSnapshot.hasError) {
                            return _StateCard(
                              icon: Icons.error_outline_rounded,
                              title: 'Could not calculate spending',
                              message: spentSnapshot.error.toString(),
                            );
                          }

                          final spent = spentSnapshot.data ?? 0;
                          if (budget == null) {
                            return _EmptyBudgetCard(
                              monthKey: _monthKey,
                              spent: spent,
                              onSetBudget: () =>
                                  _openBudgetSheet(uid: user.uid, budget: null),
                            );
                          }

                          final liveBudget = budget.copyWithSpent(spent);
                          return _BudgetDetailsCard(
                            budget: liveBudget,
                            isDeleting: _isDeleting,
                            onEdit: () => _openBudgetSheet(
                              uid: user.uid,
                              budget: liveBudget,
                            ),
                            onDelete: () =>
                                _confirmDelete(user.uid, liveBudget),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _openBudgetSheet({
    required String uid,
    required BudgetModel? budget,
  }) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _BudgetFormSheet(
          monthKey: _monthKey,
          budget: budget,
          onSave: (amount, monthKey) async {
            final isEdit = budget != null;
            if (isEdit) {
              await _budgetService.updateMonthlyBudget(uid, budget.id, amount);
              await _notificationService.createNotification(
                uid,
                'Budget updated',
                'Your monthly budget for ${budget.monthKey} was updated.',
                'budget_updated',
              );
            } else {
              await _budgetService.setMonthlyBudget(uid, amount, monthKey);
              await _notificationService.createNotification(
                uid,
                'Budget set',
                'Your monthly budget for $monthKey was set to ${amount.toStringAsFixed(2)}.',
                'budget_set',
              );
            }
          },
        );
      },
    );

    if (saved == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(budget == null ? 'Budget set.' : 'Budget updated.'),
        ),
      );
    }
  }

  Future<void> _confirmDelete(String uid, BudgetModel budget) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete budget?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    setState(() => _isDeleting = true);

    try {
      await _budgetService.deleteBudget(uid, budget.id);
      await _notificationService.createNotification(
        uid,
        'Budget deleted',
        'Your monthly budget for ${budget.monthKey} was deleted.',
        'budget_deleted',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Budget deleted.')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete budget: $error')),
      );
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }
}

class _BudgetFormSheet extends StatefulWidget {
  const _BudgetFormSheet({
    required this.monthKey,
    required this.budget,
    required this.onSave,
  });

  final String monthKey;
  final BudgetModel? budget;
  final Future<void> Function(double amount, String monthKey) onSave;

  @override
  State<_BudgetFormSheet> createState() => _BudgetFormSheetState();
}

class _BudgetFormSheetState extends State<_BudgetFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late String _monthKey;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEdit => widget.budget != null;

  @override
  void initState() {
    super.initState();
    _monthKey = widget.budget?.monthKey ?? widget.monthKey;
    _amountController = TextEditingController(
      text: widget.budget == null
          ? ''
          : widget.budget!.amount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      _isEdit ? 'Edit Budget' : 'Set Budget',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _monthKey,
                  decoration: const InputDecoration(
                    labelText: 'Month',
                    prefixIcon: Icon(Icons.calendar_month_outlined),
                  ),
                  items: _monthOptions()
                      .map(
                        (month) =>
                            DropdownMenuItem(value: month, child: Text(month)),
                      )
                      .toList(),
                  onChanged: _isEdit || _isLoading
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() => _monthKey = value);
                        },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Budget amount',
                    prefixIcon: Icon(Icons.savings_outlined),
                  ),
                  validator: (value) {
                    final amount = double.tryParse(value?.trim() ?? '');
                    if (amount == null) return 'Amount is required.';
                    if (amount <= 0) return 'Amount must be greater than zero.';
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.littleRed,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.red,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _isLoading ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_rounded),
                  label: Text(_isEdit ? 'Save changes' : 'Set budget'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await widget.onSave(
        double.parse(_amountController.text.trim()),
        _monthKey,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Could not save budget: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<String> _monthOptions() {
    final now = DateTime.now();
    return List.generate(13, (index) {
      final date = DateTime(now.year, now.month - 6 + index);
      return BudgetService.monthKeyFor(date);
    });
  }
}

class _BudgetDetailsCard extends StatelessWidget {
  const _BudgetDetailsCard({
    required this.budget,
    required this.isDeleting,
    required this.onEdit,
    required this.onDelete,
  });

  final BudgetModel budget;
  final bool isDeleting;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(budget.status);
    final percent = (budget.progress.clamp(0, 1) * 100).round();

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const _IconBadge(icon: Icons.savings_outlined),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  budget.monthKey,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              _StatusPill(
                label: _statusLabel(budget.status),
                color: statusColor,
              ),
            ],
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: budget.progress.clamp(0, 1),
              minHeight: 12,
              color: statusColor,
              backgroundColor: const Color(0xffE5E7EB),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '$percent% used',
            style: const TextStyle(
              color: AppColors.littleGrey,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          _MetricRow(label: 'Budgeted', value: _money(budget.amount)),
          _MetricRow(label: 'Spent', value: _money(budget.spent)),
          _MetricRow(
            label: 'Remaining',
            value: _money(budget.remaining),
            color: budget.remaining < 0 ? AppColors.red : AppColors.success,
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onEdit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Budget'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: isDeleting ? null : onDelete,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.red,
              side: const BorderSide(color: AppColors.red),
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: isDeleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_outline_rounded),
            label: const Text('Delete Budget'),
          ),
        ],
      ),
    );
  }
}

class _EmptyBudgetCard extends StatelessWidget {
  const _EmptyBudgetCard({
    required this.monthKey,
    required this.spent,
    required this.onSetBudget,
  });

  final String monthKey;
  final double spent;
  final VoidCallback onSetBudget;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: [
          const _IconBadge(icon: Icons.savings_outlined),
          const SizedBox(height: 14),
          Text(
            'No budget for $monthKey',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Expenses this month: ${_money(spent)}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.littleGrey,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onSetBudget,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Set Budget'),
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({required this.monthKey, required this.onChanged});

  final String monthKey;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final options = List.generate(13, (index) {
      final date = DateTime(now.year, now.month - 6 + index);
      return BudgetService.monthKeyFor(date);
    });

    return _Card(
      child: DropdownButtonFormField<String>(
        value: monthKey,
        decoration: const InputDecoration(
          labelText: 'Month',
          prefixIcon: Icon(Icons.calendar_month_outlined),
        ),
        items: options
            .map((month) => DropdownMenuItem(value: month, child: Text(month)))
            .toList(),
        onChanged: (value) {
          if (value == null) return;
          onChanged(value);
        },
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.littleGrey,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: color ?? AppColors.primaryText,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withAlpha(22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(24),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
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
        child: _Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconBadge(icon: icon),
              const SizedBox(height: 14),
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

Color _statusColor(BudgetStatus status) {
  switch (status) {
    case BudgetStatus.over:
      return AppColors.red;
    case BudgetStatus.near:
      return Colors.orange;
    case BudgetStatus.safe:
      return AppColors.success;
    case BudgetStatus.none:
      return AppColors.littleGrey;
  }
}

String _statusLabel(BudgetStatus status) {
  switch (status) {
    case BudgetStatus.over:
      return 'Over budget';
    case BudgetStatus.near:
      return 'Near limit';
    case BudgetStatus.safe:
      return 'Under budget';
    case BudgetStatus.none:
      return 'No budget';
  }
}

String _money(double value) => value.toStringAsFixed(2);
