import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache lokal agar data tetap bisa ditampilkan saat offline.
class CacheService {
  static const _keySchedule = 'cached_schedule';
  static const _keyTakenDates = 'cached_taken_dates';
  static const _keyStreak = 'cached_streak';
  static const _keyLastFetch = 'cached_last_fetch';

  // ─── Schedule ─────────────────────────────────────────────────────────────
  static Future<void> cacheSchedule(Map<String, dynamic>? scheduleJson) async {
    if (scheduleJson == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySchedule, jsonEncode(scheduleJson));
    await prefs.setString(_keyLastFetch, DateTime.now().toIso8601String());
  }

  static Future<Map<String, dynamic>?> getCachedSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keySchedule);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ─── Taken Dates (riwayat minum obat) ─────────────────────────────────────
  static Future<void> cacheTakenDates(List<String> dateStrings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyTakenDates, dateStrings);
  }

  static Future<List<String>?> getCachedTakenDates() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyTakenDates);
  }

  // ─── Streak ───────────────────────────────────────────────────────────────
  static Future<void> cacheStreak(int streak) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStreak, streak);
  }

  static Future<int> getCachedStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyStreak) ?? 0;
  }

  // ─── Info kapan terakhir fetch ────────────────────────────────────────────
  static Future<DateTime?> getLastFetchTime() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLastFetch);
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Hapus semua cache (saat logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keySchedule);
    await prefs.remove(_keyTakenDates);
    await prefs.remove(_keyStreak);
    await prefs.remove(_keyLastFetch);
    debugPrint('[CacheService] All cache cleared');
  }
}
