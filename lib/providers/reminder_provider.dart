import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/customer.dart';
import '../models/reminder.dart';
import 'customer_provider.dart';
import 'database_provider.dart';

final remindersProvider = StreamProvider<List<Reminder>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.reminders.where().sortByDueDate().watch(fireImmediately: true);
});

class ReminderWithCustomer {
  const ReminderWithCustomer({required this.reminder, required this.customer});

  final Reminder reminder;
  final Customer? customer;
}

final remindersWithCustomerProvider =
    Provider<AsyncValue<List<ReminderWithCustomer>>>((ref) {
      final remindersAsync = ref.watch(remindersProvider);
      final customersAsync = ref.watch(customersProvider);

      return remindersAsync.when(
        data: (reminders) {
          return customersAsync.when(
            data: (customers) {
              final map = {
                for (final customer in customers) customer.id: customer,
              };
              final rows = reminders
                  .map(
                    (reminder) => ReminderWithCustomer(
                      reminder: reminder,
                      customer: map[reminder.customerId],
                    ),
                  )
                  .toList();
              return AsyncValue.data(rows);
            },
            loading: () => const AsyncValue.loading(),
            error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
          );
        },
        loading: () => const AsyncValue.loading(),
        error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
      );
    });

final reminderNotifierProvider = NotifierProvider<ReminderNotifier, void>(
  ReminderNotifier.new,
);

class ReminderNotifier extends Notifier<void> {
  @override
  void build() {}

  Isar get _isar => ref.read(isarProvider);

  Future<void> addReminder({
    required int customerId,
    required double amount,
    required DateTime dueDate,
    String? note,
  }) async {
    final now = DateTime.now();
    final reminder = Reminder()
      ..customerId = customerId
      ..amount = amount
      ..dueDate = dueDate
      ..note = note?.trim().isEmpty ?? true ? null : note!.trim()
      ..isSettled = false
      ..createdAt = now
      ..updatedAt = now;

    await _isar.writeTxn(() => _isar.reminders.put(reminder));
  }

  Future<void> setSettled({
    required Reminder reminder,
    required bool settled,
  }) async {
    reminder.isSettled = settled;
    reminder.updatedAt = DateTime.now();
    await _isar.writeTxn(() => _isar.reminders.put(reminder));
  }

  Future<void> deleteReminder(int id) async {
    await _isar.writeTxn(() => _isar.reminders.delete(id));
  }
}
