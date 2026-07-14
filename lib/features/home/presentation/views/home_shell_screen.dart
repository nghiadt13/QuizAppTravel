import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShellScreen extends StatefulWidget {
  final Widget child;
  const HomeShellScreen({super.key, required this.child});

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/home/quests')) {
      return 0;
    }
    if (location.startsWith('/home/leaderboard')) {
      return 1;
    }
    if (location.startsWith('/home/passport')) {
      return 2;
    }
    if (location.startsWith('/home/shop')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home/quests');
        break;
      case 1:
        context.go('/home/leaderboard');
        break;
      case 2:
        context.go('/home/passport');
        break;
      case 3:
        context.go('/home/shop');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  index: 0,
                  selectedIndex: selectedIndex,
                  activeIcon: Icons.map,
                  inactiveIcon: Icons.map_outlined,
                  label: 'Quests',
                  context: context,
                ),
                _buildNavItem(
                  index: 1,
                  selectedIndex: selectedIndex,
                  activeIcon: Icons.bar_chart,
                  inactiveIcon: Icons.bar_chart_outlined,
                  label: 'Leaderboard',
                  context: context,
                ),
                _buildNavItem(
                  index: 2,
                  selectedIndex: selectedIndex,
                  activeIcon: Icons.style,
                  inactiveIcon: Icons.style_outlined,
                  label: 'Passport',
                  context: context,
                ),
                _buildNavItem(
                  index: 3,
                  selectedIndex: selectedIndex,
                  activeIcon: Icons.card_giftcard,
                  inactiveIcon: Icons.card_giftcard_outlined,
                  label: 'Shop',
                  context: context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required int selectedIndex,
    required IconData activeIcon,
    required IconData inactiveIcon,
    required String label,
    required BuildContext context,
  }) {
    final isSelected = index == selectedIndex;
    
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _onItemTapped(index, context),
        child: Center(
          child: isSelected
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC554), // Warm orange-yellow active container
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        activeIcon,
                        color: const Color(0xFF5D4037), // Dark brown/olive icon
                        size: 22,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        maxLines: 1,
                        textScaler: TextScaler.noScaling,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037), // Dark brown/olive label
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      inactiveIcon,
                      color: const Color(0xFF4A5568), // Slate gray inactive icon
                      size: 22,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      label,
                      maxLines: 1,
                      textScaler: TextScaler.noScaling,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4A5568), // Slate gray inactive label
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
