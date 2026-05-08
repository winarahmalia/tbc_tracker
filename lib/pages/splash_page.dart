import 'package:flutter/material.dart';
import '../constants/colors.dart';
import 'login_page.dart';
import 'dart:async';

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

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Rotate quotes every 1.5 seconds
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted) {
        setState(() {
          _quoteIndex = (_quoteIndex + 1) % _quotes.length;
        });
      }
    });

    // Navigate to Login after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
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
            // Logo Section
            _buildLogo(),
            const SizedBox(height: 20),
            // Slogan
            const Text(
              "Pantau. Patuh. Pulih.",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B4332),
              ),
            ),
            const Spacer(flex: 2),
            // Loading Indicator
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: Color(0xFF40916C),
                strokeWidth: 4,
              ),
            ),
            const Spacer(flex: 2),
            // Motivational Quotes
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
            // Medical Cross/Bandage Icon Representation
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF00A355),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.white,
                size: 60,
              ),
            ),
            // Sub-elements to make it look like a bandage (simplified)
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
