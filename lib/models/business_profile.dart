import 'package:isar/isar.dart';

part 'business_profile.g.dart';

@collection
class BusinessProfile {
  Id id = Isar.autoIncrement;

  @Index()
  late String businessName;

  String? ownerName;
  String? phone;
  String? address;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
