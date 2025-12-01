import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedRecycleBackground extends StatefulWidget {
  final Widget child;
  const AnimatedRecycleBackground({super.key, required this.child});

  @override
  State<AnimatedRecycleBackground> createState() =>
      _AnimatedRecycleBackgroundState();
}

class _AnimatedRecycleBackgroundState extends State<AnimatedRecycleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();

  List<Offset> positions = [];
  List<double> sizes = [];
  List<double> speeds = [];

  @override
  void initState() {
    super.initState();

    // create 12 floating icons
    for (int i = 0; i < 12; i++) {
      positions.add(Offset(_random.nextDouble(), _random.nextDouble()));
      sizes.add(20 + _random.nextDouble() * 25);
      speeds.add(0.0002 + _random.nextDouble() * 0.0005);
    }

    _controller =
        AnimationController(vsync: this, duration: const Duration(days: 1))
          ..addListener(() {
            setState(() {
              for (int i = 0; i < positions.length; i++) {
                double dy = positions[i].dy + speeds[i];
                if (dy > 1) dy = 0;
                positions[i] = Offset(positions[i].dx, dy);
              }
            });
          });

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.recycling,
      Icons.delete_outline,
      Icons.eco_outlined,
      Icons.shopping_bag_outlined,
      Icons.restore_from_trash_outlined,
    ];

    return Stack(
      children: [
        // floating icons
        ...List.generate(positions.length, (i) {
          return Positioned(
            left: positions[i].dx * MediaQuery.of(context).size.width,
            top: positions[i].dy * MediaQuery.of(context).size.height,
            child: Icon(
              icons[i % icons.length],
              size: sizes[i],
              color: Colors.green.withOpacity(0.15),
            ),
          );
        }),

        // main content
        widget.child,
      ],
    );
  }
}
