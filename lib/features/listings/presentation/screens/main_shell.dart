import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import 'directory_screen.dart';
import 'map_view_screen.dart';
import 'my_listings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _tabs = [
    (icon: Icons.list_alt, label: 'Directory'),
    (icon: Icons.folder_outlined, label: 'My Listings'),
    (icon: Icons.map_outlined, label: 'Map View'),
    (icon: Icons.settings_outlined, label: 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          DirectoryScreen(),
          MyListingsScreen(),
          MapViewScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.primaryDark,
        selectedItemColor: AppTheme.accent,
        unselectedItemColor: Colors.white70,
        items: _tabs
            .map((t) => BottomNavigationBarItem(
                  icon: Icon(t.icon),
                  label: t.label,
                ))
            .toList(),
      ),
    );
  }
}
