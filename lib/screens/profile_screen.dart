// lib/screens/profile_screen.dart
// Halaman untuk menampilkan profil pengguna dan statistik sederhana.

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import '../utils/auth_manager.dart';
import '../services/my_api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = 'Pengguna';
  String? _profilePicBase64;
  int _favoritCount = 0;
  bool _isLoading = true;
  
  final MyApiService _apiService = MyApiService();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final name = await AuthManager.getUsername();
    final pic = await AuthManager.getProfilePicture();
    final favorits = await _apiService.fetchAllFavorit();
    
    if (mounted) {
      setState(() {
        _username = name ?? 'Pengguna';
        _profilePicBase64 = pic;
        _favoritCount = favorits.length;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64String = base64Encode(bytes);
        
        await AuthManager.saveProfilePicture(base64String);
        
        if (mounted) {
          setState(() {
            _profilePicBase64 = base64String;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memilih gambar.')),
        );
      }
    }
  }

  String get _userLevel {
    if (_favoritCount >= 10) return 'Master Kopi';
    if (_favoritCount >= 6) return 'Barista Pemula';
    if (_favoritCount >= 3) return 'Penikmat Kopi';
    return 'Pemula';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              children: [
                // Header Bagian Atas
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.white,
                            backgroundImage: _profilePicBase64 != null 
                              ? MemoryImage(base64Decode(_profilePicBase64!))
                              : null,
                            child: _profilePicBase64 == null 
                              ? const Icon(Icons.person, size: 80, color: Colors.grey)
                              : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              radius: 20,
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _username,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mahasiswa UDB / Coffee Enthusiast',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Card Statistik
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Favorit', _favoritCount.toString(), Icons.favorite, Colors.red),
                          Container(width: 1, height: 50, color: Colors.grey.withValues(alpha: 0.3)),
                          _buildStatItem('Level', _userLevel, Icons.star, Colors.amber),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Info Tambahan
                ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text('Email'),
                  subtitle: Text('${_username.toLowerCase()}@student.udb.ac.id'),
                ),
                const Divider(),
                const ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Bergabung Sejak'),
                  subtitle: Text('Juli 2026'),
                ),
                const Divider(),
              ],
            ),
          ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, size: 30, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}
