import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Widget Pop-up Settings dengan animasi timbul dan tombol close di luar container
class SettingsModal extends StatefulWidget {
  const SettingsModal({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsModalState createState() => _SettingsModalState();
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

    // Mulai animasi timbul
    _animationController.forward();
  }

  Future<ui.Image> _loadImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List list = data.buffer.asUint8List();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(list, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget buildSlider(
      IconData icon, double value, ValueChanged<double> onChanged) {
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
                    activeTrackColor: Colors.white,
                    inactiveTrackColor: Colors.grey,
                    thumbShape: CustomSliderThumbImage(snapshot.data!),
                    overlayColor: Colors.transparent,
                    showValueIndicator: ShowValueIndicator.never,
                    tickMarkShape:
                        const RoundSliderTickMarkShape(tickMarkRadius: 0),
                  ),
                  child: Slider(
                    value: value,
                    min: 0.0,
                    max: 1.0,
                    label: (value * 100).toInt().toString(),
                    onChanged: onChanged,
                  ),
                );
              } else {
                return const Slider(
                    value: 0.5, min: 0, max: 1, onChanged: null);
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
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Konten popup utama
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFAA55FF), Color(0xFF7F18C8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Judul popup di tengah
                  const Center(
                    child: Text(
                      "PENGATURAN",
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'FontdinerSwanky',
                        color: Color(0xFFFFF50B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Slider musik
                  buildSlider(Icons.music_note, _musicVolume, (value) {
                    setState(() => _musicVolume = value);
                  }),
                  // Slider sound
                  buildSlider(Icons.volume_up, _soundVolume, (value) {
                    setState(() => _soundVolume = value);
                  }),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                      onPressed: () {
                        // Aksi tombol "KELUAR"
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
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
            // Tombol close (X) yang diletakkan di luar popup
            Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.yellow, size: 26),
                onPressed: () {
                  // Reverse animasi sebelum pop-up ditutup
                  _animationController.reverse().then((_) {
                    Navigator.of(context).pop();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Tombol dengan efek gradient & shadow
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
            // ignore: deprecated_member_use
            color: Colors.white.withOpacity(0.5),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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

// Custom thumb shape untuk slider menggunakan gambar
class CustomSliderThumbImage extends SliderComponentShape {
  final ui.Image image;
  // Ukuran thumb yang diinginkan (sesuaikan nilainya jika perlu)
  final double thumbSize;
  CustomSliderThumbImage(this.image, {this.thumbSize = 50.0});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(thumbSize, thumbSize);
  }

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
    // Menggunakan ukuran thumbSize yang telah ditentukan
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
