import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spacewordgameapp/provider.dart';

class GameLevelsPage extends StatelessWidget {
  const GameLevelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset(
            "assets/image/back.png",
            width: 50,
            height: 50,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Consumer<CoinProvider>(
              builder: (context, coinProvider, child) {
                return Row(
                  children: [
                    Text(
                      '${coinProvider.coins}', // Menampilkan jumlah koin
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                      ),
                    ),
                    IconButton(
                      icon: SizedBox(
                        width: 30,
                        height: 30,
                        child: Image.asset(
                          "assets/image/jam_coin.png",
                          fit: BoxFit.contain, // Pastikan gambar tidak pecah
                          semanticLabel: "Ikon koin",
                        ),
                      ),
                      onPressed: () {
                        debugPrint('Icon button pressed');
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E0C5A), Color(0xFF631AC0)],
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gambar judul
              Image.asset(
                'assets/image/space word.png',
                width: 200,
              ),
              const SizedBox(height: 70),

              // Baris tombol level
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildDifficultyButton(
                      context, 'EASY', Colors.green, 100, 140),
                  const SizedBox(width: 20),
                  _buildDifficultyButton(
                      context, 'MEDIUM', Colors.blue, 140, 180),
                  const SizedBox(width: 20),
                  _buildDifficultyButton(
                      context, 'HARD', Colors.purple, 100, 140),
                ],
              ),
              const SizedBox(height: 50),

              // Ikon berbentuk lingkaran di bagian bawah
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircleIcon("assets/image/Group.png"),
                  const SizedBox(width: 30),
                  _buildCircleIcon("assets/image/material-symbols_home.png"),
                  const SizedBox(width: 30),
                  _buildCircleIcon("assets/image/tdesign_setting-filled.png"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membuat tombol level
  Widget _buildDifficultyButton(BuildContext context, String text, Color color,
      double width, double height) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                GameLevelDetail(title: text, backgroundColor: color),
          ),
        );
      },
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey, width: 5),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // Fungsi untuk membuat ikon berbentuk lingkaran
  Widget _buildCircleIcon(String imagePath) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Colors.blue, Colors.lightBlueAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.grey, width: 5),
      ),
      child: Center(
        child: Image.asset(
          imagePath,
          width: 40,
          height: 40,
          color: Colors.yellow,
        ),
      ),
    );
  }
}

// Halaman detail setiap level
class GameLevelDetail extends StatelessWidget {
  final String title;
  final Color backgroundColor;

  const GameLevelDetail({
    super.key,
    required this.title,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: backgroundColor),
      body: Container(
        decoration: BoxDecoration(color: backgroundColor),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
