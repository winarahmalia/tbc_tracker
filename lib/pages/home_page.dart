import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/streak_card.dart';
import '../widgets/medication_card.dart';
import '../widgets/info_card.dart';
import 'schedule_setup_page.dart';
import 'calendar_history_page.dart';
import 'profile_settings_page.dart';
import 'daily_checkup_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  bool _isTaken = false;
  String? _statusMessage; // "success" or "error" or null

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.lightGreen, Colors.white],
            center: Alignment(0, -0.6),
            radius: 1.2,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 20),
                      if (_statusMessage != null) _buildStatusBanner(),
                      const SizedBox(height: 10),
                      _buildGreeting(),
                      const SizedBox(height: 25),
                      StreakCard(
                        streakDays: 5,
                        completionHistory: const [true, true, true, true, true, false],
                      ),
                      const SizedBox(height: 25),
                      MedicationCard(
                        currentDay: 6,
                        totalDays: 100,
                        percentage: 6,
                        isTaken: _isTaken,
                        onActionPressed: () {
                          setState(() {
                            _isTaken = true;
                            _statusMessage = "success";
                          });
                        },
                        onSeeAllPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarHistoryPage()));
                        },
                      ),
                      const SizedBox(height: 25),
                      _buildCheckupCard(),
                      const SizedBox(height: 25),
                      const InfoCard(
                        title: "Tahukah Kamu?",
                        content: "Kepatuhan dalam menjalani pengobatan tuberkulosis secara teratur sangat penting untuk memastikan keberhasilan terapi dan mencegah terjadinya resistensi obat.",
                        author: "World Health Organization (WHO)",
                        authorRole: "Organisasi Kesehatan Dunia",
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              _buildBottomNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCheckupCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4332),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pantau Kondisi Harian",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Cek gejala Anda hari ini untuk memastikan pemulihan berjalan lancar.",
                  style: TextStyle(
                    color: Color(0xFFD1F2E1),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DailyCheckupPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF40916C),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: const Text(
              "Mulai",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    bool isSuccess = _statusMessage == "success";
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: isSuccess ? const Color(0xFF2DC653) : const Color(0xFFD91E18),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess ? Icons.check : Icons.close,
              color: isSuccess ? const Color(0xFF2DC653) : const Color(0xFFD91E18),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSuccess ? "Berhasil!" : "Gagal!",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  isSuccess
                      ? "Berhasil konfirmasi minum obat hari ini"
                      : "Maaf, Silahkan Konfirmasi Kembali",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _statusMessage = null),
            child: const Icon(Icons.close, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.medical_services, color: Color(0xFF00A355), size: 24),
            const SizedBox(width: 8),
            const Text(
              "TBC-Tracker",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1B4332),
              ),
            ),
          ],
        ),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFF1B4332),
          child: Icon(Icons.person, color: Colors.white, size: 20),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Selamat Pagi, Dinda",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4332),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Yuk fokus pada pemulihan hari ini.",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF1B4332),
        borderRadius: BorderRadius.circular(35),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_filled, 0),
          _buildNavItem(Icons.calendar_month_outlined, 1),
          _buildNavItem(Icons.menu_rounded, 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 1) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarHistoryPage()));
        } else if (index == 2) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileSettingsPage()));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: isActive
            ? const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              )
            : null,
        child: Icon(
          icon,
          color: isActive ? const Color(0xFF1B4332) : Colors.white.withOpacity(0.6),
          size: 28,
        ),
      ),
    );
  }
}
