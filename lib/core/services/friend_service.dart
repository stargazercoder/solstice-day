import 'supabase_service.dart';

class FriendService {
  final _client = SupabaseService.client;
  String get _uid => SupabaseService.currentUserId!;

  Future<List<Map<String, dynamic>>> getFriends() async {
    final data = await _client
        .from('friendships')
        .select('*, requester:profiles!requester_id(*), addressee:profiles!addressee_id(*)')
        .or('requester_id.eq.$_uid,addressee_id.eq.$_uid')
        .eq('status', 'accepted');
    return data;
  }

  Future<List<Map<String, dynamic>>> getPendingRequests() async {
    return await _client
        .from('friendships')
        .select('*, requester:profiles!requester_id(*)')
        .eq('addressee_id', _uid)
        .eq('status', 'pending');
  }

  Future<void> sendFriendRequest(String addresseeId) async {
    await _client.from('friendships').insert({
      'requester_id': _uid,
      'addressee_id': addresseeId,
    });
  }

  Future<void> acceptFriendRequest(String friendshipId) async {
    await _client.from('friendships').update({'status': 'accepted'}).eq('id', friendshipId);
  }

  Future<void> rejectFriendRequest(String friendshipId) async {
    await _client.from('friendships').update({'status': 'rejected'}).eq('id', friendshipId);
  }

  Future<String> createInviteCode() async {
    final code = await _client.rpc('generate_invite_code');
    await _client.from('friend_invites').insert({
      'inviter_id': _uid,
      'invite_code': code,
    });
    return code;
  }

  Future<Map<String, dynamic>?> useInviteCode(String code) async {
    final invite = await _client
        .from('friend_invites')
        .select()
        .eq('invite_code', code.toUpperCase())
        .gt('expires_at', DateTime.now().toIso8601String())
        .maybeSingle();

    if (invite == null) return null;
    if (invite['inviter_id'] == _uid) return null;

    await sendFriendRequest(invite['inviter_id']);
    await _client.from('friend_invites').update({
      'used_count': (invite['used_count'] as int) + 1,
    }).eq('id', invite['id']);

    return invite;
  }
}
