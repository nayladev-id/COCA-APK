// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/coffee_model.dart';
import '../models/terjemahan_model.dart';
import '../models/cart_model.dart';
import '../services/coffee_api_service.dart';
import '../services/my_api_service.dart';
import '../widgets/coffee_card.dart';
import '../utils/theme_manager.dart';
import '../utils/auth_manager.dart';
import 'detail_screen.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';
import 'cart_screen.dart';
import 'live_order_screen.dart'; // IMPORT LAYAR DAPUR

final ValueNotifier<Set<String>> favoriteNotifier = ValueNotifier<Set<String>>({});

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _coffeeService = CoffeeApiService();
  final _myApiService = MyApiService();

  late TabController _tabController;

  List<CoffeeModel> _hotCoffees = [];
  List<CoffeeModel> _icedCoffees = [];
  List<CoffeeModel> _lokalCoffees = [];
  Map<int, TerjemahanModel> _terjemahanMap = {};

  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  
  bool _isOwner = false;
  String _username = 'Coffee Lover'; 
  String? _profilePicBase64;
  String _sortBy = 'default';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadUser() async {
    final name = await AuthManager.getUsername();
    final pic = await AuthManager.getProfilePicture();
    
    if (mounted) {
      setState(() {
        if (name != null && name.isNotEmpty) {
          _username = name;
          _isOwner = true;
        } else {
          _username = 'Customer';
          _isOwner = false;
        }
        _profilePicBase64 = pic;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final hot = await _coffeeService.fetchHotCoffee();
      final iced = await _coffeeService.fetchIcedCoffee();
      final lokal = await _coffeeService.fetchKopiNusantara();
      final terjemahanList = await _myApiService.fetchAllTerjemahan();

      final prefs = await SharedPreferences.getInstance();
      final savedFavs = prefs.getStringList('local_favorites') ?? [];
      favoriteNotifier.value = savedFavs.toSet();

      setState(() {
        _hotCoffees = hot;
        _icedCoffees = iced;
        _lokalCoffees = lokal;
        _terjemahanMap = {for (var t in terjemahanList) t.idApi: t};
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            'Gagal memuat data kopi. Pastikan koneksi internet Anda aktif.\n\nDetail: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorit(CoffeeModel coffee) async {
    final prefs = await SharedPreferences.getInstance();
    final currentFavorites = Set<String>.from(favoriteNotifier.value);

    if (currentFavorites.contains(coffee.title)) {
      currentFavorites.remove(coffee.title);
      _showSnack('${coffee.title} dihapus dari favorit.');
    } else {
      currentFavorites.add(coffee.title);
      _showSnack('${coffee.title} ditambahkan ke favorit!');
    }

    favoriteNotifier.value = currentFavorites;
    await prefs.setStringList('local_favorites', currentFavorites.toList());
  }

  Future<void> _openMap() async {
    final Uri url = Uri.parse(
        'https://www.google.com/maps/search/coffee+shop+near+Universitas+Duta+Bangsa+Surakarta');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      _showSnack('Gagal membuka peta.');
    }
  }

  Future<void> _logout() async {
    await AuthManager.logout();
    if (!mounted) return;
    
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Urutkan Kopi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.sort),
                  title: const Text('Bawaan (Default)'),
                  trailing: _sortBy == 'default' ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () { setState(() => _sortBy = 'default'); Navigator.pop(context); },
                ),
                ListTile(
                  leading: const Icon(Icons.keyboard_arrow_down),
                  title: const Text('Nama (A - Z)'),
                  trailing: _sortBy == 'name_asc' ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () { setState(() => _sortBy = 'name_asc'); Navigator.pop(context); },
                ),
                ListTile(
                  leading: const Icon(Icons.keyboard_arrow_up),
                  title: const Text('Nama (Z - A)'),
                  trailing: _sortBy == 'name_desc' ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () { setState(() => _sortBy = 'name_desc'); Navigator.pop(context); },
                ),
              ],
            ),
          );
        });
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildCoffeeList(List<CoffeeModel> coffees, {bool isIced = false}) {
    var filteredCoffees = coffees.where((c) {
      final titleLower = c.title.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return titleLower.contains(queryLower);
    }).toList();

    if (_sortBy == 'name_asc') {
      filteredCoffees.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortBy == 'name_desc') {
      filteredCoffees.sort((a, b) => b.title.compareTo(a.title));
    }

    if (filteredCoffees.isEmpty) {
      return const Center(child: Text('Tidak ada kopi yang sesuai.'));
    }

    return ValueListenableBuilder<Set<String>>(
      valueListenable: favoriteNotifier,
      builder: (context, favoriteSet, child) {
        return RefreshIndicator(
          onRefresh: _loadData,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: filteredCoffees.length,
            itemBuilder: (context, index) {
              final coffee = filteredCoffees[index];
              final terjemahanKey = isIced ? coffee.id + 10000 : coffee.id;
              final terjemahan = _terjemahanMap[terjemahanKey];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: CoffeeCard(
                  coffee: coffee,
                  deskripsiId: terjemahan?.deskripsiId,
                  isFavorit: favoriteSet.contains(coffee.title),
                  isIced: isIced,
                  onFavoritToggle: () => _toggleFavorit(coffee),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          coffee: coffee,
                          terjemahan: terjemahan,
                          isFavorit: favoriteSet.contains(coffee.title),
                          isIced: isIced,
                          onFavoritToggle: () {
                            _toggleFavorit(coffee);
                          },
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onDoubleTap: () {
            _showSnack('Membuka Akses Owner...');
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
          },
          child: const Text('☕ Coffee Catalog'),
        ),
        centerTitle: true,
        actions: [
          ValueListenableBuilder<List<CartItem>>(
            valueListenable: cartNotifier,
            builder: (context, cartItems, child) {
              int totalMacamKopi = cartItems.length;
              return IconButton(
                icon: Badge(
                  isLabelVisible: totalMacamKopi > 0, 
                  label: Text(totalMacamKopi.toString()),
                  child: const Icon(Icons.shopping_cart),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                tooltip: 'Buka Keranjang',
              );
            },
          ),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: ThemeManager.themeNotifier,
            builder: (_, ThemeMode currentMode, __) {
              final isDark = currentMode == ThemeMode.dark;
              return IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: ThemeManager.toggleTheme,
                tooltip: isDark ? 'Terang' : 'Gelap',
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_username,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: Text(_isOwner ? 'Administrator Kafe' : 'Selamat Datang di Kafe Kami!'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: _isOwner && _profilePicBase64 != null
                    ? MemoryImage(base64Decode(_profilePicBase64!))
                    : null,
                child: (!_isOwner || _profilePicBase64 == null)
                    ? const Icon(Icons.coffee, size: 40, color: Colors.grey)
                    : null,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                image: DecorationImage(
                  image: const NetworkImage('https://images.unsplash.com/photo-1497935586351-b67a49e012bf'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.54), BlendMode.darken),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Beranda Web'),
              onTap: () => Navigator.pop(context),
            ),
            if (_isOwner)
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Profil Saya'),
                onTap: () async {
                  Navigator.pop(context);
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                  _loadUser();
                },
              ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Lokasi Kafe'),
              subtitle: const Text('Kunjungi kami secara langsung'),
              onTap: () {
                Navigator.pop(context);
                _openMap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Ganti Tema (Estetika)'),
              onTap: () {
                ThemeManager.toggleTheme();
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(_isOwner ? Icons.logout : Icons.admin_panel_settings, 
                            color: _isOwner ? Colors.red : Colors.brown),
              title: Text(_isOwner ? 'Logout' : 'Login Owner', 
                          style: TextStyle(color: _isOwner ? Colors.red : Colors.brown, fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                if (_isOwner) {
                  _logout();
                } else {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AuthScreen()));
                }
              },
            ),
          ],
        ),
      ),
      // PERBAIKAN LOGIKA TOMBOL FLOATING ACTION
      floatingActionButton: _isOwner 
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveOrderScreen()));
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text('Live Orders'),
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
            )
          : FloatingActionButton.extended(
              onPressed: _openMap,
              icon: const Icon(Icons.map),
              label: const Text('Kunjungi Kedai'),
            ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: const NetworkImage('https://images.unsplash.com/photo-1447933601403-0c6688de566e?q=80&w=1000'),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.65), BlendMode.darken),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'Vintage Roastery',
                            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2.0),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Jelajahi koleksi biji kopi terbaik dari seluruh dunia, \ndiseduh dengan kehangatan tempo dulu.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) => setState(() => _searchQuery = value),
                              decoration: InputDecoration(
                                hintText: 'Cari kopi favoritmu...',
                                prefixIcon: const Icon(Icons.search),
                                filled: true,
                                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.filter_list),
                            onPressed: _showSortOptions,
                            style: IconButton.styleFrom(backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                          ),
                        ],
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(icon: Icon(Icons.local_fire_department), text: 'Hot'),
                        Tab(icon: Icon(Icons.ac_unit), text: 'Iced'),
                        Tab(icon: Icon(Icons.location_on), text: 'Lokal'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildCoffeeList(_hotCoffees),
                          _buildCoffeeList(_icedCoffees, isIced: true),
                          _buildCoffeeList(_lokalCoffees),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}