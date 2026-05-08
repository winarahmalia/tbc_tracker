import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/custom_button.dart';

class ScheduleSetupPage extends StatefulWidget {
  const ScheduleSetupPage({super.key});

  @override
  State<ScheduleSetupPage> createState() => _ScheduleSetupPageState();
}

class _ScheduleSetupPageState extends State<ScheduleSetupPage> {
  bool _isDaily = true;
  bool _reminderOn = true;

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
            _buildSectionHeader(Icons.calendar_today_outlined, "Rentang Pengobatan"),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildDateInput("MULAI", "Ketik \"Hari ke-\"")),
                const SizedBox(width: 20),
                const Icon(Icons.arrow_right_alt, color: Color(0xFF40916C)),
                const SizedBox(width: 20),
                Expanded(child: _buildDateInput("TARGET", "Ketik \"Hari ke-\"")),
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
            _buildSectionHeader(Icons.access_time, "Waktu Minum Obat"),
            const SizedBox(height: 15),
            _buildTimePicker(),
            const SizedBox(height: 40),
            _buildReminderSection(),
            const SizedBox(height: 40),
            _buildSectionHeader(Icons.calendar_month_outlined, "Frekuensi"),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: _buildFrequencyButton("Setiap Hari", _isDaily, () => setState(() => _isDaily = true))),
                const SizedBox(width: 15),
                Expanded(child: _buildFrequencyButton("Pilih Hari", !_isDaily, () => setState(() => _isDaily = false))),
              ],
            ),
            const SizedBox(height: 50),
            CustomButton(
              text: "Simpan Jadwal",
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF40916C)),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
        ),
      ],
    );
  }

  Widget _buildDateInput(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
            filled: true,
            fillColor: const Color(0xFFD1F2E1).withOpacity(0.3),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFD1F2E1).withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimeBox("08", "JAM"),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(":", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          _buildTimeBox("00", "MENIT"),
          const SizedBox(width: 20),
          Column(
            children: [
              _buildAmPmBox("AM", true),
              const SizedBox(height: 5),
              _buildAmPmBox("PM", false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBox(String val, String label) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
        ),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildAmPmBox(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF40916C) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isActive ? Colors.transparent : Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isActive ? Colors.white : Colors.grey,
        ),
      ),
    );
  }

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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1B4332)),
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
          activeColor: const Color(0xFF40916C),
        ),
      ],
    );
  }

  Widget _buildFrequencyButton(String text, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF40916C) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isActive ? Colors.transparent : Colors.grey.shade300),
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
}
