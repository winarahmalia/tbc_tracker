import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/streak_card.dart';
import '../widgets/medication_card.dart';
import '../widgets/info_carousel.dart';
import '../services/schedule_service.dart';
import '../services/medication_service.dart';
import '../services/profile_service.dart';
import '../services/cache_service.dart';
import '../models/schedule_model.dart';
import 'schedule_setup_page.dart';
import 'calendar_history_page.dart';
import 'profile_settings_page.dart';
import 'daily_checkup_page.dart';

class HomePage extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final String? userId;
  const HomePage({super.key, this.userName, this.userEmail, this.userId});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  String? _statusMessage;

  // ─── Profile state ─────────────────────────────────────────────────────────
  String _currentName = '';
  String _currentEmail = '';
  String? _currentAvatarUrl;

  // ─── Streak state ──────────────────────────────────────────────────────────
  int _streakDays = 0;
  List<bool> _completionHistory = [false, false, false, false, false, false];

  // ─── Jadwal state ─────────────────────────────────────────────────────────
  bool _scheduleSet = false;
  int _currentDay = 1;
  int _totalDays = 100;
  bool _isTaken = false;
  bool _isMedicationDay = true;
  bool _isCompleted = false;
  Set<DateTime> _takenDates = {};
  DateTime? _scheduleStartDate;
  bool _isLoadingSchedule = true;

  double get _percentage {
    final total = _totalDays;
    if (total <= 0) return 0;
    return (((_currentDay - 1 + (_isTaken ? 1 : 0)) / total) * 100)
        .clamp(0, 100);
  }

  @override
  void initState() {
    super.initState();
    _currentName = widget.userName ?? 'Pengguna';
    _currentEmail = widget.userEmail ?? '';
    _loadProfileData();
    _loadScheduleFromDatabase();
    _loadMedicationData();
  }

  // ─── Load profil terkini ──────────────────────────────────────────────────
  Future<void> _loadProfileData() async {
    try {
      final profile = await ProfileService.getProfile();
      if (mounted && profile != null) {
        setState(() {
          _currentName = profile.name;
          _currentEmail = profile.email;
          _currentAvatarUrl = profile.avatarUrl;
        });
      }
    } catch (_) {}
  }

  // ─── Load data minum obat (Streak) ─────────────────────────────────────────
  Future<void> _loadMedicationData() async {
    try {
      final history = await MedicationService.getMedicationHistory();
      final streak = await MedicationService.calculateCurrentStreak();

      // Cache untuk offline
      final dateStrings =
          history.map((d) => d.toIso8601String()).toList();
      await CacheService.cacheTakenDates(dateStrings);
      await CacheService.cacheStreak(streak);

      if (!mounted) return;

      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      
      bool takenToday = history.any((d) => 
        d.year == todayDate.year && d.month == todayDate.month && d.day == todayDate.day);

      // Hitung 6 hari ke belakang untuk completionHistory
      List<bool> recentHistory = [];
      for (int i = 0; i < 6; i++) {
        DateTime checkDate = todayDate.subtract(Duration(days: i));
        bool found = history.any((d) => 
          d.year == checkDate.year && d.month == checkDate.month && d.day == checkDate.day);
        recentHistory.add(found);
      }

      setState(() {
        _streakDays = streak;
        _isTaken = takenToday;
        _takenDates = history.toSet();
        _completionHistory = recentHistory;
      });
    } catch (e) {
      debugPrint('Error loading medication data, fallback ke cache: $e');
      // Fallback ke cache lokal saat offline
      _loadMedicationFromCache();
    }
  }

  Future<void> _loadMedicationFromCache() async {
    final cachedDates = await CacheService.getCachedTakenDates();
    final cachedStreak = await CacheService.getCachedStreak();

    if (cachedDates == null || cachedDates.isEmpty) return;

    final history =
        cachedDates.map((s) => DateTime.parse(s)).toList();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    bool takenToday = history.any((d) =>
        d.year == todayDate.year &&
        d.month == todayDate.month &&
        d.day == todayDate.day);

    List<bool> recentHistory = [];
    for (int i = 0; i < 6; i++) {
      DateTime checkDate = todayDate.subtract(Duration(days: i));
      bool found = history.any((d) =>
          d.year == checkDate.year &&
          d.month == checkDate.month &&
          d.day == checkDate.day);
      recentHistory.add(found);
    }

    if (mounted) {
      setState(() {
        _streakDays = cachedStreak;
        _isTaken = takenToday;
        _takenDates = history.toSet();
        _completionHistory = recentHistory;
      });
    }
  }

  // ─── Hitung hari ke berapa sekarang sejak jadwal dimulai ────────────────
  int _calculateCurrentDay(ScheduleModel schedule) {
    final now = DateTime.now();
    final startDate = schedule.createdAt;
    final daysElapsed = now.difference(startDate).inDays;
    final computedDay = schedule.startDay + daysElapsed;

    // Tidak boleh kurang dari startDay
    if (computedDay < schedule.startDay) return schedule.startDay;
    return computedDay;
  }

  // ─── Cek apakah hari ini termasuk jadwal minum (untuk mode pilih hari) ──
  bool _isTodayMedicationDay(ScheduleModel schedule) {
    if (schedule.isDaily) return true;
    if (schedule.selectedDays.isEmpty) return true;

    // Nama hari dalam Bahasa Indonesia (cocok dengan isi selectedDays)
    const dayNames = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    final today = DateTime.now();
    final todayName = dayNames[today.weekday % 7]; // DateTime.monday = 1
    return schedule.selectedDays.contains(todayName);
  }

  // ─── Load jadwal dari Supabase ─────────────────────────────────────────────
  Future<void> _loadScheduleFromDatabase() async {
    try {
      final schedule = await ScheduleService.getActiveSchedule();
      if (mounted && schedule != null) {
        final currentDay = _calculateCurrentDay(schedule);
        final isMedicationDay = _isTodayMedicationDay(schedule);
        final isCompleted = currentDay > schedule.targetDay;

        setState(() {
          _scheduleSet = true;
          _currentDay = currentDay;
          _totalDays = schedule.targetDay;
          _scheduleStartDate = schedule.createdAt;
          _isMedicationDay = isMedicationDay;
          _isCompleted = isCompleted;
        });
      }
    } catch (e) {
      debugPrint('[HomePage] Gagal load jadwal: $e');
    } finally {
      if (mounted) setState(() => _isLoadingSchedule = false);
    }
  }

  // ─── Buka halaman setup jadwal ────────────────────────────────────────────
  void _openScheduleSetup() async {
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text("Ya, Edit",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const ScheduleSetupPage()),
    );

    if (result != null && mounted) {
      // Reload schedule from DB to get updated values + reschedule notification
      await _loadScheduleFromDatabase();
      await _loadMedicationData();

      if (mounted) {
        setState(() => _isTaken = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Jadwal berhasil disimpan!'),
            backgroundColor: const Color(0xFF40916C),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  // ─── Konfirmasi minum obat hari ini ───────────────────────────────────────
  Future<void> _confirmMedication() async {
    final today = DateTime.now();
    
    // Optimistic UI update
    setState(() {
      _isTaken = true;
      _streakDays += 1;
      _statusMessage = "success";
      _takenDates = {
        ..._takenDates,
        DateTime(today.year, today.month, today.day)
      };
      _completionHistory = [true, ..._completionHistory.take(5)];
    });

    try {
      await MedicationService.logMedication(today);
    } catch (e) {
      // Revert if failed
      if (mounted) {
        setState(() {
          _isTaken = false;
          _streakDays -= 1;
          _statusMessage = null;
          _takenDates.remove(DateTime(today.year, today.month, today.day));
          _completionHistory[0] = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan riwayat: $e')),
        );
      }
    }
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
                        padding:
                            const EdgeInsets.symmetric(horizontal: 25),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _buildHeader(),
                            const SizedBox(height: 20),
                            if (_statusMessage != null) _buildStatusBanner(),
                            if (_statusMessage != null)
                              const SizedBox(height: 10),
                            _buildGreeting(),
                            const SizedBox(height: 25),

                            // Streak Card
                            StreakCard(
                              streakDays: _streakDays,
                              completionHistory: _completionHistory,
                            ),
                            const SizedBox(height: 25),

                            // Card Jadwal / Loading / Setup
                            if (_isLoadingSchedule)
                              _buildLoadingScheduleCard()
                            else if (!_scheduleSet)
                              _buildSetupScheduleCard()
                            else if (_isCompleted)
                              _buildCompletedTreatmentCard()
                            else if (!_isMedicationDay)
                              _buildOffDayCard()
                            else
                              MedicationCard(
                                currentDay: _currentDay,
                                totalDays: _totalDays,
                                percentage: _percentage,
                                isTaken: _isTaken,
                                onSeeAllPressed: _openScheduleSetup,
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

  // ─── Loading skeleton jadwal ───────────────────────────────────────────────
  Widget _buildLoadingScheduleCard() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF40916C),
          strokeWidth: 2,
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
          color: const Color(0xFF2ECC71).withOpacity(0.05),
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
                border:
                    Border.all(color: const Color(0xFF1B4332), width: 2.5),
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
                  color: Color(0xFF1B4332)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedTreatmentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4332),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          const Icon(Icons.celebration, size: 48, color: Color(0xFF2ECC71)),
          const SizedBox(height: 12),
          const Text(
            "Selamat! Pengobatan Selesai",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Kamu telah menyelesaikan seluruh rangkaian pengobatan. Tetap jaga kesehatan!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFFD1F2E1), fontSize: 13),
          ),
          const SizedBox(height: 15),
          IconButton(
            onPressed: _openScheduleSetup,
            icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildOffDayCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Jadwal Minum Obat",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B4332),
                ),
              ),
              IconButton(
                onPressed: _openScheduleSetup,
                icon: const Icon(Icons.edit_outlined, color: Color(0xFF006D37), size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "Hari ke $_currentDay dari $_totalDays",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Row(
              children: [
                Icon(Icons.notifications_off_outlined, color: Color(0xFFD97706), size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Hari ini tidak ada jadwal minum obat. Tetap jaga kesehatan!",
                    style: TextStyle(color: Color(0xFF92400E), fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
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
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  "Cek gejala Anda hari ini untuk memastikan pemulihan berjalan lancar.",
                  style:
                      TextStyle(color: Color(0xFFD1F2E1), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const DailyCheckupPage()),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF40916C),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              elevation: 0,
            ),
            child: const Text(
              "Mulai",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        color: isSuccess
            ? const Color(0xFF2DC653)
            : const Color(0xFFD91E18),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration:
                const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(
              isSuccess ? Icons.check : Icons.close,
              color: isSuccess
                  ? const Color(0xFF2DC653)
                  : const Color(0xFFD91E18),
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
                      fontSize: 14),
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
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF1B4332)),
            ),
          ],
        ),
        GestureDetector(
          onTap: () async {
            final result = await Navigator.push<Map<String, dynamic>>(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileSettingsPage(
                  initialName: _currentName,
                  initialEmail: _currentEmail,
                  userId: widget.userId ?? "",
                ),
              ),
            );

            // Re-fetch profile data just in case it was updated
            if (mounted) {
              await _loadProfileData();
            }

            if (result != null && mounted) {
              await _loadScheduleFromDatabase();
              await _loadMedicationData();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Data berhasil diperbarui!'),
                  backgroundColor: const Color(0xFF2DC653),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          child: _currentAvatarUrl != null
              ? CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFF1B4332),
                  backgroundImage: NetworkImage(_currentAvatarUrl!),
                )
              : const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFF1B4332),
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    final greeting = hour < 10
        ? 'Selamat Pagi'
        : hour < 15
            ? 'Selamat Siang'
            : hour < 18
                ? 'Selamat Sore'
                : 'Selamat Malam';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "$greeting, $_currentName",
          style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332)),
        ),
        const SizedBox(height: 4),
        const Text(
          "Yuk fokus pada pemulihan hari ini.",
          style: TextStyle(
              fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
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
        if (index == 2) {
          setState(() => _currentIndex = index);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DailyCheckupPage()),
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
          color: isActive
              ? const Color(0xFF1B4332)
              : Colors.white.withOpacity(0.6),
          size: 28,
        ),
      ),
    );
  }
}
