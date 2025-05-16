import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class CoinProvider with ChangeNotifier {
  int _coins = 1000;

  int get coins => _coins;

  CoinProvider() {
    _loadCoins();
  }

  void addCoins(int amount) {
    _coins += amount;
    _saveCoins();
    notifyListeners();
  }

  void subtractCoins(int amount) {
    if (_coins >= amount) {
      _coins -= amount;
      _saveCoins();
      notifyListeners();
    }
  }

  bool purchaseSkin(int price) {
    if (_coins >= price) {
      _coins -= price;
      _saveCoins();
      notifyListeners();
      return true;
    }
    return false;
  }

  void convertScoreToCoins(int score) {
    _coins += score;
    _saveCoins();
    notifyListeners();
  }

  void resetCoins() {
    _coins = 1000;
    _saveCoins();
    notifyListeners();
  }

  void syncWithGlobalScore(int globalScore) {
    _coins = globalScore;
    _saveCoins();
    notifyListeners();
  }

  void _saveCoins() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('coins', _coins);
  }

  void _loadCoins() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedCoins = prefs.getInt('coins');
    if (storedCoins != null) {
      _coins = storedCoins;
      notifyListeners();
    }
  }
}

class CharacterProvider with ChangeNotifier {
  String _selectedBody = 'assets/bodies/Alien Biru.png';

  String get selectedBody => _selectedBody;

  void updateCharacter(String body, String clothes) {
    _selectedBody = body;
    _saveToPreferences();
    notifyListeners();
  }

  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedBody', _selectedBody);
  }

  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedBody =
        prefs.getString('selectedBody') ?? 'assets/bodies/Alien Biru.png';
  }
}
