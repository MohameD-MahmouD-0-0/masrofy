import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../notifications/data/notification_service.dart';
import '../data/transaction_model.dart';
import '../data/transaction_service.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({super.key});

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _transactionService = TransactionService();
  final _notificationService = NotificationService();

  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _categoryController;
  late final TextEditingController _noteController;
  late final TextEditingController _paymentMethodController;

  String _type = 'expense';
  bool _isReady = false;
  bool _isLoading = false;
  String? _errorMessage;
  TransactionModel? _transaction;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isReady) return;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is TransactionModel) {
      _transaction = args;
      _titleController = TextEditingController(text: args.title);
      _amountController = TextEditingController(
        text: args.amount.toStringAsFixed(2),
      );
      _categoryController = TextEditingController(text: args.category);
      _noteController = TextEditingController(text: args.note);
      _paymentMethodController = TextEditingController(
        text: args.paymentMethod,
      );
      _type = args.type == 'income' ? 'income' : 'expense';
    } else {
      _titleController = TextEditingController();
      _amountController = TextEditingController();
      _categoryController = TextEditingController();
      _noteController = TextEditingController();
      _paymentMethodController = TextEditingController();
    }
    _isReady = true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    _paymentMethodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_transaction == null) {
      return Scaffold(
        backgroundColor: const Color(0xffF6F8FB),
        appBar: AppBar(
          title: const Text('Edit Transaction'),
          backgroundColor: const Color(0xffF6F8FB),
        ),
        body: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Transaction details are unavailable.'),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      appBar: AppBar(
        title: const Text('Edit Transaction'),
        backgroundColor: const Color(0xffF6F8FB),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          child: Container(
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    controller: _titleController,
                    label: 'Title',
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Title is required.'
                        : null,
                  ),
                  const SizedBox(height: 16),
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
                      DropdownMenuItem(value: 'income', child: Text('Income')),
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
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _categoryController,
                    label: 'Category',
                    prefixIcon: const Icon(Icons.label_outline_rounded),
                    textInputAction: TextInputAction.next,
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Category is required.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _paymentMethodController,
                    label: 'Payment method',
                    hintText: 'Optional',
                    prefixIcon: const Icon(Icons.wallet_outlined),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _noteController,
                    label: 'Note',
                    hintText: 'Optional',
                    prefixIcon: const Icon(Icons.notes_rounded),
                    maxLines: 3,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
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
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: 'Save changes',
                    icon: Icons.save_rounded,
                    isLoading: _isLoading,
                    onPressed: _save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final transaction = _transaction;
    if (user == null || transaction == null) {
      setState(() => _errorMessage = 'Please login again to continue.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _transactionService.updateTransaction(
        uid: user.uid,
        transactionId: transaction.id,
        title: _titleController.text,
        amount: double.parse(_amountController.text.trim()),
        type: _type,
        category: _categoryController.text,
        note: _noteController.text,
        paymentMethod: _paymentMethodController.text,
      );
      await _notificationService.createNotification(
        user.uid,
        'Transaction updated',
        "Your transaction '${_titleController.text.trim()}' was updated successfully.",
        'transaction_updated',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Transaction updated.')));
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Could not update transaction: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String? _validateAmount(String? value) {
    final amount = double.tryParse(value?.trim() ?? '');
    if (amount == null) return 'Enter a valid amount.';
    if (amount <= 0) return 'Amount must be greater than zero.';
    return null;
  }
}
