import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/custom_input.dart';
import '../services/auth_service.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  String? _generalError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Validasi input lokal ─────────────────────────────────────────────────
  bool _validateInputs() {
    final emailRegex = RegExp(r'^[\w.+\-]+@[\w\-]+\.\w+$');
    setState(() {
      _emailError = !emailRegex.hasMatch(_emailController.text.trim())
          ? "*Format email tidak valid"
          : null;
      _passwordError = _passwordController.text.trim().length < 6
          ? "*Password minimal 6 karakter"
          : null;
      _generalError = null;
    });
    return _emailError == null && _passwordError == null;
  }

  // ─── Proses login via Supabase ────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final profile = await AuthService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

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
    } catch (e) {
      // Tampilkan pesan error asli agar mudah diagnosa
      final rawMsg = e.toString().replaceFirst('Exception: ', '');
      setState(() {
        _generalError = rawMsg;
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Ubah pesan error Supabase menjadi pesan yang ramah pengguna.
  String _parseError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Email atau password salah.';
    } else if (error.contains('Email not confirmed')) {
      return 'Email belum diverifikasi.';
    } else if (error.contains('network')) {
      return 'Tidak ada koneksi internet.';
    }
    return 'Terjadi kesalahan, coba lagi.';
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      _buildHeader(),
                      const SizedBox(height: 40),

                      // Input Email
                      CustomInput(
                        label: "Alamat Email",
                        hintText: "nama@gmail.com",
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        errorText: _emailError,
                      ),
                      const SizedBox(height: 20),

                      // Input Password
                      CustomInput(
                        label: "Kata Sandi",
                        hintText: "Masukkan kata sandi",
                        prefixIcon: Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true,
                        isVisible: _isPasswordVisible,
                        onToggleVisibility: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible),
                        errorText: _passwordError,
                      ),

                      // Pesan error umum dari Supabase
                      if (_generalError != null) ...[
                        const SizedBox(height: 10),
                        _buildErrorBanner(_generalError!),
                      ],

                      _buildForgotPassword(),
                      const SizedBox(height: 30),

                      _buildLoginButton(),
                      const SizedBox(height: 20),
                      _buildFooter(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Widget Helpers ───────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/logo_tbc.png',
          height: 120,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.medical_services,
            size: 100,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Yuk lanjutkan perjalanan sehatmu hari ini.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade400, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
        ),
        child: const Text(
          "Lupa Password?",
          style: TextStyle(
              color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Container(
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppColors.buttonGradient,
          color: _isLoading ? Colors.grey.shade300 : null,
          borderRadius: BorderRadius.circular(30),
          boxShadow: _isLoading
              ? []
              : [
                  BoxShadow(
                    color: AppColors.accentGreen.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  "Masuk",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Belum memiliki akun? "),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterPage()),
          ),
          child: const Text(
            "Daftar Sekarang",
            style: TextStyle(
                color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}