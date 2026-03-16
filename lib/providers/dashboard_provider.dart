import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction.dart';
import 'customer_provider.dart';
import 'transaction_provider.dart';

/// Aggregated dashboard data computed from live streams.
class DashboardData {
  const DashboardData({
    required this.totalReceivable,
    required this.totalPayable,
    required this.customerCount,
    required this.todayTransactions,
  });

  final double totalReceivable;
  final double totalPayable;
  final int customerCount;
  final List<TransactionWithCustomer> todayTransactions;

  double get netBalance => totalReceivable - totalPayable;
}

/// A transaction paired with its customer name for display.
class TransactionWithCustomer {
  const TransactionWithCustomer({
    required this.transaction,
    required this.customerName,
  });
  final Transaction transaction;
  final String customerName;
}

/// Provides live aggregated dashboard data.
final dashboardProvider = Provider<AsyncValue<DashboardData>>((ref) {
  final customersAsync = ref.watch(customersProvider);
  final txnAsync = ref.watch(allTransactionsProvider);

  return customersAsync.when(
    data: (customers) {
      return txnAsync.when(
        data: (transactions) {
          double totalReceivable = 0;
          double totalPayable = 0;

          // Build customer name lookup
          final customerMap = <int, String>{};
          for (final c in customers) {
            customerMap[c.id] = c.name;
            if (c.balance > 0) {
              totalReceivable += c.balance;
            } else {
              totalPayable += c.balance.abs();
            }
          }

          // Today's transactions
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          final todayTxns = transactions
              .where((t) => t.date.isAfter(todayStart))
              .map((t) => TransactionWithCustomer(
                    transaction: t,
                    customerName: customerMap[t.customerId] ?? 'Unknown',
                  ))
              .toList();

          return AsyncValue.data(DashboardData(
            totalReceivable: totalReceivable,
            totalPayable: totalPayable,
            customerCount: customers.length,
            todayTransactions: todayTxns,
          ));
        },
        loading: () => const AsyncValue.loading(),
        error: (e, st) => AsyncValue.error(e, st),
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});
