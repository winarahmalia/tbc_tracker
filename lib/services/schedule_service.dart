import 'package:flutter/foundation.dart';
import 'supabase_service.dart';
import '../models/schedule_model.dart';
import 'notification_service.dart';
import 'cache_service.dart';

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
    final schedule = ScheduleModel.fromJson(result.first);

    // Cache jadwal untuk offline
    await CacheService.cacheSchedule(result.first);

    // Schedule or cancel notifications based on reminder setting
    if (reminderTime != null) {
      final parsed = NotificationService.parseReminderTime(reminderTime);
      await NotificationService.scheduleAllReminders(
        hour: parsed.hour,
        minute: parsed.minute,
      );
      debugPrint('[ScheduleService] All reminders scheduled at $reminderTime');
    } else {
      await NotificationService.cancelAllReminders();
      debugPrint('[ScheduleService] All reminders cancelled');
    }

    return schedule;
  }

  // ─── Ambil jadwal aktif ───────────────────────────────────────────────────
  /// Mengambil jadwal aktif milik user yang sedang login.
  /// Jika gagal dari server, fallback ke cache lokal.
  static Future<ScheduleModel?> getActiveSchedule() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final data = await _client
          .from('schedules')
          .select()
          .eq('user_id', userId)
          .order('updated_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (data != null) {
        // Cache untuk offline
        await CacheService.cacheSchedule(data);
        final schedule = ScheduleModel.fromJson(data);

        // Reschedule all notifications from stored reminder time
        if (schedule.reminderTime != null) {
          final parsed =
              NotificationService.parseReminderTime(schedule.reminderTime);
          await NotificationService.scheduleAllReminders(
            hour: parsed.hour,
            minute: parsed.minute,
          );
        }

        return schedule;
      }
    } catch (e) {
      debugPrint('[ScheduleService] Gagal fetch dari server, pakai cache: $e');
    }

    // Fallback ke cache lokal
    final cached = await CacheService.getCachedSchedule();
    if (cached != null) {
      return ScheduleModel.fromJson(cached);
    }

    return null;
  }

  /// Hapus jadwal user dan batalkan notifikasi
  static Future<void> deleteSchedule() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    await _client.from('schedules').delete().eq('user_id', userId);
    await NotificationService.cancelAllReminders();
    await CacheService.clearAll();
    debugPrint('[ScheduleService] Schedule deleted & notifications cancelled');
  }
}
