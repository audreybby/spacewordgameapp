import 'dart:async';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';

import 'package:spacewordgameapp/provider.dart';

final supabase = Supabase.instance.client;
final activeSession = supabase.auth.currentSession;

class CharacterCustomizationPage extends StatefulWidget {
  const CharacterCustomizationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CharacterCustomizationPageState createState() =>
      _CharacterCustomizationPageState();
}

class _CharacterCustomizationPageState
    extends State<CharacterCustomizationPage> {
  String selectedBody = 'assets/bodies/Alien Biru.png';
  String selectedClothes = 'assets/clothes/KOSTUM PENCURI.png';
  int playerCoins = 0;

  final List<String> bodyAssets = [
    'assets/bodies/Alien Biru.png',
    'assets/bodies/Alien Hijau.png',
    'assets/bodies/Alien Pink.png',
    'assets/bodies/Alien Ungu.png',
    'assets/bodies/Alien Kuning.png',
  ];

  final List<int> bodyPrices = [300, 400, 500, 600, 700];

  final List<String> clothesAssets = [
    'assets/clothes/KOSTUM PENCURI.png',
    'assets/clothes/Kostum Iblis Revisi.png',
    'assets/clothes/Kostum Koki Revisi lagi.png',
    'assets/clothes/Kostum Raja.png',
    'assets/clothes/Kostum Domba.png',
    'assets/clothes/Kostum Rubah.png',
    'assets/clothes/Kostum Sapi.png',
    'assets/clothes/Kostum Santa.png',
    'assets/clothes/Kostum Superhero.png',
  ];

  final List<int> clothesPrices = [
    200,
    300,
    400,
    500,
    600,
    700,
    800,
    900,
    1000
  ];

  List<String> purchasedBodies = [];
  List<String> purchasedClothes = [];

  // ignore: unused_field
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _loadCharacterPreferences();

    if (activeSession == null) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      });
    }
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return; // Pastikan widget masih ada

    setState(() {
      _isLoggedIn = isLoggedIn;
    });

    if (isLoggedIn && ModalRoute.of(context)?.settings.name != '/custom') {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/custom');
        }
      });
    } else if (!isLoggedIn &&
        ModalRoute.of(context)?.settings.name != '/auth') {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      });
    }
  }

  Future<void> _loadCharacterPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedBody = prefs.getString('selectedBody') ?? bodyAssets[0];
      selectedClothes = prefs.getString('selectedClothes') ?? clothesAssets[0];
      purchasedBodies =
          prefs.getStringList('purchasedBodies') ?? [bodyAssets[0]];
      purchasedClothes =
          prefs.getStringList('purchasedClothes') ?? [clothesAssets[0]];
    });
  }

  Future<void> logout() async {
    await supabase.auth.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _saveCharacterPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedBody', selectedBody);
    await prefs.setString('selectedClothes', selectedClothes);
    await prefs.setStringList('purchasedBodies', purchasedBodies);
    await prefs.setStringList('purchasedClothes', purchasedClothes);
    await prefs.setInt('playerCoins', playerCoins);
  }

  void selectItem(String item, String itemType) {
    setState(() {
      if (itemType == 'clothes') {
        selectedClothes = item;
      } else if (itemType == 'body') {
        selectedBody = item;
      }
    });
    _saveCharacterPreferences();

    final characterProvider =
        Provider.of<CharacterProvider>(context, listen: false);
    characterProvider.updateCharacter(selectedBody, selectedClothes);
  }

  void buyItem(int price, String item, String itemType) {
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);

    if (coinProvider.purchaseSkin(price)) {
      setState(() {
        if (itemType == 'clothes') {
          purchasedClothes.add(item);
        } else if (itemType == 'body') {
          purchasedBodies.add(item);
        }

        _saveCharacterPreferences();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins!')),
      );
    }
  }

  void showConfirmationDialog(
      BuildContext context, String itemType, String item, int price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Purchase'),
          content: Text('Do you want to buy this $itemType for $price coins?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                buyItem(price, item, itemType);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  Widget username(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Edit Username',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                debugPrint('Username entered: $value');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Customize'),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFFFFC700),
              size: 30,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Consumer<CoinProvider>(
                builder: (context, coinProvider, child) {
                  return Row(
                    children: [
                      Text(
                        '${coinProvider.coins}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 30,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.monetization_on,
                          color: Color(0xFFFFC700),
                          size: 30,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        body: activeSession == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Column(
                  children: [
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        final prefs = await SharedPreferences.getInstance();
                        final coinProvider =
                            // ignore: use_build_context_synchronously
                            Provider.of<CoinProvider>(context, listen: false);
                        coinProvider.resetCoins();
                        await prefs.clear();
                        // ignore: use_build_context_synchronously
                        Navigator.pushReplacementNamed(context, '/');
                      }, // Logout button
                      child: const Text('Sign out'),
                    ),

                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              selectedBody,
                              height: 220,
                            ),
                            Image.asset(
                              selectedClothes,
                              height: 220,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Clothes
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              'Clothes',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: clothesAssets.length,
                              itemBuilder: (context, index) {
                                final isPurchased = purchasedClothes
                                    .contains(clothesAssets[index]);
                                return GestureDetector(
                                  onTap: () {
                                    if (isPurchased) {
                                      selectItem(
                                          clothesAssets[index], 'clothes');
                                    } else {
                                      showConfirmationDialog(
                                          context,
                                          'clothes',
                                          clothesAssets[index],
                                          clothesPrices[index]);
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 7, top: 11, right: 7),
                                    decoration: BoxDecoration(
                                      color: isPurchased
                                          ? Colors.grey
                                          : const Color.fromARGB(
                                              255, 239, 223, 253),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 100,
                                            child: Image.asset(
                                              clothesAssets[index],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          if (!isPurchased)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                '${clothesPrices[index]} coins',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Skin
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              'Skin',
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: GridView.builder(
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: bodyAssets.length,
                              itemBuilder: (context, index) {
                                final isPurchased =
                                    purchasedBodies.contains(bodyAssets[index]);
                                return GestureDetector(
                                  onTap: () {
                                    if (isPurchased) {
                                      selectItem(bodyAssets[index], 'body');
                                    } else {
                                      showConfirmationDialog(context, 'body',
                                          bodyAssets[index], bodyPrices[index]);
                                    }
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 7, top: 9, right: 7, bottom: 11),
                                    decoration: BoxDecoration(
                                      color: isPurchased
                                          ? Colors.grey
                                          : const Color(0xFFBB84F3),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 90,
                                            child: Image.asset(
                                              bodyAssets[index],
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          if (!isPurchased)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: Text(
                                                '${bodyPrices[index]} coins',
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
  }
}
