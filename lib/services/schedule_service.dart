import 'supabase_service.dart';
import '../models/schedule_model.dart';

/// Service untuk operasi CRUD jadwal minum obat ke tabel `schedules`.
class ScheduleService {
  static final _client = SupabaseService.client;

  // ─── Simpan atau perbarui jadwal ──────────────────────────────────────────
  /// Menyimpan jadwal baru. Jika sudah ada, akan diganti (upsert berdasarkan user_id).
  static Future<ScheduleModel?> saveSchedule({
    required int startDay,
    required int targetDay,
    String? reminderTime,
    bool isDaily = true,
    List<String> selectedDays = const [],
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final data = {
      'user_id': userId,
      'start_day': startDay,
      'target_day': targetDay,
      if (reminderTime != null) 'reminder_time': reminderTime,
      'is_daily': isDaily,
      'selected_days': selectedDays,
      'updated_at': DateTime.now().toIso8601String(),
    };

    // Cek apakah jadwal sudah ada untuk user ini
    final existing = await _client
        .from('schedules')
        .select('id')
        .eq('user_id', userId)
        .maybeSingle();

    List<Map<String, dynamic>> result;

    if (existing != null) {
      // Update jadwal yang ada
      result = await _client
          .from('schedules')
          .update(data)
          .eq('user_id', userId)
          .select();
    } else {
      // Insert jadwal baru
      result = await _client.from('schedules').insert(data).select();
    }

    if (result.isEmpty) return null;
    return ScheduleModel.fromJson(result.first);
  }

  // ─── Ambil jadwal aktif ───────────────────────────────────────────────────
  /// Mengambil jadwal aktif milik user yang sedang login.
  static Future<ScheduleModel?> getActiveSchedule() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await _client
        .from('schedules')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (data == null) return null;
    return ScheduleModel.fromJson(data);
  }
}
