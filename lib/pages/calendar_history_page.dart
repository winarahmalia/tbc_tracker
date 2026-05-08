import 'package:flutter/material.dart';
import '../constants/colors.dart';

class CalendarHistoryPage extends StatelessWidget {
  const CalendarHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Jadwal Minum Obat",
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildCalendarHeader(),
            const SizedBox(height: 20),
            _buildCalendarGrid(),
            const SizedBox(height: 40),
            _buildStatusSection(false), // Example: Not taken today
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "June 2026",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
        ),
        Row(
          children: [
            IconButton(icon: const Icon(Icons.chevron_left), onPressed: () {}),
            IconButton(icon: const Icon(Icons.chevron_right), onPressed: () {}),
          ],
        ),
      ],
    );
  }

  Widget _buildCalendarGrid() {
    final List<String> days = ["SEN", "SEL", "RAB", "KAM", "JUM", "SAB", "MIN"];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: days.map((day) => Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
          )).toList(),
        ),
        const SizedBox(height: 20),
        // Simple mock calendar grid
        _buildCalendarRow([null, null, 1, 2, 3, 4], [3, 4]),
        _buildCalendarRow([5, 6, 7, 8, 9, 10, 11], [5, 6]),
        _buildCalendarRow([12, 13, 14, 15, 16, 17, 18], []),
        _buildCalendarRow([19, 20, 21, 22, 23, 24, 25], []),
        _buildCalendarRow([26, 27, 28, 29, 30, 31, null], []),
      ],
    );
  }

  Widget _buildCalendarRow(List<int?> dates, List<int> completedDates) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: dates.map((date) {
          if (date == null) return const Expanded(child: SizedBox());
          bool isCompleted = completedDates.contains(date);
          bool isCurrent = date == 6; // Mock current date
          bool isMissed = date == 6 && !isCompleted; // Example logic

          return Expanded(
            child: Center(
              child: Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFF74C69D) : (isCurrent ? Colors.red.withOpacity(0.1) : Colors.transparent),
                  shape: BoxShape.circle,
                  border: isCurrent && !isCompleted ? Border.all(color: Colors.red, width: 1) : null,
                ),
                child: Text(
                  "$date",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.white : (isCurrent && !isCompleted ? Colors.red : const Color(0xFF1B4332)),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusSection(bool isTaken) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Waktu", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            Text(isTaken ? "12.00 Am" : "-", style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
          ],
        ),
        const SizedBox(height: 30),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: isTaken ? const Color(0xFF74C69D).withOpacity(0.2) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            isTaken ? "Kamu Sudah Minum Obat Hari Ini" : "Kamu Belum Minum Obat Hari Ini!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isTaken ? const Color(0xFF2D6A4F) : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
