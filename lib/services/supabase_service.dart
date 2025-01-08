import '../exports.dart';
import '../models/user_extra.dart';
import '../models/contact.dart';

part 'supabase_service_auth.dart';
part 'supabase_service_user.dart';
part 'supabase_service_contacts.dart';

class SupabaseService {
  final client = Supabase.instance.client;
}
