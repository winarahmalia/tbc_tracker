import 'package:flutter/material.dart';

class StreakCard extends StatelessWidget {
  final int streakDays;
  final List<bool> completionHistory; // Last 6 days

  const StreakCard({
    super.key,
    required this.streakDays,
    required this.completionHistory,
  });

  @override
  Widget build(BuildContext context) {
    bool isZero = streakDays == 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2ECC71).withOpacity(0.25), // Terang
            const Color(0xFF006D37).withOpacity(0.25), // Gelap
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD1F2E1).withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isZero 
                  ? const Color(0xFF6FF1A5) 
                  : const Color(0xFF40916C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              isZero ? "BELUM MULAI" : "STREAK AKTIF",
              style: TextStyle(
                color: isZero ? const Color(0xFF1B4332) : Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          
          // Angka Streak
          Row(
            children: [
              Text(
                isZero ? "-" : "$streakDays hari", // Kembalikan ke "-"
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "🔥",
                style: TextStyle(fontSize: 28),
              ),
            ],
          ),
          
          // Subtitle
          Text(
            isZero ? "Mulai Langkah Pertamamu!" : "Pertahankan terus!",
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF006D37), // Warna teks sekunder
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          
          // History Bulatan
          Wrap(
            spacing: 10,
            children: completionHistory.map((isDone) {
              return Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFF2ECC71) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF2ECC71),
                    width: 1.5,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
