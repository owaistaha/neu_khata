import 'package:isar/isar.dart';

part 'customer.g.dart';

/// Represents a customer / business contact in the khata ledger.
///
/// Each customer has a running [balance]:
/// - **Positive** → the customer owes you.
/// - **Negative** → you owe the customer.
@collection
class Customer {
  Id id = Isar.autoIncrement;

  /// Full name of the customer.
  @Index()
  late String name;

  /// Phone number (Pakistani format, e.g. 03XX-XXXXXXX).
  String? phone;

  /// Optional profile image path (local file or URL).
  String? imageUrl;

  /// Current net balance in PKR.
  /// Positive = they owe you. Negative = you owe them.
  double balance = 0;

  /// Timestamp when the customer was first added.
  DateTime createdAt = DateTime.now();

  /// Timestamp of the last update.
  DateTime updatedAt = DateTime.now();
}
