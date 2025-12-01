import 'package:flutter/material.dart';
import 'package:recylce_app/pages/home.dart';
import 'package:recylce_app/pages/points.dart';
import 'package:recylce_app/pages/profile.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class Bottomnav extends StatefulWidget {
  const Bottomnav({super.key});

  @override
  State<Bottomnav> createState() => _BottomnavState();
}

class _BottomnavState extends State<Bottomnav> {
  late List<Widget> pages;

  late Home homePage;
  late Points pointsPage;
  late Profile profilePage;

  int currentTabIndex = 0;

  @override
  void initState() {
    // Initialize screens
    homePage = Home();
    pointsPage = Points();
    profilePage = Profile();

    // Add to list
    pages = [homePage, pointsPage, profilePage];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        height: 70,
        backgroundColor: Colors.white, // background behind the bar
        color: Colors.black, // actual nav bar color
        animationDuration: const Duration(milliseconds: 500),

        onTap: (int index) {
          setState(() {
            currentTabIndex = index;
          });
        },

        items: const [
          Icon(Icons.home, color: Colors.white, size: 34.0),
          Icon(Icons.point_of_sale, color: Colors.white, size: 34.0),
          Icon(Icons.person, color: Colors.white, size: 34.0),
        ],
      ),

      body: pages[currentTabIndex],
    );
  }
}
