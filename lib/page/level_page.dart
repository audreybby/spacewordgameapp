import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
// ignore: unused_import
import 'package:shared_preferences/shared_preferences.dart';

import 'package:spacewordgameapp/provider.dart';
import 'package:spacewordgameapp/ui/popup_win_lose.dart';
import 'package:flutter/services.dart' show rootBundle;

class EasyLevel extends StatefulWidget {
  const EasyLevel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EasyLevelState createState() => _EasyLevelState();
}

class _EasyLevelState extends State<EasyLevel>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  Timer? timer;
  int timerCount = 40;
  int score = 0;
  int remainingTime = 40;

  List<List<String>> correctAnswers = [];
  List<String> clues = [];
  List<List<String>> crossword = [
    ['', '', '', ''],
    ['', '', '', ''],
    ['', '', '', ''],
    ['', '', '', ''],
    ['', '', '', ''],
  ];

  int activeClueIndex = 0;
  List<bool> isCorrectRow = [false, false, false, false, false];
  List<bool> isRowWrong = [false, false, false, false, false];
  String statusMessage = '';
  Color statusColor = Colors.white;

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    loadQuestions();
    startTime();
    Provider.of<CharacterProvider>(context, listen: false)
        .loadFromPreferences();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> loadQuestions() async {
    final String response =
        await rootBundle.loadString('assets/questions/easy.json');
    final data = json.decode(response);

    setState(() {
      final List<dynamic> questions = data['questions'];

      questions.shuffle(Random());

      clues = List<String>.from(questions.map((q) => q['clue']));
      correctAnswers = List<List<String>>.from(
        questions.map((q) => List<String>.from(q['answer'])),
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void addScore1(int points) {
    setState(() {
      score += points;
    });

    int coinsToAdd = points;
    Provider.of<CoinProvider>(context, listen: false).addCoins(coinsToAdd);

    if (isCorrectRow.every((row) => row)) {
      showFinalPopup(true, score);
      timer?.cancel();
    }
  }

  void showFinalPopup(bool isWin, int score) {
    Future.delayed(const Duration(seconds: 1), () {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PopupWinLose(
            score: score,
            type: isWin ? PopupType.win : PopupType.lose,
          );
        },
      );
    });
  }

  void startTime() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
        if (!allRowsCorrect()) {
          showFinalPopup(false, score);
        }
      }
    });
  }

  bool allRowsCorrect() {
    return isCorrectRow.every((correct) => correct);
  }

  void updateRow(int rowIndex, String newRowValue) {
    setState(() {
      if (newRowValue.length != correctAnswers[rowIndex].length) {
        isRowWrong[rowIndex] = true;
        for (int i = 0; i < crossword[rowIndex].length; i++) {
          crossword[rowIndex][i] = '';
        }
        return;
      }

      List<String> newRow = newRowValue.split('');
      bool isCorrect = true;

      for (int i = 0; i < newRow.length; i++) {
        if (newRow[i].toUpperCase() != correctAnswers[rowIndex][i]) {
          isCorrect = false;
          break;
        }
      }

      if (isCorrect) {
        crossword[rowIndex] = List.from(correctAnswers[rowIndex]);
        isCorrectRow[rowIndex] = true;
        isRowWrong[rowIndex] = false;
        statusMessage = 'BENAR!';
        statusColor = Colors.green;
        _animationController.forward(from: 0.0);

        remainingTime += 3;
        addScore1(5);
      } else {
        isRowWrong[rowIndex] = true;
        crossword[rowIndex].fillRange(0, crossword[rowIndex].length, '');
        statusMessage = 'SALAH!';
        statusColor = const Color.fromARGB(255, 207, 17, 4);
        _animationController.forward(from: 0.0);
      }

      if (isCorrectRow.every((row) => row)) {
        showFinalPopup(true, score);
      }
    });
  }

  void showAnswerInputDialog(BuildContext context, int rowIndex) {
    if (isCorrectRow[rowIndex]) {
      return;
    }

    final TextEditingController controller =
        TextEditingController(text: crossword[rowIndex].join());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(clues[rowIndex],
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                focusNode: _focusNode,
                controller: controller,
                onSubmitted: (newValue) {
                  if (newValue.trim().isNotEmpty) {
                    updateRow(rowIndex, newValue);
                  }
                  Navigator.pop(context);
                },
                maxLength: crossword[rowIndex].length,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String newValue = controller.text.trim();
                if (newValue.isEmpty) {
                  Navigator.pop(context);
                  return;
                }

                updateRow(rowIndex, newValue);
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    ).then((_) {
      _focusNode.unfocus();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final characterProvider = Provider.of<CharacterProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 255, 255, 255),
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text('Waktu: $remainingTime detik',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text('Score: $score',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255))),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/1.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(children: [
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  Column(
                    children: List.generate(crossword.length, (rowIndex) {
                      return Row(
                        children: List.generate(crossword[rowIndex].length,
                            (colIndex) {
                          Color borderColor =
                              const Color.fromARGB(255, 255, 255, 255);

                          if (isCorrectRow[rowIndex]) {
                            borderColor = Colors.green;
                          } else if (isRowWrong[rowIndex]) {
                            borderColor = Colors.red;
                          }

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showAnswerInputDialog(context, rowIndex);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: borderColor, width: 2.0),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Center(
                                    child: Text(
                                      crossword[rowIndex][colIndex],
                                      style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _opacityAnimation.value,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              statusMessage,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Flexible(
              flex: 1,
              child: Consumer<CharacterProvider>(
                builder: (context, characterProvider, child) {
                  return Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(characterProvider.selectedBody,
                            height: 195),
                        Image.asset(characterProvider.selectedClothes,
                            height: 195),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class MediumLevel extends StatefulWidget {
  const MediumLevel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MediumLevelState createState() => _MediumLevelState();
}

class _MediumLevelState extends State<MediumLevel>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  Timer? timer;
  int timerCount = 30;
  int score = 0;
  int remainingTime = 30;

  List<List<String>> correctAnswers = [];
  List<String> clues = [];
  List<List<String>> crossword = [
    ['', '', '', '', ''],
    ['', '', '', '', ''],
    ['', '', '', '', ''],
    ['', '', '', '', ''],
    ['', '', '', '', ''],
  ];

  int activeClueIndex = 0;
  List<bool> isCorrectRow = [false, false, false, false, false];
  List<bool> isRowWrong = [false, false, false, false, false];
  String statusMessage = '';
  Color statusColor = Colors.white;

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    loadQuestions();
    startTime();
    Provider.of<CharacterProvider>(context, listen: false)
        .loadFromPreferences();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> loadQuestions() async {
    final String response =
        await rootBundle.loadString('assets/questions/medium.json');
    final data = json.decode(response);

    setState(() {
      final List<dynamic> questions = data['questions'];

      questions.shuffle(Random());

      clues = List<String>.from(questions.map((q) => q['clue']));
      correctAnswers = List<List<String>>.from(
        questions.map((q) => List<String>.from(q['answer'])),
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void addScore1(int points) {
    setState(() {
      score += points;
    });

    int coinsToAdd = points;
    Provider.of<CoinProvider>(context, listen: false).addCoins(coinsToAdd);

    if (isCorrectRow.every((row) => row)) {
      showFinalPopup(true, score);
      timer?.cancel();
    }
  }

  void showFinalPopup(bool isWin, int score) {
    Future.delayed(const Duration(seconds: 1), () {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PopupWinLose(
            score: score,
            type: isWin ? PopupType.win : PopupType.lose,
          );
        },
      );
    });
  }

  void startTime() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
        if (!allRowsCorrect()) {
          showFinalPopup(false, score);
        }
      }
    });
  }

  bool allRowsCorrect() {
    return isCorrectRow.every((correct) => correct);
  }

  void updateRow(int rowIndex, String newRowValue) {
    setState(() {
      if (newRowValue.length != correctAnswers[rowIndex].length) {
        isRowWrong[rowIndex] = true;
        for (int i = 0; i < crossword[rowIndex].length; i++) {
          crossword[rowIndex][i] = ''; // kolom akan tetap kosong
        }
        return;
      }

      List<String> newRow = newRowValue.split('');
      bool isCorrect = true;

      for (int i = 0; i < newRow.length; i++) {
        if (newRow[i].toUpperCase() != correctAnswers[rowIndex][i]) {
          isCorrect = false;
          break;
        }
      }

      if (isCorrect) {
        crossword[rowIndex] = List.from(correctAnswers[rowIndex]);
        isCorrectRow[rowIndex] = true;
        isRowWrong[rowIndex] = false;
        statusMessage = 'BENAR!';
        statusColor = Colors.green;
        _animationController.forward(from: 0.0);

        remainingTime += 3;
        addScore1(5);
      } else {
        isRowWrong[rowIndex] = true;
        crossword[rowIndex].fillRange(0, crossword[rowIndex].length, '');
        statusMessage = 'SALAH!';
        statusColor = const Color.fromARGB(255, 207, 17, 4);
        _animationController.forward(from: 0.0);
      }

      if (isCorrectRow.every((row) => row)) {
        showFinalPopup(true, score);
      }
    });
  }

  void showAnswerInputDialog(BuildContext context, int rowIndex) {
    if (isCorrectRow[rowIndex]) {
      return;
    }

    final TextEditingController controller =
        TextEditingController(text: crossword[rowIndex].join());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(clues[rowIndex],
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                focusNode: _focusNode,
                controller: controller,
                onSubmitted: (newValue) {
                  if (newValue.trim().isNotEmpty) {
                    updateRow(rowIndex, newValue);
                  }
                  Navigator.pop(context);
                },
                maxLength: crossword[rowIndex].length,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String newValue = controller.text.trim();
                if (newValue.isEmpty) {
                  Navigator.pop(context);
                  return;
                }

                updateRow(rowIndex, newValue);
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    ).then((_) {
      _focusNode.unfocus();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final characterProvider = Provider.of<CharacterProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 255, 255, 255),
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text('Waktu: $remainingTime detik',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text('Score: $score',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255))),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/3.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(children: [
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  Column(
                    children: List.generate(crossword.length, (rowIndex) {
                      return Row(
                        children: List.generate(crossword[rowIndex].length,
                            (colIndex) {
                          Color borderColor =
                              const Color.fromARGB(255, 255, 255, 255);

                          if (isCorrectRow[rowIndex]) {
                            borderColor = Colors.green;
                          } else if (isRowWrong[rowIndex]) {
                            borderColor = Colors.red;
                          }

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showAnswerInputDialog(context, rowIndex);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: borderColor, width: 2.0),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Center(
                                    child: Text(
                                      crossword[rowIndex][colIndex],
                                      style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _opacityAnimation.value,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              statusMessage,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Flexible(
              flex: 1,
              child: Consumer<CharacterProvider>(
                builder: (context, characterProvider, child) {
                  return Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(characterProvider.selectedBody,
                            height: 200),
                        Image.asset(characterProvider.selectedClothes,
                            height: 200),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20)
        ]),
      ),
    );
  }
}

class HardLevel extends StatefulWidget {
  const HardLevel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HardLevelState createState() => _HardLevelState();
}

class _HardLevelState extends State<HardLevel>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  Timer? timer;
  int timerCount = 20;
  int score = 0;
  int remainingTime = 20;

  List<List<String>> correctAnswers = [];
  List<String> clues = [];
  List<List<String>> crossword = [
    ['', '', '', '', '', ''],
    ['', '', '', '', '', ''],
    ['', '', '', '', '', ''],
    ['', '', '', '', '', ''],
    ['', '', '', '', '', ''],
  ];

  int activeClueIndex = 0;
  List<bool> isCorrectRow = [false, false, false, false, false];
  List<bool> isRowWrong = [false, false, false, false, false];
  String statusMessage = '';
  Color statusColor = Colors.white;

  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    loadQuestions();
    startTime();
    Provider.of<CharacterProvider>(context, listen: false)
        .loadFromPreferences();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> loadQuestions() async {
    final String response =
        await rootBundle.loadString('assets/questions/hard.json');
    final data = json.decode(response);

    setState(() {
      // Mendapatkan daftar soal
      final List<dynamic> questions = data['questions'];

      // Mengacak urutan soal
      questions.shuffle(Random());

      // Memisahkan petunjuk dan jawaban setelah diacak
      clues = List<String>.from(questions.map((q) => q['clue']));
      correctAnswers = List<List<String>>.from(
        questions.map((q) => List<String>.from(q['answer'])),
      );
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _focusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void addScore1(int points) {
    setState(() {
      score += points;
    });

    //menambahkan coin sesuai dengan skor
    int coinsToAdd = points; // Langsung menyamakan jumlah koin dengan skor
    Provider.of<CoinProvider>(context, listen: false).addCoins(coinsToAdd);

    if (isCorrectRow.every((row) => row)) {
      showFinalPopup(true, score);
      timer?.cancel();
    }
  }

  void showFinalPopup(bool isWin, int score) {
    Future.delayed(const Duration(seconds: 1), () {
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PopupWinLose(
            score: score,
            type: isWin ? PopupType.win : PopupType.lose,
          );
        },
      );
    });
  }

  void startTime() {
    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (remainingTime > 0) {
        setState(() {
          remainingTime--;
        });
      } else {
        timer.cancel();
        if (!allRowsCorrect()) {
          showFinalPopup(false, score);
        }
      }
    });
  }

  bool allRowsCorrect() {
    return isCorrectRow.every((correct) => correct);
  }

  void updateRow(int rowIndex, String newRowValue) {
    setState(() {
      if (newRowValue.length != correctAnswers[rowIndex].length) {
        isRowWrong[rowIndex] = true;
        for (int i = 0; i < crossword[rowIndex].length; i++) {
          crossword[rowIndex][i] = ''; // kolom akan tetap kosong
        }
        return;
      }

      List<String> newRow = newRowValue.split('');
      bool isCorrect = true;

      for (int i = 0; i < newRow.length; i++) {
        if (newRow[i].toUpperCase() != correctAnswers[rowIndex][i]) {
          isCorrect = false;
          break;
        }
      }

      if (isCorrect) {
        crossword[rowIndex] = List.from(correctAnswers[rowIndex]);
        isCorrectRow[rowIndex] = true;
        isRowWrong[rowIndex] = false;
        statusMessage = 'BENAR!';
        statusColor = Colors.green;
        _animationController.forward(from: 0.0);

        remainingTime += 3;
        addScore1(5);
      } else {
        isRowWrong[rowIndex] = true;
        crossword[rowIndex].fillRange(0, crossword[rowIndex].length, '');
        statusMessage = 'SALAH!';
        statusColor = const Color.fromARGB(255, 207, 17, 4);
        _animationController.forward(from: 0.0);
      }

      if (isCorrectRow.every((row) => row)) {
        showFinalPopup(true, score);
      }
    });
  }

  void showAnswerInputDialog(BuildContext context, int rowIndex) {
    if (isCorrectRow[rowIndex]) {
      return;
    }

    final TextEditingController controller =
        TextEditingController(text: crossword[rowIndex].join());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(clues[rowIndex],
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                focusNode: _focusNode,
                controller: controller,
                onSubmitted: (newValue) {
                  if (newValue.trim().isNotEmpty) {
                    updateRow(rowIndex, newValue);
                  }
                  Navigator.pop(context);
                },
                maxLength: crossword[rowIndex].length,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                String newValue = controller.text.trim();
                if (newValue.isEmpty) {
                  Navigator.pop(context);
                  return;
                }

                updateRow(rowIndex, newValue);
                Navigator.pop(context);
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    ).then((_) {
      _focusNode.unfocus();
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _focusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final characterProvider = Provider.of<CharacterProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color.fromARGB(255, 255, 255, 255),
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text('Waktu: $remainingTime detik',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text('Score: $score',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255))),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/7.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(children: [
          Flexible(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  Column(
                    children: List.generate(crossword.length, (rowIndex) {
                      return Row(
                        children: List.generate(crossword[rowIndex].length,
                            (colIndex) {
                          Color borderColor =
                              const Color.fromARGB(255, 255, 255, 255);

                          if (isCorrectRow[rowIndex]) {
                            borderColor = Colors.green;
                          } else if (isRowWrong[rowIndex]) {
                            borderColor = Colors.red;
                          }

                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showAnswerInputDialog(context, rowIndex);
                              },
                              child: Container(
                                margin: const EdgeInsets.all(4.0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: borderColor, width: 2.0),
                                ),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: Center(
                                    child: Text(
                                      crossword[rowIndex][colIndex],
                                      style: const TextStyle(
                                          fontSize: 24.0,
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromARGB(
                                              255, 255, 255, 255)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _opacityAnimation.value,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              statusMessage,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Flexible(
              flex: 1,
              child: Consumer<CharacterProvider>(
                builder: (context, characterProvider, child) {
                  return Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset(characterProvider.selectedBody,
                            height: 200),
                        Image.asset(characterProvider.selectedClothes,
                            height: 200),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 20)
        ]),
      ),
    );
  }
}
