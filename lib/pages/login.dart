import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:recylce_app/services/auth.dart';
import 'package:recylce_app/services/widget_support.dart';

class logIn extends StatefulWidget {
  const logIn({super.key});

  @override
  State<logIn> createState() => _logInState();
}

class _logInState extends State<logIn> {
  // Animation values
  double a = 0, b = 20, c = -20, d = 10;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    // Smooth loop animation every 2 seconds
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        a = Random().nextDouble() * 40 - 20;
        b = Random().nextDouble() * 40 - 20;
        c = Random().nextDouble() * 40 - 20;
        d = Random().nextDouble() * 40 - 20;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ------------------- GREEN BACKGROUND -------------------
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // ------------------- FLOATING ANIMATED ICONS -------------------
          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            top: 80 + a,
            left: 20,
            child: Icon(Icons.recycling, size: 48, color: Colors.white12),
          ),

          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            top: 180 + b,
            right: 30,
            child: Icon(Icons.card_giftcard, size: 55, color: Colors.white12),
          ),

          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            bottom: 200 + c,
            left: 40,
            child: Icon(Icons.delete_outline, size: 60, color: Colors.white10),
          ),

          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            bottom: 120 + d,
            right: 40,
            child: Icon(Icons.stars_rounded, size: 50, color: Colors.white12),
          ),

          AnimatedPositioned(
            duration: const Duration(seconds: 2),
            curve: Curves.easeInOut,
            bottom: 300 + a,
            right: 130,
            child: Icon(Icons.recycling, size: 70, color: Colors.white10),
          ),

          // ------------------- MAIN CONTENT -------------------
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // TOP IMAGE
                Expanded(
                  flex: 4,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: Image.asset(
                        "asset/images/login.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // TITLE
                Text(
                  "Reduce • Reuse • Recycle",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                    fontFamily: "Poppins",
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Join the green movement with TrashME",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontFamily: "Poppins",
                  ),
                ),

                const SizedBox(height: 40),

                // GOOGLE LOGIN BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GestureDetector(
                    onTap: () {
                      AuthMethods().signInWithGoogle(context);
                    },
                    child: Container(
                      height: 58,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Google icon
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              color: Colors.white,
                            ),
                            child: Image.asset(
                              "asset/images/google.png",
                              height: 28,
                            ),
                          ),

                          const SizedBox(width: 16),

                          Text(
                            "Sign in with Google",
                            style: AppWidget.normalTextStyle(18).copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
