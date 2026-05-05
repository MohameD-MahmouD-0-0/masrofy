import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/data/auth_service.dart';
import '../../auth/data/user_profile_service.dart';
import '../../budget/data/budget_model.dart';
import '../../budget/data/budget_service.dart';
import '../../notifications/data/notification_service.dart';
import '../data/transaction_model.dart';
import '../data/transaction_service.dart';
import '../widgets/summary_card.dart';

class DashboardScreen
    extends StatefulWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  State<DashboardScreen>
  createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState
    extends
        State<
          DashboardScreen
        > {
  final _authService =
      AuthService();
  final _profileService =
      UserProfileService();
  final _transactionService =
      TransactionService();
  final _notificationService =
      NotificationService();
  final _budgetService =
      BudgetService();

  Future<void>
  _logout() async {
    await _authService
        .signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final user = FirebaseAuth
        .instance
        .currentUser;

    if (user == null) {
      return const _SignedOutView();
    }

    return Scaffold(
      body: SafeArea(
        child:
            StreamBuilder<
              List<
                TransactionModel
              >
            >(
              stream: _transactionService
                  .watchTransactions(
                    user.uid,
                  ),
              builder:
                  (
                    context,
                    transactionSnapshot,
                  ) {
                    if (transactionSnapshot
                        .hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(
                          20,
                        ),
                        child: _StateMessage(
                          icon:
                              Icons.error_outline_rounded,
                          title:
                              'Could not load transactions',
                          message:
                              transactionSnapshot.error.toString(),
                        ),
                      );
                    }

                    if (!transactionSnapshot
                        .hasData) {
                      return const Center(
                        child:
                            CircularProgressIndicator(),
                      );
                    }

                    final transactions =
                        transactionSnapshot
                            .data!;
                    final summary =
                        TransactionSummary.fromTransactions(
                          transactions,
                        );

                    return StreamBuilder(
                      stream: _profileService.userProfileStream(
                        user.uid,
                      ),
                      builder:
                          (
                            context,
                            profileSnapshot,
                          ) {
                            final profile = profileSnapshot.data?.data();
                            final fullName =
                                profile?['fullName']
                                    as String?;

                            final displayName =
                                (fullName ==
                                        null ||
                                    fullName.trim().isEmpty)
                                ? user.email ??
                                      'there'
                                : fullName.trim();

                            return RefreshIndicator(
                              onRefresh: () async {},
                              child: SingleChildScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  20,
                                  36,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    _DashboardHeader(
                                      displayName: displayName,
                                      email: user.email,
                                      onLogout: _logout,
                                      unreadCountStream: _notificationService.watchUnreadCount(
                                        user.uid,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    _SummarySection(
                                      summary: summary,
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    _MonthlyBudgetSection(
                                      uid: user.uid,
                                      budgetService: _budgetService,
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

class _DashboardHeader
    extends StatelessWidget {
  const _DashboardHeader({
    required this.displayName,
    required this.email,
    required this.onLogout,
    required this.unreadCountStream,
  });

  final String displayName;
  final String? email;
  final VoidCallback onLogout;
  final Stream<int>
  unreadCountStream;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
            22,
          ),
      decoration: BoxDecoration(
        gradient:
            LinearGradient(
              colors: [
                AppColors
                    .primary,
                AppColors
                    .primary
                    .withAlpha(
                      209,
                    ),
              ],
              begin: Alignment
                  .topLeft,
              end: Alignment
                  .bottomRight,
            ),
        borderRadius:
            BorderRadius.circular(
              26,
            ),
        boxShadow: [
          BoxShadow(
            color: AppColors
                .primary
                .withAlpha(
                  42,
                ),
            blurRadius: 22,
            offset:
                const Offset(
                  0,
                  10,
                ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 24,
                backgroundColor:
                    Colors
                        .white,
                child: Icon(
                  Icons
                      .account_balance_wallet_outlined,
                  color: AppColors
                      .primary,
                ),
              ),
              const Spacer(),
              StreamBuilder<
                int
              >(
                stream:
                    unreadCountStream,
                builder:
                    (
                      context,
                      snapshot,
                    ) {
                      final count =
                          snapshot.data ??
                          0;
                      return _NotificationBell(
                        count:
                            count,
                      );
                    },
              ),
              const SizedBox(
                width: 8,
              ),
              IconButton(
                tooltip:
                    'Logout',
                onPressed:
                    onLogout,
                style: IconButton.styleFrom(
                  backgroundColor: Colors
                      .white
                      .withAlpha(
                        41,
                      ),
                  foregroundColor:
                      Colors
                          .white,
                ),
                icon: const Icon(
                  Icons
                      .logout_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            'Welcome back,',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: Colors
                      .white
                      .withAlpha(
                        217,
                      ),
                  fontWeight:
                      FontWeight
                          .w500,
                ),
          ),
          const SizedBox(
            height: 4,
          ),
          Text(
            displayName,
            maxLines: 1,
            overflow:
                TextOverflow
                    .ellipsis,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(
                  color: Colors
                      .white,
                  fontWeight:
                      FontWeight
                          .w900,
                ),
          ),
          if (email !=
              null) ...[
            const SizedBox(
              height: 6,
            ),
            Text(
              email!,
              maxLines: 1,
              overflow:
                  TextOverflow
                      .ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: Colors
                        .white
                        .withAlpha(
                          191,
                        ),
                  ),
            ),
          ],
          const SizedBox(
            height: 16,
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(
                  horizontal:
                      14,
                  vertical:
                      10,
                ),
            decoration: BoxDecoration(
              color: Colors
                  .white
                  .withAlpha(
                    36,
                  ),
              borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
            ),
            child: const Row(
              mainAxisSize:
                  MainAxisSize
                      .min,
              children: [
                Icon(
                  Icons
                      .insights_rounded,
                  color: Colors
                      .white,
                  size: 18,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Your live finance summary',
                  style: TextStyle(
                    color: Colors
                        .white,
                    fontWeight:
                        FontWeight
                            .w700,
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

class _NotificationBell
    extends StatelessWidget {
  const _NotificationBell({
    required this.count,
  });

  final int count;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          tooltip:
              'Notifications',
          onPressed: () =>
              Navigator.pushNamed(
                context,
                AppRoutes
                    .notifications,
              ),
          style: IconButton.styleFrom(
            backgroundColor:
                Colors.white
                    .withAlpha(
                      41,
                    ),
            foregroundColor:
                Colors.white,
          ),
          icon: const Icon(
            Icons
                .notifications_none_rounded,
          ),
        ),
        if (count > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              constraints:
                  const BoxConstraints(
                    minWidth:
                        18,
                    minHeight:
                        18,
                  ),
              padding:
                  const EdgeInsets.symmetric(
                    horizontal:
                        5,
                  ),
              decoration: BoxDecoration(
                color:
                    AppColors
                        .red,
                borderRadius:
                    BorderRadius.circular(
                      999,
                    ),
                border: Border.all(
                  color: Colors
                      .white,
                  width: 1.5,
                ),
              ),
              alignment:
                  Alignment
                      .center,
              child: Text(
                count > 99
                    ? '99+'
                    : '$count',
                style: const TextStyle(
                  color: Colors
                      .white,
                  fontSize:
                      10,
                  fontWeight:
                      FontWeight
                          .w900,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SummarySection
    extends StatelessWidget {
  const _SummarySection({
    required this.summary,
  });

  final TransactionSummary
  summary;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Column(
      children: [
        SummaryCard(
          title: 'Income',
          amount:
              summary.income,
          icon: Icons
              .trending_up_rounded,
          color: AppColors
              .success,
        ),
        const SizedBox(
          height: 12,
        ),
        SummaryCard(
          title: 'Expenses',
          amount: summary
              .expenses,
          icon: Icons
              .trending_down_rounded,
          color:
              AppColors.red,
        ),
        const SizedBox(
          height: 12,
        ),
        SummaryCard(
          title: 'Balance',
          amount:
              summary.balance,
          icon: Icons
              .account_balance_wallet_outlined,
          color: AppColors
              .primary,
        ),
      ],
    );
  }
}

class _MonthlyBudgetSection
    extends StatelessWidget {
  const _MonthlyBudgetSection({
    required this.uid,
    required this.budgetService,
  });

  final String uid;
  final BudgetService
  budgetService;

  @override
  Widget build(
    BuildContext context,
  ) {
    final monthKey =
        BudgetService.currentMonthKey();

    return StreamBuilder<
      BudgetModel?
    >(
      stream: budgetService
          .watchCurrentMonthBudget(
            uid,
          ),
      builder: (context, budgetSnapshot) {
        if (budgetSnapshot
            .hasError) {
          return _BudgetPromptCard(
            title:
                'Budget unavailable',
            message:
                'Manage Budget',
            onTap: () =>
                Navigator.pushNamed(
                  context,
                  AppRoutes
                      .budget,
                ),
          );
        }

        return StreamBuilder<
          double
        >(
          stream: budgetService
              .watchMonthlySpent(
                uid,
                monthKey,
              ),
          builder:
              (
                context,
                spentSnapshot,
              ) {
                final spent =
                    spentSnapshot
                        .data ??
                    0;
                final budget =
                    budgetSnapshot
                        .data
                        ?.copyWithSpent(
                          spent,
                        );

                if (budget ==
                    null) {
                  return _BudgetPromptCard(
                    title:
                        'Set your monthly budget',
                    message:
                        'Spent this month: ${spent.toStringAsFixed(2)}',
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes
                          .budget,
                    ),
                  );
                }

                return _DashboardBudgetCard(
                  budget:
                      budget,
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes
                        .budget,
                  ),
                );
              },
        );
      },
    );
  }
}

class _DashboardBudgetCard
    extends StatelessWidget {
  const _DashboardBudgetCard({
    required this.budget,
    required this.onTap,
  });

  final BudgetModel budget;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
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
        budget.status ==
            BudgetStatus.over
        ? AppColors.red
        : budget.status ==
              BudgetStatus
                  .near
        ? Colors.orange
        : AppColors.success;

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
            20,
          ),
      child: Container(
        padding:
            const EdgeInsets.all(
              18,
            ),
        decoration: BoxDecoration(
          color: colorScheme
              .surface,
          borderRadius:
              BorderRadius.circular(
                20,
              ),
          border: Border.all(
            color: isDark
                ? AppColors
                      .darkBorder
                : const Color(
                    0xffE5E7EB,
                  ),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors
                        .black
                        .withAlpha(
                          10,
                        ),
                    blurRadius:
                        18,
                    offset:
                        const Offset(
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
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors
                        .primary
                        .withAlpha(
                          22,
                        ),
                    shape: BoxShape
                        .circle,
                  ),
                  child: const Icon(
                    Icons
                        .savings_outlined,
                    color: AppColors
                        .primary,
                  ),
                ),
                const SizedBox(
                  width: 12,
                ),
                Expanded(
                  child: Text(
                    'Monthly Budget',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(
                          fontWeight:
                              FontWeight.w900,
                        ),
                  ),
                ),
                TextButton(
                  onPressed:
                      onTap,
                  child: const Text(
                    'Manage',
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 14,
            ),
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(
                    999,
                  ),
              child: LinearProgressIndicator(
                value: budget
                    .progress
                    .clamp(
                      0,
                      1,
                    ),
                minHeight: 10,
                color: color,
                backgroundColor:
                    isDark
                    ? AppColors
                          .darkBorder
                    : const Color(
                        0xffE5E7EB,
                      ),
              ),
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              children: [
                _BudgetMiniMetric(
                  label:
                      'Budget',
                  value: budget
                      .amount
                      .toStringAsFixed(
                        2,
                      ),
                ),
                _BudgetMiniMetric(
                  label:
                      'Spent',
                  value: budget
                      .spent
                      .toStringAsFixed(
                        2,
                      ),
                ),
                _BudgetMiniMetric(
                  label:
                      'Left',
                  value: budget
                      .remaining
                      .toStringAsFixed(
                        2,
                      ),
                  color:
                      budget.remaining <
                          0
                      ? AppColors
                            .red
                      : AppColors
                            .success,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetPromptCard
    extends StatelessWidget {
  const _BudgetPromptCard({
    required this.title,
    required this.message,
    required this.onTap,
  });

  final String title;
  final String message;
  final VoidCallback onTap;

  @override
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(
          context,
        ).colorScheme;
    final isDark =
        Theme.of(
          context,
        ).brightness ==
        Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
            20,
          ),
      child: Container(
        padding:
            const EdgeInsets.all(
              18,
            ),
        decoration: BoxDecoration(
          color: colorScheme
              .surface,
          borderRadius:
              BorderRadius.circular(
                20,
              ),
          border: Border.all(
            color: isDark
                ? AppColors
                      .darkBorder
                : const Color(
                    0xffE5E7EB,
                  ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors
                    .primary
                    .withAlpha(
                      22,
                    ),
                shape: BoxShape
                    .circle,
              ),
              child: const Icon(
                Icons
                    .savings_outlined,
                color: AppColors
                    .primary,
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w900,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    message,
                    style: const TextStyle(
                      color: AppColors
                          .littleGrey,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons
                  .chevron_right_rounded,
              color: AppColors
                  .littleGrey,
            ),
          ],
        ),
      ),
    );
  }
}

class _BudgetMiniMetric
    extends StatelessWidget {
  const _BudgetMiniMetric({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors
                  .littleGrey,
              fontSize: 12,
              fontWeight:
                  FontWeight
                      .w700,
            ),
          ),
          const SizedBox(
            height: 3,
          ),
          Text(
            value,
            maxLines: 1,
            overflow:
                TextOverflow
                    .ellipsis,
            style: TextStyle(
              color:
                  color ??
                  Theme.of(
                        context,
                      )
                      .colorScheme
                      .onSurface,
              fontWeight:
                  FontWeight
                      .w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignedOutView
    extends StatelessWidget {
  const _SignedOutView();

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(
                  24,
                ),
            child: _StateMessage(
              icon: Icons
                  .lock_outline_rounded,
              title:
                  'You are signed out',
              message:
                  'Please login again to continue using Masrofy.',
              action: FilledButton(
                onPressed: () =>
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes
                          .login,
                      (_) =>
                          false,
                    ),
                child: const Text(
                  'Go to login',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StateMessage
    extends StatelessWidget {
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
  Widget build(
    BuildContext context,
  ) {
    final colorScheme =
        Theme.of(
          context,
        ).colorScheme;
    final isDark =
        Theme.of(
          context,
        ).brightness ==
        Brightness.dark;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
            24,
          ),
      decoration: BoxDecoration(
        color: colorScheme
            .surface,
        borderRadius:
            BorderRadius.circular(
              24,
            ),
        border: Border.all(
          color: isDark
              ? AppColors
                    .darkBorder
              : const Color(
                  0xffE5E7EB,
                ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors
                      .black
                      .withAlpha(
                        10,
                      ),
                  blurRadius:
                      18,
                  offset:
                      const Offset(
                        0,
                        8,
                      ),
                ),
              ],
      ),
      child: Column(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors
                  .primary
                  .withAlpha(
                    26,
                  ),
              shape: BoxShape
                  .circle,
            ),
            child: Icon(
              icon,
              size: 32,
              color: AppColors
                  .primary,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            title,
            textAlign:
                TextAlign
                    .center,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight:
                      FontWeight
                          .w900,
                ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            message,
            textAlign:
                TextAlign
                    .center,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(
                  color: AppColors
                      .littleGrey,
                  height: 1.4,
                ),
          ),
          if (action !=
              null) ...[
            const SizedBox(
              height: 18,
            ),
            action!,
          ],
        ],
      ),
    );
  }
}
