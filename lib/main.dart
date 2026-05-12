import 'package:flutter/material.dart';
import 'package:tbc/pages/splash_page.dart';
import 'services/supabase_service.dart';

void main() async {
  // Pastikan Flutter binding sudah siap sebelum memanggil kode asinkron
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase sekali di awal aplikasi
  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TBC Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00A355)),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}