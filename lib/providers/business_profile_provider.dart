import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../models/business_profile.dart';
import 'database_provider.dart';

final businessProfileProvider = StreamProvider<BusinessProfile?>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.businessProfiles
      .where()
      .watch(fireImmediately: true)
      .map((profiles) => profiles.isEmpty ? null : profiles.first);
});

final hasBusinessProfileProvider = FutureProvider<bool>((ref) async {
  final isar = ref.watch(isarProvider);
  final profile = await isar.businessProfiles.where().findFirst();
  return profile != null;
});

final businessProfileNotifierProvider =
    NotifierProvider<BusinessProfileNotifier, void>(
      BusinessProfileNotifier.new,
    );

class BusinessProfileNotifier extends Notifier<void> {
  @override
  void build() {}

  Isar get _isar => ref.read(isarProvider);

  Future<BusinessProfile?> getProfile() {
    return _isar.businessProfiles.where().findFirst();
  }

  Future<void> upsertProfile({
    required String businessName,
    String? ownerName,
    String? phone,
    String? address,
  }) async {
    final now = DateTime.now();
    final existing = await _isar.businessProfiles.where().findFirst();

    await _isar.writeTxn(() async {
      final profile = existing ?? BusinessProfile()
        ..createdAt = now;
      profile.businessName = businessName.trim();
      profile.ownerName = ownerName?.trim().isEmpty ?? true
          ? null
          : ownerName!.trim();
      profile.phone = phone?.trim().isEmpty ?? true ? null : phone!.trim();
      profile.address = address?.trim().isEmpty ?? true
          ? null
          : address!.trim();
      profile.updatedAt = now;

      await _isar.businessProfiles.put(profile);
    });
  }
}
