// auth.dart (example)
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:recylce_app/services/database.dart';
import 'package:recylce_app/services/shared_pref.dart';
import 'package:recylce_app/pages/bottomnav.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // 1) Google popup
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 2) Firebase credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3) Sign in with Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      final User? user = userCredential.user;
      if (user == null) return;

      // 4) SAVE / UPDATE USER IN FIRESTORE SAFELY (NO POINT RESET)
      await Databasemethods().createOrUpdateUserOnLogin(
        userId: user.uid,
        name: user.displayName ?? "",
        email: user.email ?? "",
        imageUrl: user.photoURL,
      );

      // 5) Save SharedPreferences (id, name, email, image)
      await SharedPreferenceHelper().saveUserId(user.uid);
      await SharedPreferenceHelper().saveUserName(user.displayName ?? "");
      await SharedPreferenceHelper().saveUserEmail(user.email ?? "");
      if (user.photoURL != null) {
        await SharedPreferenceHelper().saveUserImage(user.photoURL!);
      }

      // 6) Go to Bottomnav
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const Bottomnav()),
          (route) => false,
        );
      }
    } catch (e) {
      print("Google Sign-In error: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login failed, please try again")),
        );
      }
    }
  }
}
