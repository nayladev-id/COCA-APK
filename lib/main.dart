// lib/main.dart
// Entry point aplikasi Coffee Catalog

import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/favorit_screen.dart';
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
            scaffoldBackgroundColor: const Color(0xFFF4ECD8), 
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6F4E37),
              brightness: Brightness.light,
            ),
            fontFamily: 'Roboto', 
            cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.zero),
            appBarTheme: const AppBarTheme(
              centerTitle: true, 
              elevation: 0,
              backgroundColor: Color(0xFFF4ECD8),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6F4E37),
              brightness: Brightness.dark,
              surface: const Color(0xFF1E1E1E),
            ),
            fontFamily: 'Roboto',
            cardTheme: const CardThemeData(elevation: 2, margin: EdgeInsets.zero),
            appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          ),
          home: const MainNavigator(), 
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          const HomeScreen(), 
          // Logika Auto-Refresh untuk Favorit
          _selectedIndex == 1 ? const FavoritScreen() : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        backgroundColor: isDarkMode ? const Color(0xFF2A1C14) : const Color(0xFFEBE0C8), 
        indicatorColor: isDarkMode ? const Color(0xFF5D4037) : const Color(0xFFD4C4A8),
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