import 'package:flutter/material.dart';
import 'package:spacewordgameapp/navigation.dart';
// import 'dart:ui' as ui;
import 'package:spacewordgameapp/page/choose_level_page.dart';
import 'package:spacewordgameapp/soundefx.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CharacterSelectionPage extends StatefulWidget {
  const CharacterSelectionPage({super.key});

  @override
  State<CharacterSelectionPage> createState() => _CharacterSelectionPageState();
}

class _CharacterSelectionPageState extends State<CharacterSelectionPage> {
  String? selectedCharacterPath;
  SoundEffects sound = SoundEffects();
  final SoundEffects _soundEffects = SoundEffects();
  List<String> purchasedBodies = [];

  void selectCharacter(String path) {
    setState(() {
      selectedCharacterPath = path;
    });
  }

  void _navigateWithScale(BuildContext context, Widget page) {
    Navigator.of(context).push(_createScaleFullPageRoute(page));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return NoBackPage(
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/Bg_Select_Character.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFAA55FF),
                      Color(0xFF7F18C8),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withAlpha((0.5 * 255).round()),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  children: [
                    Text(
                      'PILIH',
                      style: TextStyle(
                        fontFamily: 'FontdinerSwanky',
                        fontSize: 40,
                        color: Color(0xFFFFF50B),
                        height: 2.0,
                      ),
                    ),
                    Text(
                      'KARAKTER',
                      style: TextStyle(
                        fontFamily: 'FontdinerSwanky',
                        fontSize: 40,
                        color: Color(0xFFFFF50B),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 0),
              SizedBox(
                height: screenHeight * 0.4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CharacterOption(
                      imagePath: 'assets/Char/Karakter_Astro.png',
                      isSelected: selectedCharacterPath ==
                          'assets/Char/Karakter_Astro.png',
                      onSelect: selectCharacter,
                    ),
                    CharacterOption(
                      imagePath: 'assets/Char/Karakter_Vega.png',
                      isSelected: selectedCharacterPath ==
                          'assets/Char/Karakter_Vega.png',
                      onSelect: selectCharacter,
                    ),
                    CharacterOption(
                      imagePath: 'assets/Char/Karakter_Nova.png',
                      isSelected: selectedCharacterPath ==
                          'assets/Char/Karakter_Nova.png',
                      onSelect: selectCharacter,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              GradientButton(
                  text: 'LANJUT',
                  onPressed: () async {
                    if (selectedCharacterPath != null) {
                      final uid = FirebaseAuth.instance.currentUser?.uid;

                      if (uid != null) {
                        final playerDoc = FirebaseFirestore.instance
                            .collection('players')
                            .doc(uid);

                        // Tambahkan karakter ke purchasedBodies jika belum ada
                        if (!purchasedBodies.contains(selectedCharacterPath)) {
                          purchasedBodies.add(selectedCharacterPath!);
                        }

                        await playerDoc.set({
                          'uid': uid,
                          'selectedBody': selectedCharacterPath,
                          'purchasedBodies': purchasedBodies,
                          'hasSelectedCharacter': true,
                        }, SetOptions(merge: true));

                        _soundEffects.click();
                        // ignore: use_build_context_synchronously
                        _navigateWithScale(context, const GameLevelsPage());
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Kamu belum login.")),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Pilih karakter terlebih dahulu!")),
                      );
                    }
                  }),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class CharacterOption extends StatelessWidget {
  final String imagePath;
  final bool isSelected;
  final Function(String) onSelect;

  const CharacterOption({
    super.key,
    required this.imagePath,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(imagePath),
        child: AnimatedScale(
          scale: isSelected ? 1.2 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(
                      color: Colors.white.withAlpha((0.8 * 255).round()),
                      width: 4)
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Colors.white.withAlpha((0.7 * 255).round())
                      : Colors.transparent,
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                SizedBox(
                  height: screenHeight * 0.23,
                  child: Image.asset(imagePath, fit: BoxFit.contain),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Route _createScaleFullPageRoute(Widget page) {
  return PageRouteBuilder(
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final scale = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack));
      return ScaleTransition(
        scale: scale,
        alignment: Alignment.center,
        child: child,
      );
    },
  );
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? fontSize;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.white.withAlpha((0.5 * 255).round()),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Colors.transparent,
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
              style: TextStyle(
                fontFamily: 'FontdinerSwanky',
                fontSize: fontSize ?? 25,
                color: const Color(0xFFFFF50B),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
