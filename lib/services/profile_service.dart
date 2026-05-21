import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';
import '../models/user_profile_model.dart';

class ProfileService {
  static final _client = SupabaseService.client;
  static const String _avatarBucket = 'avatars';

  static Future<UserProfileModel?> getProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (data == null) return null;

    // Email comes from Auth, not from the profiles table
    final profileData = Map<String, dynamic>.from(data);
    profileData['email'] = user.email ?? '';

    return UserProfileModel.fromJson(profileData);
  }

  static Future<void> _safeUpdateProfile(Map<String, dynamic> data) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      final existing = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      final updateData = Map<String, dynamic>.from(existing ?? {});
      updateData.addAll(data);
      updateData['id'] = user.id;

      if (!updateData.containsKey('name')) updateData['name'] = 'Pengguna';

      // Don't include 'email' — the profiles table doesn't have that column.
      // Email is managed by Supabase Auth only.
      updateData.remove('email');

      await _client.from('profiles').upsert(updateData);
    } catch (e) {
      debugPrint('ProfileService _safeUpdateProfile error: $e');
      throw Exception('Gagal menyimpan profil: $e');
    }
  }

  // ─── Update Nama ──────────────────────────────────────────────────────────
  static Future<void> updateName(String newName) async {
    if (newName.trim().isEmpty) {
      throw Exception('Nama tidak boleh kosong.');
    }
    await _safeUpdateProfile({'name': newName.trim()});
  }

  // ─── Update Email ────────────────────────────────────────────────────────
  static Future<void> updateEmail({required String newEmail}) async {
    final email = newEmail.trim().toLowerCase();
    if (email.isEmpty) throw Exception('Email tidak boleh kosong.');
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      throw Exception('Format email tidak valid.');
    }

    try {
      await _client.auth.updateUser(UserAttributes(email: email));
    } on AuthException catch (e) {
      debugPrint('ProfileService updateEmail AuthException: ${e.message}');
      if (e.message.toLowerCase().contains('rate limit')) {
        throw Exception('Terlalu sering mencoba. Tunggu beberapa menit.');
      }
      throw Exception('Gagal update email: ${e.message}');
    }
  }

  // ─── Reset password tanpa verifikasi (user sudah login) ─────────────────
  static Future<void> resetPasswordDirectly(String newPassword) async {
    if (newPassword.length < 6) {
      throw Exception('Password minimal 6 karakter.');
    }
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      throw Exception('Gagal reset password: ${e.message}');
    }
  }

  // ─── Update Password (wajib verifikasi password lama) ─────────────────────
  static Future<void> updatePassword({
    required String newPassword,
    required String currentPassword,
  }) async {
    if (newPassword.length < 6) {
      throw Exception('Password minimal 6 karakter.');
    }

    // Re-autentikasi dulu
    try {
      await _client.auth.signInWithPassword(
        email: _client.auth.currentUser?.email ?? '',
        password: currentPassword,
      );
    } on AuthException {
      throw Exception('Password saat ini salah.');
    }

    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } on AuthException catch (e) {
      debugPrint('ProfileService updatePassword AuthException: ${e.message}');
      throw Exception('Gagal update password: ${e.message}');
    }
  }

  // ─── Avatar ───────────────────────────────────────────────────────────────
  static Future<String> uploadAvatarBytes({
    required Uint8List bytes,
    required String mimeType,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User tidak ditemukan.');

    final filePath = '$userId/profile.jpg';

    await _client.storage.from(_avatarBucket).uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: mimeType,
          ),
        );

    final publicUrl =
        _client.storage.from(_avatarBucket).getPublicUrl(filePath);
    final avatarUrl = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

    await _safeUpdateProfile({'avatar_url': avatarUrl});
    return avatarUrl;
  }

  static Future<void> removeAvatar() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    final filePath = '$userId/profile.jpg';

    try {
      await _client.storage.from(_avatarBucket).remove([filePath]);
    } catch (e) {
      debugPrint('ProfileService Remove avatar warning: $e');
    }
    await _safeUpdateProfile({'avatar_url': null});
  }
}
