import 'dart:async';
import 'package:flutter/material.dart';

class _InfoItem {
  final String content;
  final String author;

  const _InfoItem({
    required this.content,
    required this.author,
  });
}

class InfoCarousel extends StatefulWidget {
  const InfoCarousel({super.key});

  @override
  State<InfoCarousel> createState() => _InfoCarouselState();
}

class _InfoCarouselState extends State<InfoCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  // ─── Konten Baru Sesuai Permintaan ─────────────────────────────────────────
  static const List<_InfoItem> _items = [
    _InfoItem(
      content: "Minum obat TBC secara teratur setiap hari dapat meningkatkan peluang sembuh hingga lebih dari 90%. Konsistensi adalah kunci utama pemulihan.",
      author: "World Health Organization (WHO)",
    ),
    _InfoItem(
      content: "Berhenti minum obat sebelum waktunya bisa menyebabkan TBC menjadi kebal obat (resistan), sehingga pengobatan jadi lebih lama dan sulit.",
      author: "Centers for Disease Control and Prevention (CDC)",
    ),
    _InfoItem(
      content: "Dukungan dari keluarga atau teman terbukti membantu pasien TBC lebih disiplin menjalani pengobatan hingga tuntas. Kamu tidak sendirian!",
      author: "Kementerian Kesehatan Republik Indonesia",
    ),
    _InfoItem(
      content: "Gejala TBC bisa mulai membaik dalam beberapa minggu, tapi bakteri belum sepenuhnya hilang. Tetap lanjutkan obat sampai selesai, ya!",
      author: "Stop TB Partnership",
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % _items.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ─── Carousel (Card) ────────────────────────────────────────────────
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) {
              final item = _items[i];
              return _buildCard(item);
            },
          ),
        ),
        const SizedBox(height: 12),
        
        // ─── Dot Indicator di Bawah Box ──────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_items.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == i ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == i
                    ? const Color(0xFF006D37)
                    : const Color(0xFF2ECC71).withOpacity(0.35),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCard(_InfoItem item) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71).withOpacity(0.07), // Hijau tipis 7%
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFF2ECC71).withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header di dalam card (Desain Awal)
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Color(0xFF006D37), size: 24),
              const SizedBox(width: 10),
              const Text(
                "Tahukah Kamu?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF064E3B), // Warna teks utama
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // Isi Konten
          Expanded(
            child: Text(
              item.content,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF064E3B), // Warna teks
                height: 1.6,
              ),
            ),
          ),
          const SizedBox(height: 15),
          
          // Footer Sumber
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF006D37),
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Sumber",
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                    Text(
                      item.author,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006D37),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
