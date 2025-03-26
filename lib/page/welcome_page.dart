import 'package:flutter/material.dart';
import 'package:spacewordgameapp/page/choose_level_page.dart';
import 'package:spacewordgameapp/settings.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StartPage(),
    );
  }
}

class StartPage extends StatelessWidget {
  const StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/BackgroundGalaxy.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Konten
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),

                // Gambar di tengah
                SizedBox(
                  width: 600,
                  height: 300,
                  child: Image.asset(
                    'assets/image/LogoSpaceword.png',
                    fit: BoxFit.contain,
                  ),
                ),

                const SizedBox(height: 40), // Jarak antara gambar dan tombol

                // Tombol Start dengan Shadow
                GradientButton(
                  text: 'START',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const GameLevelsPage(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20), // Jarak antara tombol

                // Tombol Settings dengan Shadow
                GradientButton(
                  text: 'SETTINGS',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsModal(),
                      ),
                    );
                  },
                ),

                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget tombol dengan efek gradient & shadow
class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const GradientButton(
      {super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          const EdgeInsets.symmetric(vertical: 5), // Hindari pemotongan shadow
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.5),
            blurRadius: 10, // Efek blur shadow
            spreadRadius: 2, // Lebar shadow lebih luas
            offset:
                const Offset(0, 5), // Geser shadow ke bawah agar terlihat alami
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero, // Hapus padding default
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor:
              Colors.transparent, // Background dihandle oleh gradient
          shadowColor: Colors.transparent, // Hindari shadow default button
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFAA55FF), Color(0xFF7F18C8)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            width: 160,
            height: 55,
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'FontdinerSwanky',
                color: Color(0xFFFFF50B),
                fontSize: 25,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
