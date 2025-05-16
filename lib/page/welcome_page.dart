import 'package:flutter/material.dart';
import 'dart:async';
import 'package:spacewordgameapp/page/character_selection.dart';
import 'package:spacewordgameapp/settings.dart';
import 'package:spacewordgameapp/soundefx.dart';
import 'package:spacewordgameapp/audioplayers.dart';

// import 'package:supabase_auth_ui/supabase_auth_ui.dart';
// import 'package:spacewordgameapp/constants/styles.dart';
// import 'package:spacewordgameapp/page/auth_page.dart';
// import 'package:spacewordgameapp/page/character_customization_page.dart';
// import 'package:spacewordgameapp/page/choose_level_page.dart';
// import 'package:spacewordgameapp/ui/custom_button.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with WidgetsBindingObserver {
  final AudioService _audioService = AudioService();
  SoundEffects sound = SoundEffects();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioService.playBackgroundMusic('sound/backsound.mp3');
    _checkLoginStatus();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Logika untuk menghentikan/melanjutkan musik berdasarkan status aplikasi
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      // Hentikan musik saat aplikasi tidak aktif atau dijeda
      _audioService.stopMusic();
    } else if (state == AppLifecycleState.resumed) {
      // Mulai kembali musik saat aplikasi aktif kembali
      _audioService.playBackgroundMusic('sound/backsound.mp3');
    }
  }

  @override
  void dispose() {
    // Hapus observer dan hentikan musik saat halaman dihapus
    WidgetsBinding.instance.removeObserver(this);
    _audioService.dispose();
    super.dispose();
  }

  Future<void> _checkLoginStatus() async {
    // Tambahkan implementasi untuk memeriksa status login
  }

  // void _navigateWithScale(BuildContext context, Widget page) {
  //   Navigator.of(context).push(
  //     PageRouteBuilder(
  //       pageBuilder: (context, animation, secondaryAnimation) => page,
  //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //         final scale = Tween<double>(begin: 0.9, end: 1.0).animate(
  //           CurvedAnimation(parent: animation, curve: Curves.easeInOut),
  //         );
  //         return ScaleTransition(scale: scale, child: child);
  //       },
  //     ),
  //   );
  // }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const SettingsModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const _BackgroundImage(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                Image.asset(
                  'assets/image/LogoSpaceword.png',
                  width: 600,
                  height: 300,
                ),
                const SizedBox(height: 40),
                GradientButton(
                  text: 'MULAI',
                  onPressed: () {
                    sound.clickSound();
                    Navigator.of(context).pushReplacementNamed('/charselect');
                  },
                ),
                const SizedBox(height: 20),
                GradientButton(
                    text: 'PENGATURAN',
                    fontSize: 20,
                    onPressed: () {
                      sound.popSound();
                      _showSettingsDialog(context);
                    }),
                const Spacer(),
              ],
            ),
          ),
        ],
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
