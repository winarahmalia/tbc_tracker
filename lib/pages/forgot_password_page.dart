import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';
import 'verification_code_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isSending = false;

  void _handleSendCode() async {
    if (_emailController.text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    // Simulasi pengiriman kode
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isSending = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const VerificationCodePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    // Header Bar
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            "Atur Ulang Kata Sandi",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Spacer for balance
                      ],
                    ),
                    const SizedBox(height: 60),
                    // Main Title
                    const Text(
                      "Lupa\nKata Sandi?",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B4332),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Subtitle
                    const Text(
                      "Jangan khawatir, masukkan alamat email Anda untuk menerima kode verifikasi.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Input Email
                    CustomInput(
                      label: "Alamat Email",
                      hintText: "nama@gmail.com",
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                    ),
                    const SizedBox(height: 40),
                    // Submit Button
                    CustomButton(
                      text: "Kirim Kode",
                      icon: Icons.send_outlined,
                      onPressed: _handleSendCode,
                    ),
                    const SizedBox(height: 20),
                    // Footer
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),

          // Loading Overlay (Mengirim Kode Verifikasi)
          if (_isSending) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Ingat kata sandi Anda? ",
          style: TextStyle(color: Colors.grey),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text(
            "Masuk Kembali",
            style: TextStyle(
              color: Color(0xFF00A355),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.1),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFC8E6C9)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Mengirim Kode Verifikasi",
                style: TextStyle(
                  color: Color(0xFF2D6A4F),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (index) {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: index == 0
                          ? const Color(0xFF40916C)
                          : index == 1
                              ? const Color(0xFF74C69D)
                              : const Color(0xFFB7E4C7),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
