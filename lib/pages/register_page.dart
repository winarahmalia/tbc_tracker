import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/custom_input.dart';
import '../services/auth_service.dart';
import 'login_page.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _generalError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ─── Validasi input lokal ─────────────────────────────────────────────────
  bool _validateInputs() {
    final emailRegex = RegExp(r'^[\w.+\-]+@[\w\-]+\.\w+$');
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? "*Nama tidak boleh kosong"
          : null;
      _emailError = !emailRegex.hasMatch(_emailController.text.trim())
          ? "*Format email tidak valid"
          : null;
      _passwordError = _passwordController.text.trim().length < 6
          ? "*Kata sandi minimal 6 karakter"
          : null;
      _confirmPasswordError =
          _confirmPasswordController.text != _passwordController.text
              ? "*Kata sandi tidak cocok"
              : null;
      _generalError = null;
    });
    return _nameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
  }

  // ─── Proses register via Supabase ─────────────────────────────────────────
  Future<void> _handleRegister() async {
    if (!_validateInputs()) return;

    setState(() => _isLoading = true);

    try {
      final profile = await AuthService.signUp(
        name: _nameController.text.trim(),
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

  /// Ubah pesan error Supabase menjadi pesan ramah pengguna.
  String _parseError(String error) {
    if (error.contains('already registered') ||
        error.contains('already been registered')) {
      return 'Email sudah terdaftar. Silakan login.';
    } else if (error.contains('password')) {
      return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 60),
              _buildHeader(),
              const SizedBox(height: 30),

              // Input Nama Lengkap
              CustomInput(
                label: "Nama Lengkap",
                hintText: "Masukkan Nama Lengkap",
                prefixIcon: Icons.person_outline,
                controller: _nameController,
                errorText: _nameError,
              ),
              const SizedBox(height: 15),

              // Input Email
              CustomInput(
                label: "Alamat Email",
                hintText: "name@gmail.com",
                prefixIcon: Icons.email_outlined,
                controller: _emailController,
                errorText: _emailError,
              ),
              const SizedBox(height: 15),

              // Input Kata Sandi
              CustomInput(
                label: "Kata Sandi",
                hintText: "........",
                prefixIcon: Icons.lock_outline,
                controller: _passwordController,
                isPassword: true,
                isVisible: _isPasswordVisible,
                onToggleVisibility: () =>
                    setState(() => _isPasswordVisible = !_isPasswordVisible),
                errorText: _passwordError,
              ),
              const SizedBox(height: 15),

              // Input Konfirmasi Kata Sandi
              CustomInput(
                label: "Konfirmasi Kata Sandi",
                hintText: "........",
                prefixIcon: Icons.lock_outline,
                controller: _confirmPasswordController,
                isPassword: true,
                isVisible: _isConfirmPasswordVisible,
                onToggleVisibility: () => setState(
                    () => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                errorText: _confirmPasswordError,
              ),

              // Error banner dari Supabase
              if (_generalError != null) ...[
                const SizedBox(height: 15),
                _buildErrorBanner(_generalError!),
              ],

              const SizedBox(height: 30),
              _buildRegisterButton(),
              const SizedBox(height: 20),
              _buildFooter(),
              const SizedBox(height: 40),
            ],
          ),
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
          height: 100,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.medical_services,
            size: 80,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Buat akun dan mulai perjalanan\npemulihan TBC-mu bersama kami.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 13),
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

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          gradient: _isLoading ? null : AppColors.buttonGradient,
          color: _isLoading ? Colors.grey.shade300 : null,
          borderRadius: BorderRadius.circular(25),
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
          onPressed: _isLoading ? null : _handleRegister,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25)),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  "Daftar",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Sudah memiliki akun? ", style: TextStyle(fontSize: 14)),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          ),
          child: const Text(
            "Masuk",
            style: TextStyle(
              color: AppColors.primaryGreen,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}