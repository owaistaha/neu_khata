import 'package:isar/isar.dart';

part 'transaction.g.dart';

/// The direction of money flow.
enum TransactionType {
  /// You gave money to the customer (debit).
  gave,

  /// You received money from the customer (credit).
  received,
}

/// Represents a single ledger entry (money given or received).
@collection
class Transaction {
  Id id = Isar.autoIncrement;

  /// The customer this transaction belongs to.
  @Index()
  int customerId = 0;

  /// Amount in PKR.
  double amount = 0;

  /// Whether money was given or received.
  @Enumerated(EnumType.name)
  TransactionType type = TransactionType.gave;

  /// Optional description / note for this entry.
  String? description;

  /// Optional category used for reporting.
  String? category;

  /// The date the transaction occurred.
  @Index()
  DateTime date = DateTime.now();

  /// Timestamp when the record was created.
  DateTime createdAt = DateTime.now();
}
