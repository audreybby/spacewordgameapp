import 'package:flutter/material.dart';
import 'package:spacewordgameapp/page/choose_level_page.dart';
import 'dart:ui' as ui;

import 'package:spacewordgameapp/soundefx.dart';

class CharacterSelectionPage extends StatefulWidget {
  const CharacterSelectionPage({super.key});

  @override
  State<CharacterSelectionPage> createState() => _CharacterSelectionPageState();
}

class _CharacterSelectionPageState extends State<CharacterSelectionPage> {
  String? selectedCharacterName;
  SoundEffects sound = SoundEffects();

  void selectCharacter(String name) {
    setState(() {
      selectedCharacterName = name;
    });
  }

  void _navigateWithScale(BuildContext context, Widget page) {
    Navigator.of(context).push(_createScaleFullPageRoute(page));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/Bg_Select_Character.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80), // Header padding atas
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 40),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFAA55FF),
                    Color(0xFF7F18C8),
                  ], // sama dengan tombol "LANJUT"
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.5),
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
                      height: 1.5, // Ubah height agar tulisan lebih dekat
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 0), // Jarak setelah "PILIH KARAKTER"
            SizedBox(
              height: screenHeight * 0.4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CharacterOption(
                    imagePath: 'assets/Char/Karakter_Astro.png',
                    name: 'Astro',
                    nameColor: Colors.cyan,
                    isSelected: selectedCharacterName == 'Astro',
                    onSelect: selectCharacter,
                  ),
                  CharacterOption(
                    imagePath: 'assets/Char/Karakter_Vega.png',
                    name: 'Vega',
                    nameColor: const ui.Color.fromARGB(255, 208, 51, 203),
                    isSelected: selectedCharacterName == 'Vega',
                    onSelect: selectCharacter,
                  ),
                  CharacterOption(
                    imagePath: 'assets/Char/Karakter_Nova.png',
                    name: 'Nova',
                    nameColor: const ui.Color.fromARGB(255, 64, 164, 116),
                    isSelected: selectedCharacterName == 'Nova',
                    onSelect: selectCharacter,
                  ),
                ],
              ),
            ),
            const Spacer(),
            GradientButton(
              text: 'LANJUT',
              onPressed: () {
                sound.clickSound();
                _navigateWithScale(context, const GameLevelsPage());
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

//karakter
class CharacterOption extends StatelessWidget {
  final String imagePath;
  final String name;
  final Color nameColor;
  final bool isSelected;
  final Function(String) onSelect;

  const CharacterOption({
    super.key,
    required this.imagePath,
    required this.name,
    required this.nameColor,
    required this.isSelected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelect(name),
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
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 4,
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.7)
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
                Stack(
                  children: [
                    // Outline putih
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'FontdinerSwanky',
                        fontSize: 24,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 4
                          ..color = Colors.white,
                      ),
                    ),
                    // Isi teks berwarna sesuai karakter
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'FontdinerSwanky',
                        fontSize: 24,
                        color: nameColor,
                      ),
                    ),
                  ],
                ),
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
            color: Colors.white.withValues(alpha: 0.5),
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
