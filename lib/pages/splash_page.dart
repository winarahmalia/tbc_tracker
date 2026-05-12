import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'login_page.dart';
import 'home_page.dart';
import 'dart:async';
import '../services/auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  int _quoteIndex = 0;
  final List<String> _quotes = [
    "Satu dosis hari ini, satu langkah menuju pulih.",
    "Setiap hari patuh minum obat adalah keberanian yang nyata",
    "Pantau kesehatanmu hari ini, nikmati hidup sehatmu esok hari",
  ];

  late Timer _quoteTimer;

  @override
  void initState() {
    super.initState();

    // Rotasi quote setiap 1.5 detik
    _quoteTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          _quoteIndex = (_quoteIndex + 1) % _quotes.length;
        });
      }
    });

    // Cek sesi aktif lalu navigasi setelah 3 detik
    Future.delayed(const Duration(seconds: 3), _checkSessionAndNavigate);
  }

  /// Cek apakah user sudah login. Jika iya, langsung ke HomePage.
  /// Jika tidak, arahkan ke LoginPage.
  Future<void> _checkSessionAndNavigate() async {
    if (!mounted) return;

    try {
      final profile = await AuthService.getCurrentProfile();

      if (!mounted) return;

      if (profile != null) {
        // Sesi aktif — langsung masuk ke HomePage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              userName: profile.name,
              userEmail: profile.email,
              userId: profile.id,
            ),
          ),
        );
      } else {
        // Tidak ada sesi — arahkan ke LoginPage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } catch (_) {
      // Jika ada error, tetap arahkan ke LoginPage
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  void dispose() {
    _quoteTimer.cancel();
    super.dispose();
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            _buildLogo(),
            const SizedBox(height: 20),
            const Text(
              "Pantau. Patuh. Pulih.",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
              ),
            ),
            const Spacer(flex: 2),
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: Color(0xFF40916C),
                strokeWidth: 4,
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _quotes[_quoteIndex],
                  key: ValueKey<int>(_quoteIndex),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B4332),
                    height: 1.4,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF00A355),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 60),
            ),
            ...List.generate(4, (index) {
              return Positioned(
                left: index % 2 == 0 ? 15 : null,
                right: index % 2 != 0 ? 15 : null,
                top: index < 2 ? 15 : null,
                bottom: index >= 2 ? 15 : null,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 15),
        const Text(
          "TBC\nTracker",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1B4332),
            letterSpacing: 1.2,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
