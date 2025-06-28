import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:spacewordgameapp/navigation.dart';
import 'package:spacewordgameapp/services/auth_service.dart';
import 'package:spacewordgameapp/provider.dart';
import 'package:spacewordgameapp/soundefx.dart';

class CharacterCustomizationPage extends StatefulWidget {
  const CharacterCustomizationPage({super.key});

  @override
  State<CharacterCustomizationPage> createState() =>
      _CharacterCustomizationPageState();
}

enum SelectionType { body, skin, character }

class _CharacterCustomizationPageState
    extends State<CharacterCustomizationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Status kategori yang sedang dipilih
  SelectionType currentSelection = SelectionType.body;

  // Daftar karakter utama yang bisa dipilih
  final List<String> bodyAssets = [
    'assets/Char/Karakter_Nova.png',
    'assets/Char/Karakter_Astro.png',
    'assets/Char/Karakter_Vega.png',
    'assets/Char/bajuAnjing.png',
    'assets/Char/bajuTikus.png',
    'assets/Char/bajuKucing.png',
    'assets/Char/adatBali.png',
    'assets/Char/adatGorontalo.png',
    'assets/Char/adatPapua.png',
  ];

  // Harga untuk karakter utama
  final List<int> bodyPrices = [100, 100, 100, 150, 150, 150, 300, 300, 300];

  // Daftar karakter utama yang sudah dibeli pemain
  List<String> purchasedBodies = [];

  String _username = 'Player';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    Future.microtask(() {
      // ignore: use_build_context_synchronously
      Provider.of<CharacterProvider>(context, listen: false).loadCharacter();
    });
  }

  void _checkLoginStatus() {
    final user = _authService.currentUser;
    if (user != null) {
      _loadPlayerData(user.uid);
      _loadUsername(user.uid); //
    }
  }

  Future<void> _loadUsername(String uid) async {
    final userDoc = await _firestore.collection('users').doc(uid).get();
    if (userDoc.exists) {
      setState(() {
        _username = userDoc.data()?['username'] ?? 'Player';
      });
    }
  }

  Future<void> _loadPlayerData(String uid) async {
    final doc = await _firestore.collection('players').doc(uid).get();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        purchasedBodies =
            List<String>.from(data['purchasedBodies'] ?? [bodyAssets[0]]);
      });

      final characterProvider =
          // ignore: use_build_context_synchronously
          Provider.of<CharacterProvider>(context, listen: false);
      characterProvider.updateCharacter(
        data['selectedBody'] ?? bodyAssets[0],
        data['selectedBody'] ?? bodyAssets[0],
      );

      // ignore: use_build_context_synchronously
      Provider.of<CoinProvider>(context, listen: false)
          .syncWithGlobalScore(data['coins'] ?? 1000);
    } else {
      await _initializePlayerData(uid);
    }
  }

  // Jika data pemain belum ada, buat default baru
  Future<void> _initializePlayerData(String uid) async {
    await _firestore.collection('players').doc(uid).set({
      'selectedBody': bodyAssets[0],
      'purchasedBodies': [bodyAssets[0]],
      'coins': 1000,
      'username': _username,
    });
    setState(() {
      purchasedBodies = [bodyAssets[0]];
    });
  }

  // Simpan perubahan ke Firestore
  Future<void> _saveToFirestore() async {
    final user = _authService.currentUser;
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    final characterProvider =
        Provider.of<CharacterProvider>(context, listen: false);

    if (user != null) {
      await _firestore.collection('players').doc(user.uid).update({
        'selectedBody': characterProvider.selectedBody,
        'purchasedBodies': purchasedBodies,
        'coins': coinProvider.coins,
        'username': _username,
      });

      await _firestore.collection('users').doc(user.uid).update({
        'username': _username,
      });
    }
  }

  Future<void> _selectItem(String item) async {
    final characterProvider =
        Provider.of<CharacterProvider>(context, listen: false);

    setState(() {
      // Jika belum dibeli, tambahkan ke daftar purchasedBodies
      if (!purchasedBodies.contains(item)) {
        purchasedBodies.add(item);
      }

      purchasedBodies.remove(item);
      purchasedBodies.insert(0, item);
    });

    await SoundEffects().pop();
    characterProvider.updateCharacter(item, characterProvider.selectedBody);
    _saveToFirestore();
  }

  void _buyItem(String item, int price) {
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);

    if (coinProvider.purchaseSkin(price)) {
      _selectItem(
          item); // ini akan menambahkan ke purchasedBodies dan menyimpan ke Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item purchased successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins!')),
      );
    }
  }

  // Tampilkan dialog konfirmasi pembelian
  Future<void> _showBuyDialog(
      String item, int price, SelectionType type) async {
    await SoundEffects().pop();
    showDialog(
      // ignore: use_build_context_synchronously
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Text(
            'Beli ini ${type == SelectionType.character ? "character" : "skin"} for $price coins?'),
        actions: [
          TextButton(
            onPressed: () async {
              await SoundEffects().pop();
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await SoundEffects().pop();
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              _buyItem(item, price);
            },
            child: const Text('Beli'),
          ),
        ],
      ),
    );
  }

  // Dialog untuk edit username
  void _showEditUsernameDialog() {
    final TextEditingController controller =
        TextEditingController(text: _username);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Username'),
        content: TextField(
          controller: controller,
          maxLength: 20,
          decoration: const InputDecoration(
            hintText: 'Ketik username baru',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                setState(() {
                  _username = newName;
                });
                _saveToFirestore();
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coinProvider = Provider.of<CoinProvider>(context);
    final characterProvider = Provider.of<CharacterProvider>(context);

    final items =
        currentSelection == SelectionType.character ? bodyAssets : bodyAssets;
    final prices =
        currentSelection == SelectionType.character ? bodyPrices : bodyPrices;

    bool isPurchased(String item) {
      return purchasedBodies.contains(item);
    }

    return NoBackPage(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            // Background utama
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.asset(
                'assets/image/Bg_Custom_Char.png',
                fit: BoxFit.cover,
              ),
            ),
            // Konten scroll
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                shadows: [
                                  Shadow(
                                    blurRadius: 6.0,
                                    color: Colors.black,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _showEditUsernameDialog,
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 22,
                                shadows: [
                                  Shadow(
                                    blurRadius: 6.0,
                                    color: Colors.black,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        Image.asset(
                          characterProvider.selectedBody,
                          height: 260,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 150,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Karakter',
                              style: TextStyle(
                                fontSize: 23,
                                color: currentSelection == SelectionType.skin
                                    ? Colors.yellow
                                    : Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 270,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final price = prices[index];
                        final purchased = isPurchased(item);
                        final isSelected =
                            characterProvider.selectedBody == item;

                        return _SelectableItem(
                          imagePath: item,
                          price: price,
                          isPurchased: purchased,
                          isSelected: isSelected,
                          isCharacter:
                              currentSelection == SelectionType.character,
                          onTap: () {
                            if (purchased) {
                              _selectItem(item);
                            } else {
                              _showBuyDialog(item, price, currentSelection);
                            }
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            Positioned(
              top: 12,
              left: 16,
              child: GestureDetector(
                // onTap: () => Navigator.pop(context),
                onTap: () async {
                  await SoundEffects().pop();
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                },
                child: Image.asset(
                  'assets/image/back.png',
                  height: 63,
                  width: 63,
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 16,
              child: Row(
                children: [
                  Stack(
                    children: [
                      Text(
                        coinProvider.coins.toString(),
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 6.0,
                              color: Colors.deepOrangeAccent,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Image.asset(
                    'assets/image/coins.png',
                    height: 44,
                    width: 44,
                  ),
                ],
              ),
            )
          ],
        ),
        backgroundColor: Colors.transparent,
      ),
    );
  }
}

// Widget item karakter
class _SelectableItem extends StatefulWidget {
  final String imagePath;
  final int price;
  final bool isPurchased;
  final bool isSelected;
  final bool isCharacter;
  final VoidCallback onTap;

  const _SelectableItem({
    required this.imagePath,
    required this.price,
    required this.isPurchased,
    required this.isSelected,
    required this.isCharacter,
    required this.onTap,
  });

  @override
  State<_SelectableItem> createState() => _SelectableItemState();
}

class _SelectableItemState extends State<_SelectableItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double boxWidth = 130;
    final double boxHeight = 220;
    final double imageHeightLarge = 210;

    final bool isSelected = widget.isSelected && widget.isPurchased;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: Container(
        width: boxWidth,
        height: boxHeight,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: isSelected
              ? Border.all(color: Colors.deepPurple, width: 4)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.25 * 255).round()),
              offset: const Offset(3, 4),
              blurRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              bottom: 13,
              child: widget.isPurchased
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((0.45 * 255).round()),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text(
                        "Dimiliki",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/image/coins.png',
                          width: 45,
                          height: 45,
                        ),
                        const SizedBox(width: 0),
                        Text(
                          widget.price.toString(),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w700,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
            ),
            Positioned(
              top: 10,
              child: SizedBox(
                height: imageHeightLarge,
                child: Image.asset(
                  widget.imagePath,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            if (_isPressed)
              Positioned.fill(
                child: Container(
                  color: Colors.deepPurple.withAlpha((0.1 * 255).round()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
