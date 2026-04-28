import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../widgets/custom_input.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // 1. Controller untuk mengambil input user (SRP)
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // 2. State untuk menyembunyikan/menampilkan password
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // 3. State untuk menyimpan pesan error (sesuai UI Figma)
  String? _nameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  // 4. Fungsi Validasi Sederhana (Clean Code: Logika dipisah dari UI)
  void _handleRegister() {
    setState(() {
      // Validasi Nama Lengkap
      _nameError = _nameController.text.isEmpty ? "*Harus Menggunakan Karakter" : null;
      
      // Validasi Email (Cek minimal ada '@')
      _emailError = !_emailController.text.contains('@') ? "*Email Tidak valid" : null;
      
      // Validasi Kata Sandi (Cek minimal 6 karakter)
      _passwordError = _passwordController.text.length < 6 
          ? "*Kata Sandi minimal 6 karakter" 
          : null;
      
      // Validasi Konfirmasi Kata Sandi (Cek kecocokan)
      _confirmPasswordError = _confirmPasswordController.text != _passwordController.text 
          ? "*Kata Sandi Tidak Cocok" 
          : null;
    });

    // Jika tidak ada error sama sekali, lanjutkan proses
    if (_nameError == null && _emailError == null && 
        _passwordError == null && _confirmPasswordError == null) {
      print("Proses Registrasi Berhasil untuk: ${_nameController.text}");
      // TODO: Hubungkan ke Service API NestJS kamu di sini nanti
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Container utama untuk menampung background gradien
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          // Gradien radial lembut seperti di Figma
          gradient: RadialGradient(
            colors: [AppColors.lightGreen, Colors.white],
            center: Alignment(0, -0.6), // Pusat gradien agak ke atas
            radius: 1.2,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 60),
              
              // 1. Header (Logo & Teks Ajakan)
              _buildHeader(),
              const SizedBox(height: 30),

              // 2. Form Input - Menggunakan Widget Reusable CustomInput (Clean Code)
              
              // Input Nama Lengkap
              CustomInput(
                label: "Nama Lengkap",
                hintText: "Masukkan Nama Lengkap",
                prefixIcon: Icons.person_outline,
                controller: _nameController,
                errorText: _nameError,
              ),
              const SizedBox(height: 15),

              // Input Alamat Email
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
                onToggleVisibility: () => 
                    setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                errorText: _confirmPasswordError,
              ),
              const SizedBox(height: 30),

              // 3. Tombol Daftar
              _buildRegisterButton(),
              const SizedBox(height: 20),

              // 4. Footer (Navigasi ke halaman Masuk)
              _buildFooter(),
              const SizedBox(height: 40), // Spasi bawah agar tidak mentok
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget Helper untuk Build Method yang Clean ---

  // Bagian Header: Logo, Nama Aplikasi, Teks Deskripsi
  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/logo_tbc.png', // Pastikan logo sudah didaftarkan di pubspec.yaml
          height: 100,
          errorBuilder: (context, error, stackTrace) => 
            const Icon(Icons.medical_services, size: 80, color: AppColors.primaryGreen),
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

  // Bagian Tombol Daftar berwarna hijau full width
  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          elevation: 0, // Tidak pakai bayangan seperti Figma
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25), // Tombol oval
          ),
        ),
        child: const Text(
          "Daftar",
          style: TextStyle(
            color: Colors.white, 
            fontSize: 16, 
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  // Bagian Footer: "Sudah memiliki akun? Masuk"
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Sudah memiliki akun? ",
          style: TextStyle(fontSize: 14),
        ),
        GestureDetector(
          onTap: () {
            // Kembali ke halaman Login
            Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const LoginPage())
            );
          },
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