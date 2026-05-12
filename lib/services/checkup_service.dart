import 'supabase_service.dart';
import '../models/checkup_model.dart';

/// Service untuk menyimpan dan mengambil log checkup harian dari tabel `checkup_logs`.
class CheckupService {
  static final _client = SupabaseService.client;

  // ─── Simpan hasil checkup ─────────────────────────────────────────────────
  /// Menyimpan hasil checkup harian ke database.
  static Future<CheckupModel?> saveCheckup({
    required Map<String, bool> answers,
    required bool isCritical,
    required bool hasWarning,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final result = await _client
        .from('checkup_logs')
        .insert({
          'user_id': userId,
          'answers': answers,
          'is_critical': isCritical,
          'has_warning': hasWarning,
        })
        .select();

    if (result.isEmpty) return null;
    return CheckupModel.fromJson(result.first);
  }

  // ─── Ambil riwayat checkup ────────────────────────────────────────────────
  /// Mengambil semua log checkup milik user, diurutkan terbaru dulu.
  static Future<List<CheckupModel>> getCheckupHistory() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from('checkup_logs')
        .select()
        .eq('user_id', userId)
        .order('checked_at', ascending: false);

    return data.map((json) => CheckupModel.fromJson(json)).toList();
  }

  // ─── Cek apakah sudah checkup hari ini ────────────────────────────────────
  /// Mengecek apakah user sudah melakukan checkup hari ini.
  static Future<bool> hasCheckedToday() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final data = await _client
        .from('checkup_logs')
        .select('id')
        .eq('user_id', userId)
        .gte('checked_at', startOfDay.toIso8601String())
        .lt('checked_at', endOfDay.toIso8601String())
        .limit(1);

    return data.isNotEmpty;
  }
}
