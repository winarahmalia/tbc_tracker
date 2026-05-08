import 'package:flutter/material.dart';
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

  final List<Map<String, dynamic>> _questions = [
    {
      "id": "Q1",
      "category": "Urin",
      "icon": Icons.water_drop_outlined,
      "question": "Apakah air kencing (urin) Anda berwarna merah atau oranye?",
      "isCritical": false,
    },
    {
      "id": "Q2",
      "category": "Fungsi Hati",
      "icon": Icons.visibility_outlined,
      "question": "Apakah bagian putih mata atau kulit Anda terlihat menguning?",
      "isCritical": true,
    },
    {
      "id": "Q3",
      "category": "Pencernaan",
      "icon": Icons.restaurant_menu_outlined,
      "question": "Apakah Anda merasa mual, muntah, atau tidak nafsu makan?",
      "isCritical": true,
    },
    {
      "id": "Q4",
      "category": "Saraf & Sendi",
      "icon": Icons.accessibility_new_outlined,
      "question": "Apakah Anda merasa kesemutan atau nyeri sendi hebat?",
      "isCritical": false,
    },
    {
      "id": "Q5",
      "category": "Sensori",
      "icon": Icons.hearing_outlined,
      "question": "Apakah pandangan kabur atau telinga berdenging tiba-tiba?",
      "isCritical": true,
    },
    {
      "id": "Q6",
      "category": "Pernapasan",
      "icon": Icons.air_outlined,
      "question": "Apakah Anda mengalami sesak napas atau batuk darah?",
      "isCritical": true,
    },
  ];

  void _handleAnswer(bool answer) {
    setState(() {
      _answers[_currentStep] = answer;
      if (answer && _questions[_currentStep]['isCritical']) {
        _showResult(isCritical: true);
        return;
      }
      if (_currentStep < _questions.length - 1) {
        _currentStep++;
      } else {
        bool hasAnyWarning = _answers.values.any((val) => val == true);
        _showResult(isCritical: false, hasWarning: hasAnyWarning);
      }
    });
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

  @override
  Widget build(BuildContext context) {
    var q = _questions[_currentStep];

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
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 30),
              _buildProgressBar(),
              const Expanded(
                child: SizedBox(),
              ),
              _buildMainCard(q),
              const Expanded(
                child: SizedBox(),
              ),
              _buildActionButtons(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Color(0xFF1B4332)),
            onPressed: () => Navigator.pop(context),
          ),
          const Text(
            "Pantau Kondisi",
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    double progress = (_currentStep + 1) / _questions.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFFE8F5E9),
              color: const Color(0xFF40916C),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Pertanyaan ${_currentStep + 1} dari ${_questions.length}",
            style: const TextStyle(
              fontSize: 12, 
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainCard(Map<String, dynamic> q) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFD1F2E1).withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              q['icon'] as IconData,
              color: const Color(0xFF40916C),
              size: 40,
            ),
          ),
          const SizedBox(height: 25),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              q['category'].toString().toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF40916C),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            q['question'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B4332),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          CustomButton(
            text: "Ya, Saya Merasakannya",
            onPressed: () => _handleAnswer(true),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton(
              onPressed: () => _handleAnswer(false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF40916C), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                "Tidak",
                style: TextStyle(
                  color: Color(0xFF40916C),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
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
