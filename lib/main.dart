// lib/main.dart
// Entry point aplikasi Coffee Catalog

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/favorit_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/theme_manager.dart';

void main() {
  runApp(const CoffeeCatalogApp());
}

class CoffeeCatalogApp extends StatelessWidget {
  const CoffeeCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'Coffee Catalog',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6F4E37), // Cokelat terang
              brightness: Brightness.light,
            ),
            fontFamily: 'Roboto',
            cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.zero),
            appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6F4E37),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E), // Warna dasar gelap modern
            ),
            fontFamily: 'Roboto',
            cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.zero),
            appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  // Daftar screen untuk bottom navigation
  static const List<Widget> _screens = [
    HomeScreen(),
    FavoritScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.coffee_outlined),
            selectedIcon: Icon(Icons.coffee),
            label: 'Katalog',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorit',
          ),
        ],
      ),
    );
  }
}
