import 'package:flutter/material.dart';

class AppColors {
  // ─── Primary palette (Figma) ───────────────────────────────────────────────
  static const Color darkGreen   = Color(0xFF064E3B); // teks utama
  static const Color primaryGreen = Color(0xFF006D37); // teks sekunder / tombol kiri gradient
  static const Color accentGreen  = Color(0xFF2ECC71); // tombol kanan gradient / penanda

  // ─── Gradient tombol ──────────────────────────────────────────────────────
  static const LinearGradient buttonGradient = LinearGradient(
    colors: [Color(0xFF006D37), Color(0xFF2ECC71)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ─── Container hijau tipis (5-10%) ────────────────────────────────────────
  // gunakan: AppColors.accentGreen.withOpacity(0.07)

  // ─── Kalender ─────────────────────────────────────────────────────────────
  static const Color calendarTodayTaken    = Color(0xFF2ECC71); // 75% opacity → pakai .withOpacity(0.75)
  static const Color calendarPastTaken     = Color(0xFF2ECC71); // 50% opacity → pakai .withOpacity(0.50)

  // ─── Error / Tidak ────────────────────────────────────────────────────────
  static const Color errorRed  = Color(0xFFC13536);

  // ─── Background gradient halaman ──────────────────────────────────────────
  static const Color lightGreen = Color(0xFFD1F2E1); // tetap untuk background gradient
}