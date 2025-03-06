import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      iconSize: 28.0,
      backgroundColor: const Color(0xFFECECEC),
      currentIndex: selectedIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''), // Home
        BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: ''), // Chatbot
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline_rounded, size: 65), // Add Progress
          label: '',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: ''), // Community
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: ''), // Extras Menu
      ],
    );
  }
}
