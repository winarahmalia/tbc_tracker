import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime currentDate = DateTime(today.year, today.month, today.day);

    // Cek apakah hari ini sudah minum obat
    bool hasTakenToday = history.any((d) => 
      d.year == currentDate.year && d.month == currentDate.month && d.day == currentDate.day);

    // Jika hari ini belum minum, cek kemarin. Jika kemarin juga belum, streak terputus (0).
    if (!hasTakenToday) {
      DateTime yesterday = currentDate.subtract(const Duration(days: 1));
      bool hasTakenYesterday = history.any((d) => 
        d.year == yesterday.year && d.month == yesterday.month && d.day == yesterday.day);
      
      if (!hasTakenYesterday) return 0; // Streak putus
      currentDate = yesterday; // Mulai hitung mundur dari kemarin
    }

    // Hitung streak ke belakang
    for (int i = 0; i < history.length; i++) {
      bool found = history.any((d) => 
        d.year == currentDate.year && d.month == currentDate.month && d.day == currentDate.day);
      
      if (found) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break; // Ada hari yang bolong
      }
    }

    return streak;
  }
}
