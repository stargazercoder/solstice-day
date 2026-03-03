import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/friend_service.dart';

final friendServiceProvider = Provider((ref) => FriendService());

final friendsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(friendServiceProvider).getFriends();
});

final pendingRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return ref.read(friendServiceProvider).getPendingRequests();
});
