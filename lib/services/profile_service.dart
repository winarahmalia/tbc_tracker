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
    return UserProfileModel.fromJson({
      'email': user.email ?? '',
      ...data,
    });
  }

  static Future<void> _safeUpdateProfile(Map<String, dynamic> data) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    try {
      // Ambil data yang ada agar upsert tidak menghapus kolom lain menjadi null
      final existing = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      final updateData = Map<String, dynamic>.from(existing ?? {});
      updateData.addAll(data);
      updateData['id'] = user.id;

      if (!updateData.containsKey('name')) updateData['name'] = 'Pengguna';
      if (!updateData.containsKey('email')) updateData['email'] = user.email ?? '';

      await _client.from('profiles').upsert(updateData);
    } catch (e) {
      debugPrint('ProfileService _safeUpdateProfile error: $e');
      throw Exception('Gagal menyimpan profil: $e');
    }
  }

  static Future<void> updateName(String newName) async {
    await _safeUpdateProfile({'name': newName});
  }

  static Future<void> updateEmail(String newEmail) async {
    try {
      await _client.auth.updateUser(UserAttributes(email: newEmail));
    } on AuthException catch (e) {
      debugPrint('ProfileService updateEmail AuthException: ${e.message}');
      if (e.message.toLowerCase().contains('rate limit')) {
        throw Exception('Terlalu sering mencoba. Tunggu beberapa menit.');
      }
      throw Exception('Gagal update email: ${e.message}');
    }

    try {
      await _safeUpdateProfile({'email': newEmail});
    } catch (e) {
      debugPrint('ProfileService profiles email update warning: $e');
    }
  }

  static Future<void> updatePassword(String newPassword) async {
    await _client.auth.updateUser(UserAttributes(password: newPassword));
  }

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
