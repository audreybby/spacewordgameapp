import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserAuthProvider with ChangeNotifier {
  String? _userId;

  String? get userId => _userId;

  void setUserId(String id) {
    _userId = id;
    notifyListeners();
  }
}

class CoinProvider with ChangeNotifier {
  int? _coins; // gunakan nullable int
  final String userId;
  bool _isLoading = true;

  CoinProvider(this.userId) {
    loadCoins();
  }

  int get coins => _coins ?? 0; // sementara bisa kembalikan 0 atau 0 untuk UI

  bool get isLoading => _isLoading;

  void addCoins(int amount) {
    if (_coins != null) {
      _coins = _coins! + amount;
      _saveCoins();
      notifyListeners();
    }
  }

  void subtractCoins(int amount) {
    if (_coins != null && _coins! >= amount) {
      _coins = _coins! - amount;
      _saveCoins();
      notifyListeners();
    }
  }

  bool purchaseSkin(int price) {
    if (_coins != null && _coins! >= price) {
      _coins = _coins! - price;
      _saveCoins();
      notifyListeners();
      return true;
    }
    return false;
  }

  void convertScoreToCoins(int score) {
    if (_coins != null) {
      _coins = _coins! + score;
      _saveCoins();
      notifyListeners();
    }
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

  Future<void> _saveCoins() async {
    await FirebaseFirestore.instance.collection('players').doc(userId).set({
      'coins': _coins,
    }, SetOptions(merge: true));
  }

  Future<void> loadCoins() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('players')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data.containsKey('coins')) {
          _coins = data['coins'];
        } else {
          // jika tidak ada field 'coins', artinya user baru → set 1000
          _coins = 1000;
          await _saveCoins();
        }
      } else {
        // user benar-benar baru, buat data baru
        _coins = 1000;
        await _saveCoins();
      }
    } catch (e) {
      print('Error loading coins from Firestore: $e');
      _coins = 1000; // fallback jika terjadi error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class CharacterProvider with ChangeNotifier {
  // Default character
  String _selectedBody = 'assets/Char/Karakter_Nova.png';
  final String userId;
  bool _isLoaded = false;

  CharacterProvider(this.userId) {
    loadCharacter(); // Load saat provider diinisialisasi
  }

  String get selectedBody => _selectedBody;
  bool get isLoaded => _isLoaded;

  // Update karakter dan simpan ke Firestore
  void updateCharacter(String body, String clothes) {
    _selectedBody = body;
    _saveCharacter();
    notifyListeners();
  }

  // Simpan ke Firestore
  Future<void> _saveCharacter() async {
    try {
      await FirebaseFirestore.instance.collection('players').doc(userId).set({
        'selectedBody': _selectedBody,
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving character to Firestore: $e');
    }
  }

  // Load karakter dari Firestore
  Future<void> loadCharacter() async {
    if (_isLoaded) return; // Jangan load dua kali
    try {
      final doc = await FirebaseFirestore.instance
          .collection('players')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        _selectedBody = data['selectedBody'] ??
            _selectedBody; // fallback ke default jika null
      }
    } catch (e) {
      print('Error loading character from Firestore: $e');
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }
}
