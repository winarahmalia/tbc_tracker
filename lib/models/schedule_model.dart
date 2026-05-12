/// Model data untuk jadwal minum obat yang tersimpan di tabel `schedules`.
class ScheduleModel {
  final String id;
  final String userId;
  final int startDay;
  final int targetDay;
  final String? reminderTime;
  final bool isDaily;
  final List<String> selectedDays;
  final DateTime createdAt;

  const ScheduleModel({
    required this.id,
    required this.userId,
    required this.startDay,
    required this.targetDay,
    this.reminderTime,
    required this.isDaily,
    required this.selectedDays,
    required this.createdAt,
  });

  /// Buat instance dari data JSON (response Supabase).
  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    return ScheduleModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      startDay: json['start_day'] as int,
      targetDay: json['target_day'] as int,
      reminderTime: json['reminder_time'] as String?,
      isDaily: json['is_daily'] as bool? ?? true,
      selectedDays: (json['selected_days'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Konversi ke Map untuk dikirim ke Supabase.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'start_day': startDay,
      'target_day': targetDay,
      if (reminderTime != null) 'reminder_time': reminderTime,
      'is_daily': isDaily,
      'selected_days': selectedDays,
    };
  }
}
