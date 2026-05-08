import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_button.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _handleResetPassword() {
    if (_passwordController.text.isNotEmpty && 
        _passwordController.text == _confirmPasswordController.text) {
      // Logika reset password berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kata sandi berhasil diperbarui!")),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
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
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 60),
                // Main Title
                const Text(
                  "Buat Kata\nSandi Baru",
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
                  "Kata sandi baru Anda harus berbeda dari yang sebelumnya.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                // Input Passwords
                CustomInput(
                  label: "Kata Sandi Baru",
                  hintText: "••••••••",
                  prefixIcon: Icons.lock_outline,
                  controller: _passwordController,
                  isPassword: true,
                  isVisible: _isPasswordVisible,
                  onToggleVisibility: () => 
                      setState(() => _isPasswordVisible = !_isPasswordVisible),
                ),
                const SizedBox(height: 20),
                CustomInput(
                  label: "Konfirmasi Kata Sandi Baru",
                  hintText: "••••••••",
                  prefixIcon: Icons.lock_outline,
                  controller: _confirmPasswordController,
                  isPassword: true,
                  isVisible: _isConfirmPasswordVisible,
                  onToggleVisibility: () => 
                      setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                ),
                const SizedBox(height: 40),
                // Reset Button
                CustomButton(
                  text: "Atur Ulang Kata Sandi",
                  icon: Icons.send_outlined,
                  onPressed: _handleResetPassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
