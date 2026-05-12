/// Model data untuk hasil checkup harian yang tersimpan di tabel `checkup_logs`.
class CheckupModel {
  final String id;
  final String userId;
  final Map<String, bool> answers;
  final bool isCritical;
  final bool hasWarning;
  final DateTime checkedAt;

  const CheckupModel({
    required this.id,
    required this.userId,
    required this.answers,
    required this.isCritical,
    required this.hasWarning,
    required this.checkedAt,
  });

  /// Buat instance dari data JSON (response Supabase).
  factory CheckupModel.fromJson(Map<String, dynamic> json) {
    final rawAnswers = json['answers'] as Map<String, dynamic>? ?? {};
    return CheckupModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      answers: rawAnswers.map((k, v) => MapEntry(k, v as bool)),
      isCritical: json['is_critical'] as bool? ?? false,
      hasWarning: json['has_warning'] as bool? ?? false,
      checkedAt: DateTime.parse(json['checked_at'] as String),
    );
  }

  /// Konversi ke Map untuk dikirim ke Supabase.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'answers': answers,
      'is_critical': isCritical,
      'has_warning': hasWarning,
    };
  }
}
