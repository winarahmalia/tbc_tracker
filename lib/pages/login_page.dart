import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/custom_input.dart';
import 'forgot_password_page.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller untuk menangkap input
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isPasswordVisible = false;
  String? _emailError;
  String? _passwordError;

  // Fungsi penanganan tombol login
  void _handleLogin() {
    setState(() {
      _emailError = _emailController.text.isEmpty ? "*Email harus diisi" : null;
      _passwordError = _passwordController.text.length < 6 
          ? "*Password minimal 6 karakter" 
          : null;
    });

    if (_emailError == null && _passwordError == null) {
      print("Login berhasil: ${_emailController.text}");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan Container untuk background gradient seluruh layar
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
        // LayoutBuilder & ConstrainedBox membuat konten bisa berada di tengah vertikal
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    // Membuat seluruh elemen berada di tengah secara vertikal
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20), // Spasi aman atas
                      
                      // 1. Header (Logo & Deskripsi)
                      _buildHeader(),
                      const SizedBox(height: 40),

                      // 2. Input Email
                      CustomInput(
                        label: "Alamat Email",
                        hintText: "nama@gmail.com",
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        errorText: _emailError,
                      ),
                      const SizedBox(height: 20),

                      // 3. Input Password
                      CustomInput(
                        label: "Kata Sandi",
                        hintText: "Masukkan kata sandi",
                        prefixIcon: Icons.lock_outline,
                        controller: _passwordController,
                        isPassword: true,
                        isVisible: _isPasswordVisible,
                        onToggleVisibility: () => 
                            setState(() => _isPasswordVisible = !_isPasswordVisible),
                        errorText: _passwordError,
                      ),
                      
                      // 4. Link Lupa Password
                      _buildForgotPassword(),
                      const SizedBox(height: 30),

                      // 5. Tombol Masuk
                      _buildLoginButton(),
                      const SizedBox(height: 20),

                      // 6. Footer Daftar
                      _buildFooter(),
                      const SizedBox(height: 20), // Spasi aman bawah
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

  // --- Widget Components (Clean Code) ---

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/logo_tbc.png', 
          height: 120, // Sesuaikan ukuran logo yang sudah ada teksnya
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.medical_services, size: 100, color: AppColors.primaryGreen
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          "Yuk lanjutkan perjalanan sehatmu hari ini.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey, 
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ForgotPasswordPage()),
          );
        },
        child: const Text(
          "Lupa Password?",
          style: TextStyle(
            color: AppColors.primaryGreen, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 0,
        ),
        child: const Text(
          "Masuk",
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold, 
            color: Colors.white
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
          onTap: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const RegisterPage())
            );
          },
          child: const Text(
            "Daftar Sekarang",
            style: TextStyle(
              color: AppColors.primaryGreen, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
      ],
    );
  }
}