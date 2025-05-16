import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:spacewordgameapp/services/auth_service.dart';
import 'package:spacewordgameapp/provider.dart';

class CharacterCustomizationPage extends StatefulWidget {
  const CharacterCustomizationPage({super.key});

  @override
  State<CharacterCustomizationPage> createState() =>
      _CharacterCustomizationPageState();
}

class _CharacterCustomizationPageState
    extends State<CharacterCustomizationPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  final List<String> bodyAssets = [
    'assets/bodies/Alien Biru.png',
    'assets/bodies/Alien Hijau.png',
    'assets/bodies/Alien Pink.png',
    'assets/bodies/Alien Ungu.png',
    'assets/bodies/Alien Kuning.png',
  ];

  final List<int> bodyPrices = [0, 300, 400, 500, 600];

  List<String> purchasedBodies = [];

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    Future.microtask(() {
      Provider.of<CharacterProvider>(context, listen: false)
          .loadFromPreferences();
    });
  }

  void _checkLoginStatus() {
    final user = _authService.currentUser;
    if (user != null) {
      _loadPlayerData(user.uid);
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

      // Sync coin with CoinProvider
      Provider.of<CoinProvider>(context, listen: false)
          .syncWithGlobalScore(data['coins'] ?? 1000);
    } else {
      await _initializePlayerData(uid);
    }
  }

  Future<void> _initializePlayerData(String uid) async {
    await _firestore.collection('players').doc(uid).set({
      'selectedBody': bodyAssets[0],
      'purchasedBodies': [bodyAssets[0]],
      'coins': 1000,
    });
    setState(() {
      purchasedBodies = [bodyAssets[0]];
    });
  }

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
      });
    }
  }

  void _selectBody(String body) {
    final characterProvider =
        Provider.of<CharacterProvider>(context, listen: false);
    characterProvider.updateCharacter(body, characterProvider.selectedBody);
    _saveToFirestore();
  }

  void _buyBody(String body, int price) {
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);

    if (coinProvider.purchaseSkin(price)) {
      setState(() {
        purchasedBodies.add(body);
      });
      _selectBody(body);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Body purchased successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins!')),
      );
    }
  }

  void _showBuyDialog(String body, int price) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Purchase'),
        content: Text('Buy this body for $price coins?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                _buyBody(body, price);
              },
              child: const Text('Buy')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coinProvider = Provider.of<CoinProvider>(context);
    final characterProvider = Provider.of<CharacterProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customize Character'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Coins: ${coinProvider.coins}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Image.asset(characterProvider.selectedBody, height: 100),
            const SizedBox(height: 10),
            const Text('Your Character'),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Available Bodies:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(bodyAssets.length, (index) {
                    final body = bodyAssets[index];
                    final price = bodyPrices[index];
                    final isPurchased = purchasedBodies.contains(body);
                    final isSelected = characterProvider.selectedBody == body;

                    return GestureDetector(
                      onTap: () {
                        if (isPurchased) {
                          _selectBody(body);
                        } else {
                          _showBuyDialog(body, price);
                        }
                      },
                      child: Container(
                        width: 100,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border.all(color: Colors.green, width: 3)
                              : Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.2),
                                blurRadius: 5)
                          ],
                        ),
                        child: Column(
                          children: [
                            Image.asset(body, height: 60),
                            const SizedBox(height: 4),
                            Text(
                              isPurchased ? 'Owned' : '$price Coins',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: isPurchased
                                      ? Colors.green
                                      : Colors.orange),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
