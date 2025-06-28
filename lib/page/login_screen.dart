import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:spacewordgameapp/navigation.dart';
import 'package:spacewordgameapp/page/welcome_page.dart';
import 'package:spacewordgameapp/provider.dart';
import 'package:spacewordgameapp/services/user_service.dart';

class GoogleLoginPage extends StatelessWidget {
  const GoogleLoginPage({super.key});

  Future<void> signInWithGoogle(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        Navigator.pop(context);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user != null) {
        Provider.of<UserAuthProvider>(context, listen: false)
            .setUserId(user.uid);

        final UserService userService = UserService();

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await userService.saveUserData(user, user.displayName ?? 'No Name');
        }

        final playerDoc = await FirebaseFirestore.instance
            .collection('players')
            .doc(user.uid)
            .get();

        Navigator.pop(context);

        if (playerDoc.exists) {
          final data = playerDoc.data();
          final hasSelectedBody =
              data?['selectedBody'] != null && data?['selectedBody'] != '';
          final hasUsername =
              data?['username'] != null && data?['username'] != '';

          if (hasSelectedBody && hasUsername) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const WelcomePage()),
            );
          } else {
            Navigator.pushReplacementNamed(context, '/charselect');
          }
        } else {
          Navigator.pushReplacementNamed(context, '/charselect');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login dengan Google berhasil!")),
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal login: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return NoBackPage(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/image/7.png"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Form login
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1A0033),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(40)),
                  ),
                  height: 500,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          "Log In",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 100),
                      // Tombol Login Google
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => signInWithGoogle(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: Colors.grey),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/image/google.jpg',
                                height: 24.0,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Login dengan Google",
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
