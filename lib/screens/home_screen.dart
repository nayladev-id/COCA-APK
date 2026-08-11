// lib/screens/home_screen.dart
// Menampilkan list kopi dari Sample APIs Coffee + terjemahan dari API sendiri

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import '../models/coffee_model.dart';
import '../models/terjemahan_model.dart';
import '../services/coffee_api_service.dart';
import '../services/my_api_service.dart';
import '../widgets/coffee_card.dart';
import '../utils/theme_manager.dart';
import '../utils/auth_manager.dart';
import 'detail_screen.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';

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
  // Map idApi -> TerjemahanModel untuk lookup O(1)
  Map<int, TerjemahanModel> _terjemahanMap = {};
  // Set idApi yang sudah difavoritkan
  Set<int> _favoritIdApiSet = {};

  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _username = 'Pengguna';
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
        if (name != null) _username = name;
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
      // Fetch paralel untuk efisiensi
      final results = await Future.wait([
        _coffeeService.fetchHotCoffee(),
        _coffeeService.fetchIcedCoffee(),
        _coffeeService.fetchKopiNusantara(),
        _myApiService.fetchAllTerjemahan(),
        _myApiService.fetchAllFavorit(),
      ]);

      final terjemahanList = results[3] as List<TerjemahanModel>;
      final favoritList = results[4] as List;

      setState(() {
        _hotCoffees = results[0] as List<CoffeeModel>;
        _icedCoffees = results[1] as List<CoffeeModel>;
        _lokalCoffees = results[2] as List<CoffeeModel>;
        _terjemahanMap = {for (var t in terjemahanList) t.idApi: t};
        _favoritIdApiSet = {for (var f in favoritList) f.idApi as int};
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
    final isCurrentlyFavorit = _favoritIdApiSet.contains(coffee.id);

    if (isCurrentlyFavorit) {
      // Hapus favorit: cari id row di DB
      final favoritDbId = await _myApiService.getFavoritId(coffee.id);
      if (favoritDbId != null) {
        final success = await _myApiService.deleteFavorit(favoritDbId);
        if (success) {
          setState(() => _favoritIdApiSet.remove(coffee.id));
          _showSnack('${coffee.title} dihapus dari favorit.');
        }
      }
    } else {
      // Tambah favorit
      final success = await _myApiService.addFavorit(
        idApi: coffee.id,
        nama: coffee.title,
        image: coffee.image,
      );
      if (success) {
        setState(() => _favoritIdApiSet.add(coffee.id));
        _showSnack('${coffee.title} ditambahkan ke favorit!');
      }
    }
  }

  Future<void> _openMap() async {
    // Mengarah langsung ke pencarian kedai kopi di sekitar kampus UDB
    final Uri url = Uri.parse('https://www.google.com/maps/search/coffee+shop+near+Universitas+Duta+Bangsa+Surakarta');
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
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'Coffee Catalog',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.coffee_maker, size: 40),
      children: [
        const Text('Aplikasi sederhana untuk menjelajahi berbagai macam jenis kopi dari seluruh dunia.\n\nDibuat untuk memenuhi tugas UAS Pemrograman Mobile Universitas Duta Bangsa Surakarta.'),
      ],
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Urutkan Kopi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.sort),
                title: const Text('Bawaan (Default)'),
                trailing: _sortBy == 'default' ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  setState(() => _sortBy = 'default');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.keyboard_arrow_down),
                title: const Text('Nama (A - Z)'),
                trailing: _sortBy == 'name_asc' ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  setState(() => _sortBy = 'name_asc');
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.keyboard_arrow_up),
                title: const Text('Nama (Z - A)'),
                trailing: _sortBy == 'name_desc' ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  setState(() => _sortBy = 'name_desc');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      }
    );
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildCoffeeList(List<CoffeeModel> coffees, {bool isIced = false}) {
    // 1. Filter berdasarkan pencarian
    var filteredCoffees = coffees.where((c) {
      final titleLower = c.title.toLowerCase();
      final queryLower = _searchQuery.toLowerCase();
      return titleLower.contains(queryLower);
    }).toList();

    // 2. Sorting (Pengurutan)
    if (_sortBy == 'name_asc') {
      filteredCoffees.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortBy == 'name_desc') {
      filteredCoffees.sort((a, b) => b.title.compareTo(a.title));
    }

    if (filteredCoffees.isEmpty) {
      return const Center(child: Text('Tidak ada kopi yang sesuai.'));
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: filteredCoffees.length,
        itemBuilder: (context, index) {
          final coffee = filteredCoffees[index];
          // Iced coffee menggunakan offset +10000 untuk lookup terjemahan (agar tidak bentrok dengan hot)
          final terjemahanKey = isIced ? coffee.id + 10000 : coffee.id;
          final terjemahan = _terjemahanMap[terjemahanKey];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CoffeeCard(
              coffee: coffee,
              deskripsiId: terjemahan?.deskripsiId,
              isFavorit: _favoritIdApiSet.contains(coffee.id),
              isIced: isIced,
              onFavoritToggle: () => _toggleFavorit(coffee),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(
                      coffee: coffee,
                      terjemahan: terjemahan,
                      isFavorit: _favoritIdApiSet.contains(coffee.id),
                      isIced: isIced,
                      onFavoritToggle: () {
                        _toggleFavorit(coffee);
                        // Perbarui state jika kembali dari DetailScreen
                        setState(() {}); 
                      },
                    ),
                  ),
                );
                // Refresh status favorit setelah kembali dari detail
                final updatedFavorit = await _myApiService.fetchAllFavorit();
                setState(() {
                  _favoritIdApiSet = {for (var f in updatedFavorit) f.idApi};
                });
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('☕ Coffee Catalog'),
        centerTitle: true,
        actions: [
          // Tombol Toggle Dark Mode
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
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showSortOptions,
            tooltip: 'Urutkan',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.local_fire_department), text: 'Hot'),
            Tab(icon: Icon(Icons.ac_unit), text: 'Iced'),
            Tab(icon: Icon(Icons.location_on), text: 'Lokal'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              accountEmail: const Text('Mahasiswa UDB / Coffee Enthusiast'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                backgroundImage: _profilePicBase64 != null
                    ? MemoryImage(base64Decode(_profilePicBase64!))
                    : null,
                child: _profilePicBase64 == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                image: const DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1497935586351-b67a49e012bf?auto=format&fit=crop&q=80&w=800'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Beranda'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil Saya'),
              onTap: () async {
                Navigator.pop(context);
                await Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                _loadUser(); // Refresh data user setelah kembali dari profil
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Peta Kedai Kopi'),
              subtitle: const Text('Cari di sekitar kampus'),
              onTap: () {
                Navigator.pop(context);
                _openMap();
              },
            ),
            ListTile(
              leading: const Icon(Icons.brightness_6),
              title: const Text('Ganti Tema'),
              onTap: () {
                ThemeManager.toggleTheme();
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang Aplikasi'),
              onTap: () {
                Navigator.pop(context);
                _showAbout();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logout,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openMap,
        icon: const Icon(Icons.map),
        label: const Text('Kedai Terdekat'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Kotak Pencarian
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: TextField(
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Cari kopi favoritmu...',
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                      ),
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
