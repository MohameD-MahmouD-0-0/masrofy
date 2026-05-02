import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/data/user_profile_service.dart';
import '../data/transaction_model.dart';
import '../data/transaction_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _authService = AuthService();
  final _profileService = UserProfileService();
  final _transactionService = TransactionService();

  Future<void> _logout() async {
    await _authService.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const _SignedOutView();
    }

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.addTransaction),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<TransactionModel>>(
          stream: _transactionService.watchTransactions(user.uid),
          builder: (context, transactionSnapshot) {
            if (transactionSnapshot.hasError) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: _StateMessage(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not load transactions',
                  message: transactionSnapshot.error.toString(),
                ),
              );
            }

            if (!transactionSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final transactions = transactionSnapshot.data!;
            final summary = TransactionSummary.fromTransactions(transactions);

            return StreamBuilder(
              stream: _profileService.userProfileStream(user.uid),
              builder: (context, profileSnapshot) {
                final profile = profileSnapshot.data?.data();
                final fullName = profile?['fullName'] as String?;

                final displayName =
                    (fullName == null || fullName.trim().isEmpty)
                    ? user.email ?? 'there'
                    : fullName.trim();

                return RefreshIndicator(
                  onRefresh: () async {},
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 112),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _DashboardHeader(
                          displayName: displayName,
                          email: user.email,
                          onLogout: _logout,
                        ),
                        const SizedBox(height: 20),
                        _SummarySection(summary: summary),
                        const SizedBox(height: 24),
                        _SectionHeader(
                          title: 'Recent transactions',
                          count: transactions.length,
                        ),
                        const SizedBox(height: 12),
                        if (transactions.isEmpty)
                          const _StateMessage(
                            icon: Icons.receipt_long_outlined,
                            title: 'No transactions yet',
                            message:
                                'Add your first income or expense to start tracking your money.',
                          )
                        else
                          ...transactions
                              .take(12)
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: TransactionCard(transaction: item),
                                ),
                              ),
                      ],
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
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.displayName,
    required this.email,
    required this.onLogout,
  });

  final String displayName;
  final String? email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withAlpha(209)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(42),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Logout',
                onPressed: onLogout,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withAlpha(41),
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.logout_rounded),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Welcome back,',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withAlpha(217),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (email != null) ...[
            const SizedBox(height: 6),
            Text(
              email!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white.withAlpha(191),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(36),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.insights_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Your live finance summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.summary});

  final TransactionSummary summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SummaryCard(
          title: 'Income',
          amount: summary.income,
          icon: Icons.trending_up_rounded,
          color: AppColors.success,
        ),
        const SizedBox(height: 12),
        SummaryCard(
          title: 'Expenses',
          amount: summary.expenses,
          icon: Icons.trending_down_rounded,
          color: AppColors.red,
        ),
        const SizedBox(height: 12),
        SummaryCard(
          title: 'Balance',
          amount: summary.balance,
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.primary,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color(0xffE5E7EB)),
          ),
          child: Text(
            '$count items',
            style: const TextStyle(
              color: AppColors.littleGrey,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _SignedOutView extends StatelessWidget {
  const _SignedOutView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: _StateMessage(
              icon: Icons.lock_outline_rounded,
              title: 'You are signed out',
              message: 'Please login again to continue using Masrofy.',
              action: FilledButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                ),
                child: const Text('Go to login'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.littleGrey,
              height: 1.4,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    );
  }
}
