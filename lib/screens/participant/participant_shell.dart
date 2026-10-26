import 'package:flutter/material.dart';

import '../../widgets/common_widgets.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'permission_screen.dart';
import 'profile_screen.dart';

class ParticipantShell extends StatefulWidget {
  const ParticipantShell({super.key});

  @override
  State<ParticipantShell> createState() => _ParticipantShellState();
}

class _ParticipantShellState extends State<ParticipantShell> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = const [
      HomeScreen(),
      HistoryScreen(),
      PermissionScreen(),
      ProfileScreen(),
    ];
  }

  void _onNavigationTap(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: BottomNav(
          currentIndex: _currentIndex,
          onTap: _onNavigationTap,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history),
              label: 'Riwayat',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Izin/Sakit',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}