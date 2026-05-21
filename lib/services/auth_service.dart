import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/user_profile_model.dart';
import 'cache_service.dart';

/// Service untuk semua operasi autentikasi menggunakan Supabase Auth.
class AuthService {
  static SupabaseClient get _client => SupabaseService.client;

  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  // ─── Register ─────────────────────────────────────────────────────────────
  static Future<UserProfileModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      // Log lengkap untuk debugging
      debugPrint('[AuthService] signUp response:');
      debugPrint('  user: ${response.user?.id}');
      debugPrint('  session: ${response.session?.accessToken != null ? "ada" : "null"}');
      debugPrint('  user email: ${response.user?.email}');

      final user = response.user;
      if (user == null) {
        throw Exception('User null setelah signUp — cek Supabase dashboard.');
      }

      if (response.session == null) {
        throw Exception(
          'Email confirmation masih aktif.\n'
          'Pergi ke Supabase → Authentication → Providers → Email → '
          'matikan "Confirm email" → Save.',
        );
      }

      // Insert profil
      try {
        await _client.from('profiles').upsert({
          'id': user.id,
          'name': name,
        });
        debugPrint('[AuthService] Profile inserted OK');
      } catch (e) {
        debugPrint('[AuthService] Profile insert error: $e');
        // Tidak fatal, lanjutkan
      }

      return UserProfileModel(
        id: user.id,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
    } on AuthException catch (e) {
      debugPrint('[AuthService] AuthException signUp: ${e.message} | statusCode: ${e.statusCode}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('[AuthService] Unexpected signUp error: $e');
      rethrow;
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────
  static Future<UserProfileModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      debugPrint('[AuthService] signIn response:');
      debugPrint('  user: ${response.user?.id}');
      debugPrint('  session: ${response.session?.accessToken != null ? "ada" : "null"}');

      final user = response.user;
      if (user == null) {
        throw Exception('Login gagal — user null.');
      }

      // Ambil profil
      try {
        final profileData = await _client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profileData != null) {
          debugPrint('[AuthService] Profile found: ${profileData['name']}');
          return UserProfileModel.fromJson({...profileData, 'email': email});
        }
      } catch (e) {
        debugPrint('[AuthService] Profile fetch error: $e');
      }

      // Buat profil baru jika belum ada
      final name = (user.userMetadata?['name'] as String?) ??
          _capitalizeFirst(email.split('@')[0]);
      try {
        await _client.from('profiles').upsert({
          'id': user.id,
          'name': name,
        });
      } catch (e) {
        debugPrint('[AuthService] Profile upsert error: $e');
      }

      return UserProfileModel(
        id: user.id,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );
    } on AuthException catch (e) {
      debugPrint('[AuthService] AuthException signIn: ${e.message} | statusCode: ${e.statusCode}');
      throw Exception(e.message);
    } catch (e) {
      debugPrint('[AuthService] Unexpected signIn error: $e');
      rethrow;
    }
  }

  // ─── Kirim email reset password ─────────────────────────────────────────
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      debugPrint('AuthService resetPassword error: ${e.message}');
      throw Exception('Gagal kirim email reset: ${e.message}');
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    await CacheService.clearAll();
    await _client.auth.signOut();
  }

  // ─── Cek sesi aktif ───────────────────────────────────────────────────────
  static Future<UserProfileModel?> getCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final profileData = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profileData == null) return null;
      return UserProfileModel.fromJson({
        ...profileData,
        'email': user.email ?? '',
      });
    } catch (e) {
      debugPrint('[AuthService] getCurrentProfile error: $e');
      return null;
    }
  }

  static String _capitalizeFirst(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
