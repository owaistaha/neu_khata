import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/business_profile.dart';
import '../models/customer.dart';
import '../models/reminder.dart';
import '../models/transaction.dart';

/// Provides the singleton [Isar] database instance.
///
/// Must be initialized before use — see [initIsar].
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'isarProvider must be overridden with the initialized Isar instance.',
  );
});

/// Opens the Isar database and returns the instance.
///
/// Called once in `main()` before [runApp].
Future<Isar> initIsar() async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [BusinessProfileSchema, CustomerSchema, ReminderSchema, TransactionSchema],
    directory: dir.path,
    name: 'khata_digital',
  );
}
