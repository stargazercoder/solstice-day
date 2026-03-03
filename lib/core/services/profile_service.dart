import 'supabase_service.dart';
import '../../shared/models/profile_model.dart';

class ProfileService {
  final _client = SupabaseService.client;
  String get _uid => SupabaseService.currentUserId!;

  Future<ProfileModel> getProfile() async {
    final data = await _client.from('profiles').select().eq('id', _uid).single();
    return ProfileModel.fromJson(data);
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    await _client.from('profiles').update(updates).eq('id', _uid);
  }

  Future<List<Map<String, dynamic>>> getManagedProfiles() async {
    return await _client.from('managed_profiles').select().eq('owner_id', _uid);
  }

  Future<void> addManagedProfile(Map<String, dynamic> data) async {
    data['owner_id'] = _uid;
    await _client.from('managed_profiles').insert(data);
  }
}
