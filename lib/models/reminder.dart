import 'package:isar/isar.dart';

part 'reminder.g.dart';

@collection
class Reminder {
  Id id = Isar.autoIncrement;

  @Index()
  int customerId = 0;

  double amount = 0;

  @Index()
  DateTime dueDate = DateTime.now();

  String? note;

  bool isSettled = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
