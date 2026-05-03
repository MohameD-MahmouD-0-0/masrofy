import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../data/transaction_model.dart';
import '../data/transaction_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key, this.transaction});

  // إذا اتبعت transaction معناها وضع تعديل، وإذا null معناها إضافة جديدة
  final TransactionModel? transaction;

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  final _transactionService = TransactionService();

  late String _type;
  String? _selectedCategory;
  String? _selectedPaymentMethod;
  bool _isLoading = false;
  String? _errorMessage;

  bool get _isEditMode => widget.transaction != null;

  final List<Map<String, dynamic>> _categories = [
    {'label': 'Food & Drinks', 'icon': Icons.restaurant},
    {'label': 'Transport', 'icon': Icons.directions_car},
    {'label': 'Shopping', 'icon': Icons.shopping_bag},
    {'label': 'Salary', 'icon': Icons.attach_money},
    {'label': 'Healthcare', 'icon': Icons.local_hospital},
    {'label': 'Education', 'icon': Icons.school},
    {'label': 'Entertainment', 'icon': Icons.movie},
    {'label': 'Bills & Utilities', 'icon': Icons.receipt_long},
    {'label': 'Rent', 'icon': Icons.home},
    {'label': 'Travel', 'icon': Icons.flight},
    {'label': 'Gym & Sports', 'icon': Icons.fitness_center},
    {'label': 'Gifts', 'icon': Icons.card_giftcard},
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {'label': 'Cash', 'icon': Icons.money},
    {'label': 'Card', 'icon': Icons.credit_card},
    {'label': 'Bank Transfer', 'icon': Icons.account_balance},
  ];

  @override
  void initState() {
    super.initState();
    final t = widget.transaction;

    _titleController = TextEditingController(text: t?.title ?? '');
    _amountController = TextEditingController(
      text: t != null ? t.amount.toString() : '',
    );
    _noteController = TextEditingController(text: t?.note ?? '');
    _type = t?.type ?? 'expense';

    // لو الـ category أو paymentMethod موجودة في الـ transaction
    // وماكانتش في الليست، نضيفهم عشان الـ dropdown يقدر يعرضهم
    if (t != null) {
      if (t.category.isNotEmpty &&
          !_categories.any((c) => c['label'] == t.category)) {
        _categories.add({'label': t.category, 'icon': Icons.label_rounded});
      }
      _selectedCategory = t.category.isNotEmpty ? t.category : null;

      if (t.paymentMethod.isNotEmpty &&
          !_paymentMethods.any((m) => m['label'] == t.paymentMethod)) {
        _paymentMethods
            .add({'label': t.paymentMethod, 'icon': Icons.payment_rounded});
      }
      _selectedPaymentMethod =
          t.paymentMethod.isNotEmpty ? t.paymentMethod : null;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _errorMessage = 'Please login before adding transactions.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (_isEditMode) {
        await _transactionService.updateTransaction(
          uid: user.uid,
          transactionId: widget.transaction!.id,
          title: _titleController.text,
          amount: double.parse(_amountController.text.trim()),
          type: _type,
          category: _selectedCategory ?? '',
          note: _noteController.text,
          paymentMethod: _selectedPaymentMethod ?? '',
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction updated.')),
        );
      } else {
        await _transactionService.addTransaction(
          uid: user.uid,
          title: _titleController.text,
          amount: double.parse(_amountController.text.trim()),
          type: _type,
          category: _selectedCategory ?? '',
          note: _noteController.text,
          paymentMethod: _selectedPaymentMethod ?? '',
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added.')),
        );
      }
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Could not save transaction: $error');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showAddCategoryDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('New Category'),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. Subscriptions',
              prefixIcon: const Icon(Icons.label_outline_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a category name.';
              }
              final exists = _categories.any(
                (c) =>
                    (c['label'] as String).toLowerCase() ==
                    value.trim().toLowerCase(),
              );
              if (exists) return 'Category already exists.';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final newLabel = controller.text.trim();
              setState(() {
                _categories.add({
                  'label': newLabel,
                  'icon': Icons.label_rounded,
                });
                _selectedCategory = newLabel;
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddPaymentMethodDialog() async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.add_circle_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'New Payment Method',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              hintText: 'e.g. PayPal',
              prefixIcon: const Icon(Icons.wallet_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a payment method name.';
              }
              final exists = _paymentMethods.any(
                (m) =>
                    (m['label'] as String).toLowerCase() ==
                    value.trim().toLowerCase(),
              );
              if (exists) return 'Payment method already exists.';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              final newLabel = controller.text.trim();
              setState(() {
                _paymentMethods.add({
                  'label': newLabel,
                  'icon': Icons.payment_rounded,
                });
                _selectedPaymentMethod = newLabel;
              });
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Transaction' : 'Add Transaction'),
        backgroundColor: const Color(0xffF6F8FB),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final formWidth =
                constraints.maxWidth > 600 ? 560.0 : constraints.maxWidth;

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
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Category',
                                    hintText: 'Food, salary, transport...',
                                    prefixIcon:
                                        Icon(Icons.label_outline_rounded),
                                  ),
                                  items: _categories.map((cat) {
                                    return DropdownMenuItem<String>(
                                      value: cat['label'] as String,
                                      child: Row(
                                        children: [
                                          Icon(
                                            cat['icon'] as IconData,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(cat['label'] as String),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _isLoading
                                      ? null
                                      : (value) => setState(
                                            () => _selectedCategory = value,
                                          ),
                                  validator: (value) => value == null
                                      ? 'Category is required.'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              _AddButton(
                                onTap: _isLoading
                                    ? null
                                    : _showAddCategoryDialog,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _noteController,
                            label: 'Note',
                            hintText: 'Optional',
                            prefixIcon: const Icon(Icons.notes_rounded),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                          const _FormSectionTitle(
                            title: 'Payment method',
                            icon: Icons.payment_outlined,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedPaymentMethod,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Payment Method',
                                    prefixIcon: Icon(Icons.wallet_outlined),
                                  ),
                                  items: _paymentMethods.map((method) {
                                    return DropdownMenuItem<String>(
                                      value: method['label'] as String,
                                      child: Row(
                                        children: [
                                          Icon(
                                            method['icon'] as IconData,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(method['label'] as String),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: _isLoading
                                      ? null
                                      : (value) => setState(
                                            () =>
                                                _selectedPaymentMethod = value,
                                          ),
                                  validator: (value) => value == null
                                      ? 'Payment method is required.'
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 10),
                              _AddButton(
                                onTap: _isLoading
                                    ? null
                                    : _showAddPaymentMethodDialog,
                              ),
                            ],
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
                            label: _isEditMode
                                ? 'Save changes'
                                : 'Save transaction',
                            icon: _isEditMode
                                ? Icons.save_rounded
                                : Icons.check_rounded,
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

// زر الـ + المشترك بين الـ category والـ payment method
class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Add new',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppColors.primary.withAlpha(22),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withAlpha(60)),
          ),
          child: const Icon(Icons.add_rounded, color: AppColors.primary),
        ),
      ),
    );
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
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}