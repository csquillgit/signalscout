import 'package:flutter/material.dart';
import 'booster_guide_screen.dart';
import 'dead_zone_logger_screen.dart';
import 'scout_needle_screen.dart';
import 'tower_directory_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F19),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const ScoutNeedleScreen(),
          TowerDirectoryScreen(onNavigateToTab: _onTabTapped),
          const DeadZoneLoggerScreen(),
          const BoosterGuideScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0B0F19),
          border: Border(
            top: BorderSide(color: Color(0xFF1E293B), width: 1.2),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFF0B0F19),
          selectedItemColor: const Color(0xFF38BDF8),
          unselectedItemColor: const Color(0xFF64748B),
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.radar_outlined),
              activeIcon: Icon(Icons.radar),
              label: 'SCOUT',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cell_tower_outlined),
              activeIcon: Icon(Icons.cell_tower),
              label: 'TOWERS',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.signal_cellular_off_outlined),
              activeIcon: Icon(Icons.signal_cellular_off),
              label: 'DEAD-ZONES',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'GUIDE',
            ),
          ],
        ),
      ),
    );
  }
}
