import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/transaction_model.dart';
import '../data/transaction_service.dart';
import '../widgets/transaction_card.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _transactionService = TransactionService();
  final _searchController = TextEditingController();
  String _filter = 'all';
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: const Color(0xffF6F8FB),
      ),
      body: SafeArea(
        child: user == null
            ? const _StateCard(
                icon: Icons.lock_outline_rounded,
                title: 'You are signed out',
                message: 'Please login again to view your transactions.',
              )
            : StreamBuilder<List<TransactionModel>>(
                stream: _transactionService.watchTransactions(user.uid),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _StateCard(
                      icon: Icons.error_outline_rounded,
                      title: 'Could not load transactions',
                      message: snapshot.error.toString(),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final filtered = _filterTransactions(snapshot.data!);

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                    children: [
                      _FilterCard(
                        controller: _searchController,
                        filter: _filter,
                        onFilterChanged: (value) =>
                            setState(() => _filter = value),
                        onQueryChanged: (value) =>
                            setState(() => _query = value.trim()),
                      ),
                      const SizedBox(height: 16),
                      if (filtered.isEmpty)
                        const _StateCard(
                          icon: Icons.receipt_long_outlined,
                          title: 'No transactions found',
                          message:
                              'Transactions you add will appear here newest first.',
                        )
                      else
                        ...filtered.map(
                          (transaction) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: TransactionCard(transaction: transaction),
                          ),
                        ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  List<TransactionModel> _filterTransactions(List<TransactionModel> items) {
    final query = _query.toLowerCase();
    return items
        .where((item) {
          final matchesType = _filter == 'all' || item.type == _filter;
          final matchesQuery =
              query.isEmpty ||
              item.title.toLowerCase().contains(query) ||
              item.category.toLowerCase().contains(query);
          return matchesType && matchesQuery;
        })
        .toList(growable: false);
  }
}

class _FilterCard extends StatelessWidget {
  const _FilterCard({
    required this.controller,
    required this.filter,
    required this.onFilterChanged,
    required this.onQueryChanged,
  });

  final TextEditingController controller;
  final String filter;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: onQueryChanged,
            decoration: const InputDecoration(
              hintText: 'Search title or category',
              prefixIcon: Icon(Icons.search_rounded),
            ),
          ),
          const SizedBox(height: 14),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'all', label: Text('All')),
              ButtonSegment(value: 'income', label: Text('Income')),
              ButtonSegment(value: 'expense', label: Text('Expense')),
            ],
            selected: {filter},
            onSelectionChanged: (values) => onFilterChanged(values.first),
            showSelectedIcon: false,
            style: SegmentedButton.styleFrom(
              selectedBackgroundColor: AppColors.primary.withAlpha(24),
              selectedForegroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
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
