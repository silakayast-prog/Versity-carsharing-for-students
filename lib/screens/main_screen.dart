import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_bottom_bar.dart';
import 'home_dashboard_screen.dart';
import 'my_rides_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeDashboardScreen(), // Tab 0: Ana Sayfa
    MyRidesScreen(),        // Tab 1: Yolculuklarım
    NotificationsScreen(),  // Tab 2: Bildirimler
    ProfileScreen(),        // Tab 3: Profil
  ];

  final List<FloatingBottomBarItem> _navItems = const [
    FloatingBottomBarItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Ana Sayfa',
    ),
    FloatingBottomBarItem(
      icon: Icons.directions_car_outlined,
      activeIcon: Icons.directions_car_rounded,
      label: 'Seferler',
    ),
    FloatingBottomBarItem(
      icon: Icons.notifications_none_rounded,
      activeIcon: Icons.notifications_rounded,
      label: 'Bildirim',
    ),
    FloatingBottomBarItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.vantaBlack,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomBar(
              currentIndex: _currentIndex,
              items: _navItems,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
            ),
          ),
        ],
      ),
    );
  }
}
