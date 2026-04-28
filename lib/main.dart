import 'package:flutter/material.dart';
import 'package:tbc/pages/login_page.dart'; // Import sudah benar

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBC Tracker',
      debugShowCheckedModeBanner: false, // Menghilangkan banner debug di pojok kanan
      theme: ThemeData(
        // Sesuaikan seedColor ke Hijau agar senada dengan UI-mu
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A355)),
        useMaterial3: true,
      ),
      // Arahkan home ke LoginPage
      home: const LoginPage(), 
    );
  }
}