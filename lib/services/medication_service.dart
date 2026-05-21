import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

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
}
