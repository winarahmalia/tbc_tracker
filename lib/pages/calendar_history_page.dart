import 'package:flutter/material.dart';

class CalendarHistoryPage extends StatefulWidget {
  final bool isTaken;
  final Set<DateTime> takenDates;
  final DateTime? scheduleStartDate;
  final bool isTab;
  final int currentDay;
  final int totalDays;

  const CalendarHistoryPage({
    super.key,
    this.isTaken = false,
    this.takenDates = const {},
    this.scheduleStartDate,
    this.isTab = false,
    this.currentDay = 0,
    this.totalDays = 0,
  });

  @override
  State<CalendarHistoryPage> createState() => _CalendarHistoryPageState();
}

class _CalendarHistoryPageState extends State<CalendarHistoryPage> {
  late DateTime _displayedMonth;
  final DateTime _today = DateTime.now();

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime(_today.year, _today.month);
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isToday(DateTime d) => _isSameDay(d, _today);

  bool _isTakenDay(DateTime d) =>
      widget.takenDates.any((t) => _isSameDay(t, d));

  // Apakah hari ini sudah lewat dalam rentang jadwal dan tidak diminum?
  bool _isMissedDay(DateTime d) {
    if (widget.scheduleStartDate == null) return false;
    final start = DateTime(
      widget.scheduleStartDate!.year,
      widget.scheduleStartDate!.month,
      widget.scheduleStartDate!.day,
    );
    final day = DateTime(d.year, d.month, d.day);
    // Sudah lewat, dalam jadwal, dan tidak ada di takenDates
    return day.isBefore(DateTime(_today.year, _today.month, _today.day)) &&
        !day.isBefore(start) &&
        !_isTakenDay(d);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: widget.isTab 
            ? null 
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
        title: const Text(
          "Jadwal Minum Obat",
          style: TextStyle(
              color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
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
            const SizedBox(height: 16),
            _buildLegend(),
            const SizedBox(height: 40),
            _buildStatusSection(),
          ],
        ),
      ),
    );
  }

  // ─── Header Bulan ──────────────────────────────────────────────────────────
  Widget _buildCalendarHeader() {
    final monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final label = "${monthNames[_displayedMonth.month]} ${_displayedMonth.year}";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
        ),
        Row(
          children: [
            IconButton(
                icon: const Icon(Icons.chevron_left), onPressed: _prevMonth),
            IconButton(
                icon: const Icon(Icons.chevron_right), onPressed: _nextMonth),
          ],
        ),
      ],
    );
  }

  // ─── Grid Kalender Dinamis ─────────────────────────────────────────────────
  Widget _buildCalendarGrid() {
    const dayHeaders = ["MIN", "SEN", "SEL", "RAB", "KAM", "JUM", "SAB"];

    // Hari pertama bulan ini (0=Min, 1=Sen, ..., 6=Sab)
    final firstDay = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final startWeekday = firstDay.weekday % 7; // jadikan 0=Min

    // Jumlah hari dalam bulan ini
    final daysInMonth =
        DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;

    // Buat list slot (null = kosong, int = tanggal)
    final List<int?> slots = [
      ...List.filled(startWeekday, null),
      ...List.generate(daysInMonth, (i) => i + 1),
    ];

    // Tambahin null di belakang supaya genap 7 kolom
    while (slots.length % 7 != 0) {
      slots.add(null);
    }

    final rows = <List<int?>>[];
    for (int i = 0; i < slots.length; i += 7) {
      rows.add(slots.sublist(i, i + 7));
    }

    return Column(
      children: [
        // Header hari
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: dayHeaders
              .map((d) => Expanded(
                    child: Center(
                      child: Text(d,
                          style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        // Baris-baris tanggal
        ...rows.map((row) => _buildCalendarRow(row)),
      ],
    );
  }

  Widget _buildCalendarRow(List<int?> dates) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: dates.map((date) {
          if (date == null) return const Expanded(child: SizedBox());

          final d = DateTime(_displayedMonth.year, _displayedMonth.month, date);
          final isToday = _isToday(d);
          final isTaken = _isTakenDay(d);
          final isMissed = _isMissedDay(d);

          Color? bgColor;
          Color textColor = const Color(0xFF064E3B);
          BoxBorder? border;

          if (isTaken) {
            // Sudah minum hari ini → hijau 75%
            if (isToday) {
              bgColor = const Color(0xFF2ECC71).withOpacity(0.75);
            } else {
              // Hari lalu sudah minum → hijau 50%
              bgColor = const Color(0xFF2ECC71).withOpacity(0.50);
            }
            textColor = Colors.white;
          } else if (isToday && !widget.isTaken) {
            // Hari ini belum minum → merah
            bgColor = const Color(0xFFC13536).withOpacity(0.1);
            border = Border.all(color: const Color(0xFFC13536), width: 1.5);
            textColor = const Color(0xFFC13536);
          } else if (isMissed) {
            // Hari lalu dalam jadwal, tidak minum → merah
            bgColor = const Color(0xFFC13536).withOpacity(0.1);
            textColor = const Color(0xFFC13536);
          }

          return Expanded(
            child: Center(
              child: Container(
                width: 35,
                height: 35,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                  border: border,
                ),
                child: Text(
                  "$date",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─── Legenda ───────────────────────────────────────────────────────────────
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(const Color(0xFF74C69D), "Sudah minum"),
        const SizedBox(width: 20),
        _legendItem(Colors.red.withOpacity(0.5), "Belum minum"),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }

  // ─── Status Bawah ─────────────────────────────────────────────────────────
  Widget _buildStatusSection() {
    final remaining = widget.totalDays - widget.currentDay;
    final hasSchedule = widget.totalDays > 0;

    return Column(
      children: [
        if (hasSchedule) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Hari ini",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(
                "Hari ke ${widget.currentDay}",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Sisa hari",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(
                remaining > 0 ? "$remaining hari lagi" : "Selesai!",
                style: TextStyle(
                  fontSize: 14,
                  color: remaining > 0
                      ? const Color(0xFF006D37)
                      : const Color(0xFF2ECC71),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          decoration: BoxDecoration(
            color: widget.isTaken
                ? const Color(0xFF74C69D).withOpacity(0.2)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Text(
            widget.isTaken
                ? "Kamu Sudah Minum Obat Hari Ini"
                : "Kamu Belum Minum Obat Hari Ini!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
                  widget.isTaken ? const Color(0xFF2D6A4F) : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
