import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spacewordgameapp/page/login_screen.dart';
import 'package:spacewordgameapp/page/welcome_page.dart';

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

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..forward();

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;

      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Sudah login, langsung ke halaman character selection
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const WelcomePage(),
          ),
        );
      } else {
        // Belum login, ke halaman login
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => GoogleLoginPage(),
          ),
        );
      }
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
              Color(0xFF0D006F),
              Color(0xFF9614D0),
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
                'assets/image/LOGO GEM DEV REVISI.png',
                width: 170,
              ),
              const SizedBox(height: 20),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 200,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        left: 0,
                        child: Container(
                          width: 200 * _animation.value,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.yellow,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      );
                    },
                  ),
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        left: (200 * _animation.value) - 42,
                        top: -40,
                        child: Image.asset(
                          'assets/image/jet.png',
                          width: 85,
                          height: 85,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "Loading...",
                style: TextStyle(
                  fontFamily: 'FontdinerSwanky',
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
