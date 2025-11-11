import '../exports.dart';
import '../models/user_extra.dart';
import '../models/contact.dart';
import 'logged_supabase_client.dart';

part 'supabase_service_auth.dart';
part 'supabase_service_user.dart';
part 'supabase_service_contacts.dart';

class SupabaseService {
  final client = LoggedSupabaseClient(Supabase.instance.client);
}
