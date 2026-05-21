import 'package:flutter/foundation.dart';
import 'supabase_service.dart';
import 'schedule_service.dart';
import 'cache_service.dart';
import '../models/schedule_model.dart';

/// Service untuk mencatat dan mengambil data riwayat minum obat harian
class MedicationService {
  static final _client = SupabaseService.client;

  // ─── Catat minum obat ─────────────────────────────────────────────────────
  static Future<void> logMedication(DateTime date) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User tidak ditemukan.');

    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    try {
      await _client.from('medication_logs').insert({
        'user_id': userId,
        'taken_date': dateString,
      });
      debugPrint('[MedicationService] Medication logged for $dateString');
    } catch (e) {
      if (e.toString().contains('23505') || e.toString().contains('duplicate key value')) {
        // Abaikan jika sudah tercatat (Unique violation)
        debugPrint('[MedicationService] Already logged today.');
      } else {
        debugPrint('[MedicationService] Error logging medication: $e');
        throw Exception(e.toString());
      }
    }
  }

  // ─── Ambil semua riwayat ──────────────────────────────────────────────────
  static Future<List<DateTime>> getMedicationHistory() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    try {
      final response = await _client
          .from('medication_logs')
          .select('taken_date')
          .eq('user_id', userId)
          .order('taken_date', ascending: false);

      return (response as List).map((row) {
        return DateTime.parse(row['taken_date'] as String);
      }).toList();
    } catch (e) {
      debugPrint('[MedicationService] Error fetching history: $e');
      return [];
    }
  }

  // ─── Hitung Streak ────────────────────────────────────────────────────────
  static Future<int> calculateCurrentStreak() async {
    final history = await getMedicationHistory();
    if (history.isEmpty) return 0;

    // Konversi history ke set string "YYYY-MM-DD" untuk lookup cepat
    final Set<String> takenDates = history
        .map((d) =>
            '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}')
        .toSet();

    final today = DateTime.now();
    DateTime currentDate = DateTime(today.year, today.month, today.day);
    int streak = 0;

    for (int i = 0; i < 365; i++) {
      final key =
          '${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}';

      if (takenDates.contains(key)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        // Hari ke-0 (hari ini) tidak ditemukan — cek kemarin dulu
        if (i == 0) {
          currentDate = currentDate.subtract(const Duration(days: 1));
          continue;
        }
        break;
      }
    }

    return streak;
  }

  // ─── Reset progres jika terlewat ─────────────────────────────────────────
  /// Menghapus semua riwayat minum obat dan mereset jadwal ke hari pertama.
  static Future<void> resetProgress() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    // Hapus semua log medication
    await _client
        .from('medication_logs')
        .delete()
        .eq('user_id', userId);
    debugPrint('[MedicationService] All medication logs deleted');

    // Reset jadwal: update created_at ke sekarang agar hitungan hari restart
    await _client
        .from('schedules')
        .update({'created_at': DateTime.now().toIso8601String()})
        .eq('user_id', userId);
    debugPrint('[MedicationService] Schedule reset to day 1');

    // Hapus cache lokal agar reload pakai data baru
    await CacheService.clearScheduleCache();
    await CacheService.cacheTakenDates([]);
    await CacheService.cacheStreak(0);
  }

  // ─── Cek apakah kemarin terlewat ─────────────────────────────────────────
  /// Memeriksa apakah user melewatkan minum obat kemarin.
  /// Jika iya, otomatis reset progres dan return true.
  static Future<bool> checkAndResetIfMissed() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    // Ambil jadwal aktif
    final schedule = await ScheduleService.getActiveSchedule();
    if (schedule == null) return false;

    // Tentukan hari kemarin
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    // Cek apakah kemarin termasuk hari minum obat
    if (!_isMedicationDay(schedule, yesterday)) return false;

    // Cek apakah kemarin sudah tercatat minum
    final history = await getMedicationHistory();
    final yesterdayTaken = history.any((d) =>
        d.year == yesterday.year &&
        d.month == yesterday.month &&
        d.day == yesterday.day);

    if (yesterdayTaken) return false;

    // Terlewat! Reset progres
    await resetProgress();
    return true;
  }

  /// Cek apakah tanggal tertentu adalah hari minum obat sesuai jadwal.
  static bool _isMedicationDay(ScheduleModel schedule, DateTime date) {
    if (schedule.isDaily) return true;
    if (schedule.selectedDays.isEmpty) return true;

    const dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    final dayName = dayNames[date.weekday % 7];
    return schedule.selectedDays.contains(dayName);
  }
}
