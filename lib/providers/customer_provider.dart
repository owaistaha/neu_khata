import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../models/customer.dart';
import '../models/transaction.dart';
import 'database_provider.dart';

/// Provides a live list of all customers, sorted by most recently updated.
final customersProvider = StreamProvider<List<Customer>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.customers
      .where()
      .sortByUpdatedAtDesc()
      .watch(fireImmediately: true);
});

/// Provides a single customer by [id].
final customerByIdProvider =
    FutureProvider.family<Customer?, int>((ref, id) async {
  final isar = ref.watch(isarProvider);
  return isar.customers.get(id);
});

/// Notifier that handles customer CRUD operations.
final customerNotifierProvider =
    NotifierProvider<CustomerNotifier, void>(CustomerNotifier.new);

class CustomerNotifier extends Notifier<void> {
  @override
  void build() {}

  Isar get _isar => ref.read(isarProvider);

  /// Create a new customer.
  Future<int> addCustomer({
    required String name,
    String? phone,
    String? imageUrl,
  }) async {
    final customer = Customer()
      ..name = name
      ..phone = phone
      ..imageUrl = imageUrl
      ..balance = 0
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    return _isar.writeTxn(() => _isar.customers.put(customer));
  }

  /// Update an existing customer's info.
  Future<void> updateCustomer(Customer customer) async {
    customer.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.customers.put(customer));
  }

  /// Delete a customer and all their transactions.
  Future<void> deleteCustomer(int id) async {
    await _isar.writeTxn(() async {
      // Remove associated transactions first
      await _isar.transactions
          .filter()
          .customerIdEqualTo(id)
          .deleteAll();
      await _isar.customers.delete(id);
    });
  }
}
