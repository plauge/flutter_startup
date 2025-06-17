import 'package:idtruster/exports.dart';
import 'package:idtruster/services/get_contact_by_users_service.dart';

final getContactByUsersServiceProvider = Provider<GetContactByUsersService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return GetContactByUsersService(client);
});

final getContactByUsersProvider = AutoDisposeFutureProviderFamily<String?, String>((ref, inputContactId) async {
  final service = ref.watch(getContactByUsersServiceProvider);
  return service.getContactByUsers(inputContactId);
});

// Created: 2024-12-28 11:30:00
