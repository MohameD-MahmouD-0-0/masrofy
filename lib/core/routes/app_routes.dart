import 'package:flutter/material.dart';

import '../../core/navigation/main_navigation_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/budget/presentation/budget_screen.dart';
import '../../features/dashboard/presentation/add_transaction_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/dashboard/presentation/edit_transaction_screen.dart';
import '../../features/dashboard/presentation/transaction_details_screen.dart';
import '../../features/dashboard/presentation/transactions_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const mainNavigation = '/main';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const dashboard = '/dashboard';
  static const addTransaction = '/add-transaction';
  static const transactions = '/transactions';
  static const transactionDetails = '/transaction-details';
  static const editTransaction = '/edit-transaction';
  static const notifications = '/notifications';
  static const budget = '/budget';
  static const reports = '/reports';
  static const profile = '/profile';

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    mainNavigation: (_) => const MainNavigationScreen(),
    login: (_) => const LoginScreen(),
    register: (_) => const RegisterScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    dashboard: (_) => const DashboardScreen(),
    addTransaction: (_) => const AddTransactionScreen(),
    transactions: (_) => const TransactionsScreen(),
    transactionDetails: (_) => const TransactionDetailsScreen(),
    editTransaction: (_) => const EditTransactionScreen(),
    notifications: (_) => const NotificationsScreen(),
    budget: (_) => const BudgetScreen(),
    reports: (_) => const ReportsScreen(),
    profile: (_) => const ProfileScreen(),
  };
}
