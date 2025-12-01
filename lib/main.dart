import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:recylce_app/Admin/home_admin.dart';
import 'package:recylce_app/pages/bottomnav.dart';
import 'package:recylce_app/pages/onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrashME',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xFFececf8),
        useMaterial3: true,
      ),
      home: const Bottomnav(),
    );
  }
}
