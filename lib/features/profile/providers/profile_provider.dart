import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/profile_service.dart';
import '../../../shared/models/profile_model.dart';

final profileServiceProvider = Provider((ref) => ProfileService());

final profileProvider = FutureProvider<ProfileModel>((ref) async {
  return ref.read(profileServiceProvider).getProfile();
});

final managedProfilesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(profileServiceProvider).getManagedProfiles();
});
