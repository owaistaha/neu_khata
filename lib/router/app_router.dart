import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../../features/splash/screens/splash_screen.dart';
import '../../../features/onboarding/screens/onboarding_screen.dart';
import '../../../features/onboarding/screens/register_business_screen.dart';
import '../../../features/dashboard/screens/dashboard_screen.dart';
import '../../../features/customers/screens/customers_screen.dart';
import '../../../features/customers/screens/customer_ledger_screen.dart';
import '../../../features/transactions/screens/add_transaction_screen.dart';
import '../../../features/reports/screens/reports_screen.dart';
import '../../../features/reminders/screens/reminders_screen.dart';
import '../../../features/settings/screens/settings_screen.dart';
import '../../../models/transaction.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

/// Application router with GoRouter.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // ── Splash ──
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

    // ── Onboarding ──
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    // ── Business Registration ──
    GoRoute(
      path: '/register-business',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final fromSettings = state.uri.queryParameters['from'] == 'settings';
        return RegisterBusinessScreen(fromSettings: fromSettings);
      },
    ),

    // ── Main shell (bottom nav tabs) ──
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return AppScaffold(currentPath: state.uri.toString(), child: child);
      },
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: DashboardScreen()),
        ),
        GoRoute(
          path: '/customers',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: CustomersScreen()),
        ),
        GoRoute(
          path: '/reports',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ReportsScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),

    // ── Full-screen routes ──
    GoRoute(
      path: '/add-transaction',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final customerIdStr = state.uri.queryParameters['customerId'];
        final typeStr = state.uri.queryParameters['type'];

        final customerId = customerIdStr != null
            ? int.tryParse(customerIdStr)
            : null;
        final type = typeStr == 'gave'
            ? TransactionType.gave
            : typeStr == 'received'
            ? TransactionType.received
            : null;

        return AddTransactionScreen(customerId: customerId, initialType: type);
      },
    ),
    GoRoute(
      path: '/customers/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) =>
          CustomerLedgerScreen(customerId: state.pathParameters['id'] ?? '0'),
    ),
    GoRoute(
      path: '/reminders',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const RemindersScreen(),
    ),
  ],
);
