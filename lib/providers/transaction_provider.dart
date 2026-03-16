import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import 'database_provider.dart';

/// Provides all transactions for a given customer, sorted by date descending.
final transactionsByCustomerProvider =
    StreamProvider.family<List<Transaction>, int>((ref, customerId) {
      final isar = ref.watch(isarProvider);
      return isar.transactions
          .filter()
          .customerIdEqualTo(customerId)
          .sortByDateDesc()
          .watch(fireImmediately: true);
    });

/// Provides all transactions across all customers, newest first.
final allTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.transactions.where().sortByDateDesc().watch(
    fireImmediately: true,
  );
});

/// Notifier that handles transaction CRUD and balance updates.
final transactionNotifierProvider = NotifierProvider<TransactionNotifier, void>(
  TransactionNotifier.new,
);

class TransactionNotifier extends Notifier<void> {
  @override
  void build() {}

  Isar get _isar => ref.read(isarProvider);

  /// Add a transaction and update the customer's running balance.
  Future<void> addTransaction({
    required int customerId,
    required double amount,
    required TransactionType type,
    String? category,
    String? description,
    DateTime? date,
  }) async {
    final txn = Transaction()
      ..customerId = customerId
      ..amount = amount
      ..type = type
      ..category = category
      ..description = description
      ..date = date ?? DateTime.now()
      ..createdAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.transactions.put(txn);

      // Update customer balance
      final customer = await _isar.customers.get(customerId);
      if (customer != null) {
        if (type == TransactionType.gave) {
          customer.balance += amount; // they owe you more
        } else {
          customer.balance -= amount; // they paid you back
        }
        customer.updatedAt = DateTime.now();
        await _isar.customers.put(customer);
      }
    });
  }

  /// Delete a transaction and reverse the balance impact.
  Future<void> deleteTransaction(Transaction txn) async {
    await _isar.writeTxn(() async {
      final customer = await _isar.customers.get(txn.customerId);
      if (customer != null) {
        if (txn.type == TransactionType.gave) {
          customer.balance -= txn.amount;
        } else {
          customer.balance += txn.amount;
        }
        customer.updatedAt = DateTime.now();
        await _isar.customers.put(customer);
      }
      await _isar.transactions.delete(txn.id);
    });
  }
}
