import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/transaction_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _noteController = TextEditingController();
  final _transactionService = TransactionService();

  String _type = 'expense';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(
        () => _errorMessage = 'Please login before adding transactions.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _transactionService.addTransaction(
        uid: user.uid,
        title: _titleController.text,
        amount: double.parse(_amountController.text.trim()),
        type: _type,
        category: _categoryController.text,
        note: _noteController.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaction added.')));
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Could not save transaction: $error');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      appBar: AppBar(
        title: const Text('Add Transaction'),
        backgroundColor: const Color(0xffF6F8FB),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final formWidth = constraints.maxWidth > 600
                ? 560.0
                : constraints.maxWidth;

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
              child: Center(
                child: SizedBox(
                  width: formWidth,
                  child: _FormCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _FormSectionTitle(
                            title: 'Transaction details',
                            icon: Icons.receipt_long_outlined,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _titleController,
                            label: 'Title',
                            prefixIcon: const Icon(Icons.edit_note_rounded),
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Title is required.'
                                : null,
                          ),
                          const SizedBox(height: 24),
                          const _FormSectionTitle(
                            title: 'Amount and type',
                            icon: Icons.payments_outlined,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _amountController,
                            label: 'Amount',
                            prefixIcon: const Icon(
                              Icons.account_balance_wallet_outlined,
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: _validateAmount,
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _type,
                            decoration: const InputDecoration(
                              labelText: 'Type',
                              prefixIcon: Icon(Icons.swap_vert_rounded),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'income',
                                child: Text('Income'),
                              ),
                              DropdownMenuItem(
                                value: 'expense',
                                child: Text('Expense'),
                              ),
                            ],
                            onChanged: _isLoading
                                ? null
                                : (value) {
                                    if (value == null) return;
                                    setState(() => _type = value);
                                  },
                          ),
                          const SizedBox(height: 24),
                          const _FormSectionTitle(
                            title: 'Category and note',
                            icon: Icons.category_outlined,
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _categoryController,
                            label: 'Category',
                            hintText: 'Food, salary, transport...',
                            prefixIcon: const Icon(Icons.label_outline_rounded),
                            textInputAction: TextInputAction.next,
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Category is required.'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _noteController,
                            label: 'Note',
                            hintText: 'Optional',
                            prefixIcon: const Icon(Icons.notes_rounded),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 18),
                          if (_errorMessage != null) ...[
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
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          PrimaryButton(
                            label: 'Save transaction',
                            icon: Icons.check_rounded,
                            isLoading: _isLoading,
                            onPressed: _saveTransaction,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String? _validateAmount(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    if (amount == null) return 'Enter a valid amount.';
    if (amount <= 0) return 'Amount must be greater than zero.';
    return null;
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xffE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FormSectionTitle extends StatelessWidget {
  const _FormSectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(22),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 19),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}
