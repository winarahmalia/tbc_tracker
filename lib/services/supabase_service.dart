import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String _supabaseUrl = 'https://rudsenxvpposrbebuwjg.supabase.co';
  static const String _supabaseAnonKey =
      'sb_publishable_h_yFI4GhdVb-5orx5Z6orA_7b55_rVJ';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
