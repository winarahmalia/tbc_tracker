import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../services/schedule_service.dart';

class ScheduleSetupPage extends StatefulWidget {
  const ScheduleSetupPage({super.key});

  @override
  State<ScheduleSetupPage> createState() => _ScheduleSetupPageState();
}

class _ScheduleSetupPageState extends State<ScheduleSetupPage> {
  bool _isDaily = true;
  bool _reminderOn = true;

  // Time picker state
  int _selectedHour = 8;   // 1–12
  int _selectedMinute = 0; // 0–59
  bool _isAM = true;

  // Day picker state
  final List<String> _dayLabels = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
  final List<bool> _selectedDays = List.filled(7, false);

  // Rentang pengobatan
  final _startController = TextEditingController();
  final _targetController = TextEditingController();

  // Scroll controllers
  late final FixedExtentScrollController _hourController;
  late final FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hourController = FixedExtentScrollController(initialItem: _selectedHour - 1);
    _minuteController = FixedExtentScrollController(initialItem: _selectedMinute);
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    _startController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  Future<void> _saveSchedule() async {
    // Validasi: jika "Pilih Hari", minimal 1 hari harus dipilih
    if (!_isDaily && !_selectedDays.contains(true)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Pilih minimal 1 hari terlebih dahulu!'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final startText = _startController.text.trim();
    final targetText = _targetController.text.trim();

    if (startText.isEmpty || targetText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Hari mulai dan hari target harus diisi!'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    final startDay = int.tryParse(startText);
    final targetDay = int.tryParse(targetText);

    if (startDay == null || targetDay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Hari mulai dan hari target harus berupa angka!'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    if (startDay >= targetDay) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Hari target harus lebih besar dari hari mulai!'),
          backgroundColor: Colors.red.shade400,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    // Format waktu pengingat (misal: "08:00 AM")
    final hour = _selectedHour.toString().padLeft(2, '0');
    final minute = _selectedMinute.toString().padLeft(2, '0');
    final period = _isAM ? 'AM' : 'PM';
    final reminderTime = '$hour:$minute $period';

    // Daftar hari yang dipilih (jika mode pilih hari)
    final selectedDayLabels = _isDaily
        ? <String>[]
        : [
            for (int i = 0; i < _selectedDays.length; i++)
              if (_selectedDays[i]) _dayLabels[i]
          ];

    try {
      // Simpan jadwal ke Supabase
      await ScheduleService.saveSchedule(
        startDay: startDay,
        targetDay: targetDay,
        reminderTime: _reminderOn ? reminderTime : null,
        isDaily: _isDaily,
        selectedDays: selectedDayLabels,
      );

      if (mounted) {
        // Kembalikan data jadwal ke HomePage
        Navigator.pop(context, {
          'startDay': startDay,
          'targetDay': targetDay,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan jadwal: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

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
          "Atur Jadwal Minum Obat",
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // --- Rentang Pengobatan ---
            _buildSectionHeader(Icons.calendar_today_outlined, "Rentang Pengobatan"),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildDateInput("MULAI", "Ketik \"Hari ke-\"", _startController)),
                const SizedBox(width: 20),
                const Icon(Icons.arrow_right_alt, color: Color(0xFF40916C)),
                const SizedBox(width: 20),
                Expanded(child: _buildDateInput("TARGET", "Ketik \"Hari ke-\"", _targetController)),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top: 10),
              child: Text(
                "\"Perjalanan kesembuhanmu dimulai dari sini.\"",
                style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 40),

            // --- Waktu Minum Obat ---
            _buildSectionHeader(Icons.access_time, "Waktu Minum Obat"),
            const SizedBox(height: 15),
            _buildScrollTimePicker(),
            const SizedBox(height: 40),

            // --- Pengingat ---
            _buildReminderSection(),
            const SizedBox(height: 40),

            // --- Frekuensi ---
            _buildSectionHeader(Icons.calendar_month_outlined, "Frekuensi"),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildFrequencyButton(
                    "Setiap Hari", _isDaily, () => setState(() => _isDaily = true),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildFrequencyButton(
                    "Pilih Hari", !_isDaily, () => setState(() => _isDaily = false),
                  ),
                ),
              ],
            ),

            // --- Pilih Hari (muncul kalau "Pilih Hari" aktif) ---
            if (!_isDaily) ...[
              const SizedBox(height: 20),
              _buildDaySelector(),
            ],

            const SizedBox(height: 50),
            CustomButton(
              text: "Simpan Jadwal",
              onPressed: _saveSchedule,
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ─── Section Header ──────────────────────────────────────────────────────────

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF40916C)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4332),
          ),
        ),
      ],
    );
  }

  // ─── Date Input ──────────────────────────────────────────────────────────────

  Widget _buildDateInput(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFD1F2E1).withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        ),
      ],
    );
  }

  // ─── Scroll Time Picker ───────────────────────────────────────────────────────

  Widget _buildScrollTimePicker() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFD1F2E1).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // JAM
          _buildScrollWheel(
            label: "JAM",
            itemCount: 12,
            controller: _hourController,
            displayBuilder: (i) => (i + 1).toString().padLeft(2, '0'),
            onSelected: (i) => setState(() => _selectedHour = i + 1),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 18),
            child: Text(":", style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1B4332))),
          ),
          // MENIT
          _buildScrollWheel(
            label: "MENIT",
            itemCount: 60,
            controller: _minuteController,
            displayBuilder: (i) => i.toString().padLeft(2, '0'),
            onSelected: (i) => setState(() => _selectedMinute = i),
          ),
          const SizedBox(width: 20),
          // AM / PM
          Column(
            children: [
              _buildAmPmBox("AM", _isAM, () => setState(() => _isAM = true)),
              const SizedBox(height: 8),
              _buildAmPmBox("PM", !_isAM, () => setState(() => _isAM = false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScrollWheel({
    required String label,
    required int itemCount,
    required FixedExtentScrollController controller,
    required String Function(int) displayBuilder,
    required void Function(int) onSelected,
  }) {
    return Column(
      children: [
        SizedBox(
          height: 120,
          width: 64,
          child: ListWheelScrollView.useDelegate(
            controller: controller,
            itemExtent: 44,
            perspective: 0.003,
            diameterRatio: 1.8,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: onSelected,
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: itemCount,
              builder: (context, index) {
                final isSelected = controller.selectedItem == index;
                return Center(
                  child: Text(
                    displayBuilder(index),
                    style: TextStyle(
                      fontSize: isSelected ? 36 : 22,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? const Color(0xFF1B4332)
                          : Colors.grey.shade400,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAmPmBox(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF40916C) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  // ─── Reminder ─────────────────────────────────────────────────────────────────

  Widget _buildReminderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.notifications_none, size: 20, color: Color(0xFF40916C)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pengingat",
                  style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4332),
                  ),
                ),
                Text(
                  "Ingatkan saya 15 menit sebelum",
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
        Switch(
          value: _reminderOn,
          onChanged: (val) => setState(() => _reminderOn = val),
          activeThumbColor: const Color(0xFF40916C),
        ),
      ],
    );
  }

  // ─── Frequency Button ─────────────────────────────────────────────────────────

  Widget _buildFrequencyButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF40916C) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? Colors.transparent : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ─── Day Selector ─────────────────────────────────────────────────────────────

  Widget _buildDaySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pilih hari minum obat:",
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            final isSelected = _selectedDays[i];
            return GestureDetector(
              onTap: () => setState(() => _selectedDays[i] = !_selectedDays[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF40916C) : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF40916C).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  _dayLabels[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
