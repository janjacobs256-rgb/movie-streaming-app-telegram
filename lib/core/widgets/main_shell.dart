import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Color(0xFF2C2F48), width: 1),
          ),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          onDestinationSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          backgroundColor: const Color(0xFF121420),
          indicatorColor: const Color(0xFFE50914).withOpacity(0.2),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: Colors.grey),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFFE50914)),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline_rounded, color: Colors.grey),
              selectedIcon: Icon(Icons.favorite_rounded, color: Color(0xFFE50914)),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded, color: Colors.grey),
              selectedIcon: Icon(Icons.person_rounded, color: Color(0xFFE50914)),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
