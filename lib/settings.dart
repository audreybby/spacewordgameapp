import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spacewordgameapp/audioplayers.dart';
import 'package:spacewordgameapp/services/auth_service.dart';
import 'package:spacewordgameapp/soundefx.dart';

class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal>
    with SingleTickerProviderStateMixin {
  double _musicVolume = 0.5;
  double _soundVolume = 0.5;
  late Future<ui.Image> _imageFuture;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _imageFuture = _loadImage('assets/background/sound.png');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
    _loadVolumes(); // Tambahkan ini
    _animationController.forward();
  }

  Future<void> _loadVolumes() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _musicVolume = prefs.getDouble('music_volume') ?? 0.5;
      _soundVolume = prefs.getDouble('sound_volume') ?? 0.5;
    });
  }

  Future<ui.Image> _loadImage(String path) async {
    final data = await rootBundle.load(path);
    final list = data.buffer.asUint8List();
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(list, (img) => completer.complete(img));
    return completer.future;
  }

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget buildSlider(
    IconData icon,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        Icon(icon, color: Colors.yellow, size: 30),
        const SizedBox(width: 10),
        Expanded(
          child: FutureBuilder<ui.Image>(
            future: _imageFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData) {
                return SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 10,
                    activeTrackColor: const Color(0xFFB19CD9),
                    inactiveTrackColor: Colors.grey,
                    thumbShape: CustomSliderThumbImage(snapshot.data!),
                    overlayColor: const Color(0xFFB19CD9),
                  ),
                  child: Slider(
                    value: value,
                    min: 0.0,
                    max: 1.0,
                    onChanged: onChanged,
                  ),
                );
              } else {
                return Slider(
                  value: value,
                  min: 0.0,
                  max: 1.0,
                  onChanged: onChanged,
                );
              }
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        backgroundColor: Colors.transparent,
        child: PopScope(
          canPop: false,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFBD7BFF), Color(0xFF7F18C8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "PENGATURAN",
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: 'FontdinerSwanky',
                          color: Color(0xFFFFF50B),
                        ),
                      ),
                      const SizedBox(height: 20),
                      buildSlider(
                        Icons.music_note,
                        _musicVolume,
                        (val) {
                          setState(() => _musicVolume = val);
                          AudioService().setVolume(val);
                        },
                      ),
                      buildSlider(
                        Icons.volume_up,
                        _soundVolume,
                        (val) {
                          setState(() => _soundVolume = val);
                          SoundEffects().setVolume(val);
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 120,
                        child: ElevatedButton(
                          onPressed: () async {
                            await SoundEffects().pop();
                            await _authService.signOut();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 200, 50, 39),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "KELUAR",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: 'FontdinerSwanky',
                              color: Color(0xFFFFF50B),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: GestureDetector(
                    onTap: () => _animationController.reverse().then((_) async {
                      await SoundEffects().pop();
                      if (mounted) Navigator.of(context).pop();
                    }),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFDBB3F8),
                          width: 2,
                        ),
                        color: const Color(0xFFC465ED),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.yellow,
                        size: 35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}

// ----------------------------- SLIDER THUMB
class CustomSliderThumbImage extends SliderComponentShape {
  final ui.Image image;
  final double thumbSize;
  CustomSliderThumbImage(this.image, {this.thumbSize = 50});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size(thumbSize, thumbSize);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final Rect imageRect = Rect.fromCenter(
      center: center,
      width: thumbSize,
      height: thumbSize,
    );
    paintImage(
      canvas: canvas,
      rect: imageRect,
      image: image,
      fit: BoxFit.contain,
    );
  }
}
