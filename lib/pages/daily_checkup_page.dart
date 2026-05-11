import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/colors.dart';
import '../widgets/custom_button.dart';

class DailyCheckupPage extends StatefulWidget {
  const DailyCheckupPage({super.key});

  @override
  State<DailyCheckupPage> createState() => _DailyCheckupPageState();
}

class _DailyCheckupPageState extends State<DailyCheckupPage> {
  int _currentStep = 0;
  final Map<int, bool> _answers = {};
  bool? _selectedAnswer;
  bool _isAnalyzing = false;

  List<Map<String, dynamic>> get _questions => [
    {
      "id": "Q1",
      "category": "Pencernaan",
      "icon": Icons.restaurant_menu_outlined,
      "question": "Apakah akhir-akhir ini Anda sering merasa mual, ingin muntah, atau kehilangan nafsu makan secara drastis?",
      "subtext": "Pikirkan apakah keinginan makan Anda berkurang drastis sejak memulai pengobatan.",
      "isCritical": true,
    },
    {
      "id": "Q2",
      "category": "Saraf & Sendi",
      "icon": Icons.accessibility_new_outlined,
      "question": "Apakah Anda merasa kesemutan, kebas, atau nyeri sendi yang mengganggu aktivitas?",
      "subtext": "Fokus pada area ujung jari tangan atau ujung kaki Anda hari ini.",
      "isCritical": false,
    },
    {
      "id": "Q3",
      "category": "Urin",
      "icon": Icons.water_drop_outlined,
      "question": "Apakah air kencing (urin) Anda berwarna merah atau oranye?",
      "subtext": "Perhatikan warna urin Anda saat buang air kecil hari ini.",
      "isCritical": false,
    },
    {
      "id": "Q4",
      "category": "Fungsi Hati",
      "icon": Icons.visibility_outlined,
      "question": "Apakah bagian putih mata atau kulit Anda terlihat menguning?",
      "subtext": "Perubahan warna kuning bisa menjadi tanda masalah pada organ hati Anda.",
      "isCritical": true,
    },
    {
      "id": "Q5",
      "category": "Sensori",
      "icon": Icons.hearing_outlined,
      "question": "Apakah pandangan kabur atau telinga berdenging tiba-tiba?",
      "subtext": "Gangguan penglihatan atau pendengaran yang tidak biasa.",
      "isCritical": true,
    },
    {
      "id": "Q6",
      "category": "Pernapasan",
      "icon": Icons.air_outlined,
      "question": "Apakah Anda mengalami sesak napas atau batuk darah?",
      "subtext": "Kondisi darurat jika Anda mengeluarkan darah saat batuk.",
      "isCritical": true,
    },
    {
      "id": "Q7",
      "category": "Berat Badan",
      "icon": Icons.monitor_weight_outlined,
      "question": "Apakah berat badan Anda turun secara drastis dalam minggu ini?",
      "subtext": "Penurunan berat badan drastis bisa menjadi tanda infeksi yang belum teratasi.",
      "isCritical": true,
    },
    {
      "id": "Q8",
      "category": "Keringat Malam",
      "icon": Icons.nights_stay_outlined,
      "question": "Apakah Anda sering berkeringat di malam hari tanpa alasan jelas?",
      "subtext": "Keringat malam yang berlebih adalah salah satu gejala spesifik TBC.",
      "isCritical": true,
    },
    {
      "id": "Q9",
      "category": "Kelelahan",
      "icon": Icons.battery_alert_outlined,
      "question": "Apakah Anda merasa sangat lelah walau tidak melakukan aktivitas berat?",
      "subtext": "Badan yang terus-menerus terasa lemas butuh perhatian ekstra.",
      "isCritical": false,
    },
    {
      "id": "Q10",
      "category": "Obat",
      "icon": Icons.medication_outlined,
      "question": "Apakah Anda mengalami ruam gatal di kulit setelah minum obat?",
      "subtext": "Reaksi alergi obat sangat penting untuk segera dilaporkan.",
      "isCritical": true,
    },
  ];

  void _handleBack() async {
    HapticFeedback.lightImpact();
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _selectedAnswer = _answers[_currentStep];
      });
    } else {
      bool? shouldExit = await _showExitConfirmation();
      if (shouldExit == true && mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _handleAnswer(bool answer) async {
    HapticFeedback.lightImpact();
    setState(() {
      _answers[_currentStep] = answer;
    });

    if (_currentStep < _questions.length - 1) {
      setState(() {
        _currentStep++;
        _selectedAnswer = _answers.containsKey(_currentStep) ? _answers[_currentStep] : null;
      });
    } else {
      bool isCritical = false;
      bool hasAnyWarning = false;

      for (int i = 0; i < _questions.length; i++) {
        if (_answers[i] == true) {
          hasAnyWarning = true;
          if (_questions[i]['isCritical'] == true) {
            isCritical = true;
          }
        }
      }

      await _processAndShowResult(isCritical: isCritical, hasWarning: hasAnyWarning);
    }
  }

  Future<void> _processAndShowResult({required bool isCritical, bool hasWarning = false}) async {
    setState(() {
      _isAnalyzing = true;
    });

    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;

    _showResult(isCritical: isCritical, hasWarning: hasWarning);
  }


  void _showResult({required bool isCritical, bool hasWarning = false}) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CheckupResultPage(
          isCritical: isCritical,
          hasWarning: hasWarning,
        ),
      ),
    );
  }

  Future<bool?> _showExitConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Batalkan Pengecekan?",
          style: TextStyle(color: Color(0xFF1B4332), fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Anda belum menyelesaikan pengecekan kondisi hari ini. Yakin ingin keluar?",
          style: TextStyle(color: Colors.grey, fontSize: 14),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Tidak", style: TextStyle(color: Color(0xFF40916C), fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD91E18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isAnalyzing) return _buildLoadingScreen();

    var q = _questions[_currentStep];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildProgressBar(),
              const SizedBox(height: 30),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: SingleChildScrollView(
                    key: ValueKey<int>(_currentStep),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          q['question'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E1E1E),
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 15),
                        Text(
                          q['subtext'] ?? "",
                          style: const TextStyle(
                            fontSize: 15, 
                            color: Color(0xFF555555),
                            height: 1.5, 
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 35),
                        _buildOptionCard(isYes: true),
                        _buildOptionCard(isYes: false),
                      ],
                    ),
                  ),
                ),
              ),
              _buildNextButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF40916C)),
            ),
            const SizedBox(height: 30),
            const Text(
              "Menganalisis kondisi Anda...",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Harap tunggu sebentar",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B4332)),
          onPressed: _handleBack,
          padding: EdgeInsets.zero,
          alignment: Alignment.centerLeft,
        ),
        const Text(
          "Cek",
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4332),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildProgressBar() {
    double progress = (_currentStep) / _questions.length;
    int percentage = (progress * 100).toInt();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "PERTANYAAN",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B4332),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  "${_currentStep + 1}",
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black),
                ),
                Text(
                  " / ${_questions.length}",
                  style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                "$percentage% Selesai",
                style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  width: constraints.maxWidth * (progress == 0 ? 0.05 : progress),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B4332), Color(0xFF40916C)],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({required bool isYes}) {
    bool isSelected = _selectedAnswer == isYes;
    
    Color bgColor = isYes ? const Color(0xFFF2FCF5) : const Color(0xFFFFF4F4);
    Color borderColor = isSelected ? (isYes ? const Color(0xFF40916C) : Colors.red.shade300) : const Color(0xFFEFEFEF);
    Color iconBgColor = isYes ? const Color(0xFFA5D6BA) : const Color(0xFFF6BDBD);
    Color iconColor = isYes ? const Color(0xFF1B4332) : const Color(0xFFD91E18);
    IconData icon = isYes ? Icons.check_circle : Icons.cancel;
    String title = isYes ? "Ya" : "Tidak";
    String subtitle = isYes ? "Mengalami gejala" : "Tidak mengalami";

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _selectedAnswer = isYes;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(vertical: 25),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Colors.black)),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: 220,
        height: 55,
        child: ElevatedButton(
          onPressed: _selectedAnswer == null ? null : () {
            HapticFeedback.lightImpact();
            _handleAnswer(_selectedAnswer!);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2DC653),
            disabledBackgroundColor: Colors.grey.shade300,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 0,
          ),
          child: const Text("Next", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class CheckupResultPage extends StatelessWidget {
  final bool isCritical;
  final bool hasWarning;

  const CheckupResultPage({
    super.key,
    required this.isCritical,
    required this.hasWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 30),
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [AppColors.lightGreen, Colors.white],
            center: Alignment(0, -0.6),
            radius: 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: isCritical 
                    ? Colors.red.withOpacity(0.1) 
                    : (hasWarning ? Colors.orange.withOpacity(0.1) : const Color(0xFFD1F2E1)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCritical ? Icons.warning_rounded : (hasWarning ? Icons.info_outline : Icons.check_circle_outline),
                size: 80,
                color: isCritical ? Colors.red : (hasWarning ? Colors.orange : const Color(0xFF40916C)),
              ),
            ),
            const SizedBox(height: 30),
            Text(
              isCritical ? "KONDISI KRITIS!" : (hasWarning ? "PERLU PERHATIAN" : "KONDISI BAIK"),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isCritical ? Colors.red : (hasWarning ? Colors.orange : const Color(0xFF1B4332)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isCritical
                  ? "Segera hubungi dokter atau layanan kesehatan terdekat. Gejala yang Anda alami memerlukan penanganan medis segera."
                  : (hasWarning
                      ? "Ada beberapa gejala yang Anda rasakan. Tetap patuh minum obat dan konsultasikan gejala ini pada kunjungan dokter berikutnya."
                      : "Luar biasa! Pertahankan kepatuhan minum obat Anda untuk pemulihan yang sempurna."),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.6),
            ),
            const SizedBox(height: 60),
            CustomButton(
              text: "Kembali ke Beranda",
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
