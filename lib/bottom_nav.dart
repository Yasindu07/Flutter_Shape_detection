import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:shape_detection/pages/currancy_obj.dart';
import 'package:shape_detection/pages/math_obj.dart';
import 'package:shape_detection/pages/science_obj.dart';
import 'package:shape_detection/pages/display_shape.dart';
import 'package:shape_detection/widgets/voice.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _currentIndex = 0;

  final _items = [
    SalomonBottomBarItem(
        icon: const Icon(Icons.home), title: const Text("Maths")),
    SalomonBottomBarItem(
        icon: const Icon(Icons.person), title: const Text("Science")),
    SalomonBottomBarItem(
        icon: const Icon(Icons.money_outlined), title: const Text("Currency")),
    SalomonBottomBarItem(
        icon: const Icon(Icons.save), title: const Text("Save")),
  ];

  final _screens = [
    const Center(
      child: MathsObj(),
    ),
    const Center(
      child: ScienceObj(),
    ),
    const Center(
      child: CurrancyObj(),
    ),
    const Center(
      child: DisplayShapes(),
    ),
  ];

  void _updateIndex(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      body: _screens[_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        items: _items,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() {
          _currentIndex = index;
        }),
      ),
      // Pass the update callback to the SpeechButton
      floatingActionButton: SpeechButton(onNavigateCommand: _updateIndex),
    );
  }
}
