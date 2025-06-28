import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spacewordgameapp/navigation.dart';
import 'dart:async';
import 'package:spacewordgameapp/page/character_selection.dart';
import 'package:spacewordgameapp/provider.dart';
import 'package:spacewordgameapp/settings.dart';
import 'package:spacewordgameapp/soundefx.dart';
import 'package:spacewordgameapp/audioplayers.dart';
import 'package:spacewordgameapp/ui/exit.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final AudioService _audioService = AudioService();
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final characterProvider =
          Provider.of<CharacterProvider>(context, listen: false);
      characterProvider.loadCharacter();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    WidgetsBinding.instance.addObserver(this);
    _audioService.playBackgroundMusic('sound/backsound.mp3');
    _checkLoginStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Stop musik waktu menutup app
      _audioService.stopMusic();
    } else if (state == AppLifecycleState.resumed) {
      // Mulai musik lagi ketika app dibuka
      _audioService.playBackgroundMusic('sound/backsound.mp3');
    }
  }

  @override
  void dispose() {
    // Hentikan musik saat halaman dihapus
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {}

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SettingsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NoBackPage(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            const _BackgroundImage(),
            Positioned(
              top: 27,
              right: 10,
              child: GestureDetector(
                onTap: () async {
                  await SoundEffects().pop();
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => const ExitModal(),
                  );
                },
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("assets/image/logout_game.png"),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  AnimatedBuilder(
                    animation: _bounceAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounceAnimation.value),
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/image/LogoSpaceword.png',
                      width: 600,
                      height: 300,
                    ),
                  ),
                  const SizedBox(height: 40),
                  GradientButton(
                    text: 'MULAI',
                    onPressed: () async {
                      await SoundEffects().click();
                      Navigator.of(context).pushReplacementNamed('/level');
                    },
                  ),
                  const SizedBox(height: 20),
                  GradientButton(
                      text: 'PENGATURAN',
                      fontSize: 20,
                      onPressed: () async {
                        await SoundEffects().pop();
                        _showSettingsDialog(context);
                      }),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/BackgroundGalaxy.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
