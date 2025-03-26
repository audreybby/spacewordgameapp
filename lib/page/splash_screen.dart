import 'dart:async';

import 'package:flutter/material.dart';
import 'package:spacewordgameapp/page/welcome_page.dart';
// import 'package:spacewordgameapp/audioplayers.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  // final audioService = AudioService(); // Buat instance AudioService

  @override
  void initState() {
    super.initState();
    // audioService.playBackgroundMusic('audio/backsound.mp3');
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..forward();

    // Future.delayed(Duration.zero, () {
    //   audioService.playBackgroundMusic('audio/backsound.mp3');
    // });

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const StartPage(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0D006F), // Warna pertama
              Color(0xFF9614D0), // Warna kedua
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/image/LOGO GEM DEV REVISI.png', // Ganti dengan nama file gambar Anda
                width: 170,
              ),
              const SizedBox(height: 20),

              // Stack untuk animasi loading dan jet
              Stack(
                clipBehavior:
                    Clip.none, // Memastikan jet bisa keluar dari area stack
                children: [
                  // Bar hitam sebagai background
                  Container(
                    width: 200,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  // Animasi loading kuning (tanpa gradasi)
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        left: 0,
                        child: Container(
                          width: 200 * _animation.value,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.yellow, // Warna solid kuning
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      );
                    },
                  ),
                  // Animasi jet (ukuran 85x85 & posisinya dimajukan menutupi garis kuning)
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        left: (200 * _animation.value) -
                            42, // Majukan sedikit untuk menutupi garis kuning
                        top:
                            -40, // Posisikan sedikit lebih tinggi agar lebih dominan
                        child: Image.asset(
                          'assets/image/jet.png', // Ganti dengan gambar jet Anda
                          width: 85, // Ukuran jet
                          height: 85,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Teks "Loading..." dengan FontdinerSwanky
              const Text(
                "Loading...",
                style: TextStyle(
                  fontFamily: 'FontdinerSwanky', // Font kustom
                  color: Colors.white,
                  fontSize: 20, // Ukuran teks sedikit diperbesar
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
