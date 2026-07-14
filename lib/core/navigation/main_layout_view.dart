import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayoutView extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayoutView({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.question_mark),
            label: 'Question',
          ),
          NavigationDestination(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.book),
            label: 'Passport',
          ),
          NavigationDestination(
            icon: Icon(Icons.shop),
            label: 'Shop',
          ),
        ],
      ),
    );
  }
}
