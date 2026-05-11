import re

file_path = r"c:\Users\aqila\tbc_tracker\lib\pages\daily_checkup_page.dart"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

new_state_body = """
  int _currentStep = 0;
  final Map<int, bool> _answers = {};
  bool? _selectedAnswer;

  final List<Map<String, dynamic>> _questions = [
    {
      "id": "Q1",
      "category": "Urin",
      "icon": Icons.water_drop_outlined,
      "question": "Apakah air kencing (urin) Anda berwarna merah atau oranye?",
      "subtext": "Perhatikan warna urin Anda saat buang air kecil hari ini.",
      "isCritical": false,
    },
    {
      "id": "Q2",
      "category": "Fungsi Hati",
      "icon": Icons.visibility_outlined,
      "question": "Apakah bagian putih mata atau kulit Anda terlihat menguning?",
      "subtext": "Perubahan warna kuning bisa menjadi tanda masalah pada organ hati Anda.",
      "isCritical": true,
    },
    {
      "id": "Q3",
      "category": "Pencernaan",
      "icon": Icons.restaurant_menu_outlined,
      "question": "Apakah akhir-akhir ini Anda sering merasa mual, ingin muntah, atau kehilangan nafsu makan secara drastis?",
      "subtext": "Pikirkan apakah keinginan makan Anda berkurang drastis sejak memulai pengobatan.",
      "isCritical": true,
    },
    {
      "id": "Q4",
      "category": "Saraf & Sendi",
      "icon": Icons.accessibility_new_outlined,
      "question": "Apakah Anda merasa kesemutan atau nyeri sendi hebat?",
      "subtext": "Perhatikan apakah ada rasa kebas di ujung jari tangan atau kaki.",
      "isCritical": false,
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
  ];

  void _handleBack() async {
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

  void _handleAnswer(bool answer) {
    setState(() {
      _answers[_currentStep] = answer;
      if (answer && _questions[_currentStep]['isCritical']) {
        _showResult(isCritical: true);
        return;
      }
      if (_currentStep < _questions.length - 1) {
        _currentStep++;
        _selectedAnswer = _answers.containsKey(_currentStep) ? _answers[_currentStep] : null;
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
              const SizedBox(height: 35),
              Text(
                q['question'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                q['subtext'],
                style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 35),
              _buildOptionCard(isYes: true),
              _buildOptionCard(isYes: false),
              const Spacer(),
              _buildNextButton(),
              const SizedBox(height: 20),
            ],
          ),
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
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B4332),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
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
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                Text(
                  " / ${_questions.length}",
                  style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              "${percentage}% Selesai",
              style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress == 0 ? 0.05 : progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade300,
            color: const Color(0xFF1B4332),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({required bool isYes}) {
    bool isSelected = _selectedAnswer == isYes;
    
    Color bgColor = isYes ? const Color(0xFFF2FCF5) : const Color(0xFFFFF4F4);
    Color borderColor = isSelected ? (isYes ? const Color(0xFF40916C) : Colors.red.shade300) : Colors.transparent;
    Color iconBgColor = isYes ? const Color(0xFFA5D6BA) : const Color(0xFFF6BDBD);
    Color iconColor = isYes ? const Color(0xFF1B4332) : const Color(0xFFD91E18);
    IconData icon = isYes ? Icons.check_circle : Icons.cancel;
    String title = isYes ? "Ya" : "Tidak";
    String subtitle = isYes ? "Mengalami gejala" : "Tidak mengalami";

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAnswer = isYes;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _selectedAnswer == null ? null : () {
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
    );
  }
"""

start_marker = "class _DailyCheckupPageState extends State<DailyCheckupPage> {"
end_marker = "class CheckupResultPage extends StatelessWidget {"

start_idx = content.find(start_marker)
end_idx = content.find(end_marker)

if start_idx != -1 and end_idx != -1:
    new_content = content[:start_idx] + start_marker + "\n" + new_state_body + "\n}\n\n" + content[end_idx:]
    with open(file_path, "w", encoding="utf-8") as f:
        f.write(new_content)
    print("Successfully replaced.")
else:
    print("Markers not found.")
