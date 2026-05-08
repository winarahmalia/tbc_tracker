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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD1F2E1).withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD1F2E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF40916C),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              "STREAK AKTIF",
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                "$streakDays hari",
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
          const Text(
            "Pertahankan terus!",
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2D6A4F),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              bool isDone = index < completionHistory.length && completionHistory[index];
              return Container(
                width: 35,
                height: 35,
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFF40916C) : Colors.white.withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDone ? Colors.transparent : const Color(0xFF40916C),
                    width: 1.5,
                  ),
                ),
                child: isDone
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              );
            }),
          ),
        ],
      ),
    );
  }
}
