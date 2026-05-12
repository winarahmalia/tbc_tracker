import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/streak_card.dart';
import '../widgets/medication_card.dart';
import '../widgets/info_carousel.dart';
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
  String? _statusMessage;

  // ─── Streak state ──────────────────────────────────────────────────────────
  int _streakDays = 0;
  List<bool> _completionHistory = [false, false, false, false, false, false];

  // ─── Jadwal state ─────────────────────────────────────────────────────────
  bool _scheduleSet = false;
  int _currentDay = 1;
  int _totalDays = 100;
  bool _isTaken = false;
  Set<DateTime> _takenDates = {};
  DateTime? _scheduleStartDate;

  double get _percentage => (((_currentDay - 1 + (_isTaken ? 1 : 0)) / _totalDays) * 100).clamp(0, 100);

  void _openScheduleSetup() async {
    // Tampilkan dialog konfirmasi jika jadwal sudah pernah di-set (artinya sedang mengedit)
    if (_scheduleSet) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Edit Jadwal?",
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
          ),
          content: const Text(
            "Apakah kamu yakin ingin mengubah jadwal minum obat?",
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006D37),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Ya, Edit", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (confirm != true) return; // Batalkan jika tidak memilih "Ya"
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const ScheduleSetupPage()),
    );

    if (result != null && mounted) {
      setState(() {
        _scheduleSet = true;
        _currentDay = result['startDay'] as int;
        _totalDays = result['targetDay'] as int;
        _isTaken = false;
        _scheduleStartDate = DateTime.now();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Jadwal berhasil disimpan! 🎉'),
          backgroundColor: const Color(0xFF40916C),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ─── Konfirmasi minum obat hari ini ───────────────────────────────────────
  void _confirmMedication() {
    final today = DateTime.now();
    setState(() {
      _isTaken = true;
      _streakDays += 1;
      _statusMessage = "success";
      _takenDates = {..._takenDates, DateTime(today.year, today.month, today.day)};
      // Geser history & tandai hari ini selesai
      _completionHistory = [
        true,
        ..._completionHistory.take(5),
      ];
    });
  }

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
                child: _currentIndex == 1
                    ? CalendarHistoryPage(
                        isTab: true,
                        isTaken: _isTaken,
                        takenDates: _takenDates,
                        scheduleStartDate: _scheduleStartDate,
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildHeader(),
                            const SizedBox(height: 20),
                            if (_statusMessage != null) _buildStatusBanner(),
                            if (_statusMessage != null) const SizedBox(height: 10),
                            _buildGreeting(),
                            const SizedBox(height: 25),
                            
                            // Streak Card
                            StreakCard(
                              streakDays: _streakDays,
                              completionHistory: _completionHistory,
                            ),
                            const SizedBox(height: 25),

                            // Card Jadwal / MedicationCard
                            if (!_scheduleSet)
                              _buildSetupScheduleCard()
                            else
                              MedicationCard(
                                currentDay: _currentDay,
                                totalDays: _totalDays,
                                percentage: _percentage,
                                isTaken: _isTaken,
                                onSeeAllPressed: _openScheduleSetup, // Sekarang membuka edit jadwal
                                onActionPressed: _confirmMedication,
                              ),

                            const SizedBox(height: 25),
                            _buildCheckupCard(),
                            const SizedBox(height: 25),
                            const InfoCarousel(),
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

  Widget _buildSetupScheduleCard() {
    return GestureDetector(
      onTap: _openScheduleSetup,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF2ECC71).withOpacity(0.05), // Hijau 5% sesuai permintaan
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          children: [
            const Text(
              "Ayo, Atur Jadwal\nKesehatanmu",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF1B4332), width: 2.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, size: 30, color: Color(0xFF1B4332)),
            ),
            const SizedBox(height: 30),
            const Text(
              "Tambah Jadwal Pertama",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1B4332),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Card Checkup Harian ──────────────────────────────────────────────────
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
                  style: TextStyle(color: Color(0xFFD1F2E1), fontSize: 12),
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

  // ─── Banner status minum obat ─────────────────────────────────────────────
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
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
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
                    color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14,
                  ),
                ),
                Text(
                  isSuccess
                      ? "Berhasil konfirmasi minum obat hari ini 🎉"
                      : "Maaf, Silahkan Konfirmasi Kembali",
                  style: const TextStyle(color: Colors.white, fontSize: 11),
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

  // ─── Header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Row(
          children: [
            Icon(Icons.medical_services, color: Color(0xFF00A355), size: 24),
            SizedBox(width: 8),
            Text(
              "TBC-Tracker",
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF1B4332),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(builder: (context) => const ProfileSettingsPage()),
            );
            
            if (result != null && mounted) {
              setState(() {
                _currentDay = result['startDay'] as int;
                _totalDays = result['targetDay'] as int;
              });
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Jadwal berhasil diperbarui!'),
                  backgroundColor: const Color(0xFF2DC653),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF1B4332),
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
        ),
      ],
    );
  }

  // ─── Greeting ─────────────────────────────────────────────────────────────
  Widget _buildGreeting() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Selamat Pagi, Dinda",
          style: TextStyle(
            fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1B4332),
          ),
        ),
        SizedBox(height: 4),
        Text(
          "Yuk fokus pada pemulihan hari ini.",
          style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ─── Bottom Nav ───────────────────────────────────────────────────────────
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
          _buildNavItem(Icons.calendar_month, 1),
          _buildNavItem(Icons.checklist, 2),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    bool isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          // Ganti ke tab Kalender (tanpa push page)
          setState(() => _currentIndex = index);
        } else if (index == 2) {
          // Buka Halaman Checkup
          setState(() => _currentIndex = index);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DailyCheckupPage()),
          ).then((_) {
            if (mounted) setState(() => _currentIndex = 0);
          });
        } else {
          setState(() => _currentIndex = index);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: isActive
            ? const BoxDecoration(color: Colors.white, shape: BoxShape.circle)
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
