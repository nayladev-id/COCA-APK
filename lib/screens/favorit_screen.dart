// lib/screens/favorit_screen.dart
// Menampilkan daftar kopi favorit dari API sendiri + dialog edit catatan/rating

import 'package:flutter/material.dart';
import '../models/favorit_model.dart';
import '../services/my_api_service.dart';

class FavoritScreen extends StatefulWidget {
  const FavoritScreen({super.key});

  @override
  State<FavoritScreen> createState() => _FavoritScreenState();
}

class _FavoritScreenState extends State<FavoritScreen> {
  final _myApiService = MyApiService();

  List<FavoritModel> _favoritList = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorit();
  }

  Future<void> _loadFavorit() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final data = await _myApiService.fetchAllFavorit();
      setState(() { _favoritList = data; _isLoading = false; });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat favorit. Coba lagi nanti.';
        _isLoading = false;
      });
    }
  }

  Future<void> _hapusFavorit(FavoritModel item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Favorit?'),
        content: Text('Hapus "${item.nama}" dari daftar favorit?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _myApiService.deleteFavorit(item.id);
      if (success) {
        _loadFavorit();
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('${item.nama} dihapus.')));
        }
      }
    }
  }

  // Dialog untuk edit catatan & rating (memanggil PUT endpoint)
  Future<void> _editFavorit(FavoritModel item) async {
    final catatanController =
        TextEditingController(text: item.catatan ?? '');
    int selectedRating = item.rating ?? 0;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Edit: ${item.nama}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input catatan
              TextField(
                controller: catatanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan',
                  hintText: 'Tulis catatan tentang kopi ini...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // Input rating bintang
              const Text('Rating:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final starValue = i + 1;
                  return IconButton(
                    icon: Icon(
                      starValue <= selectedRating
                          ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
                    ),
                    onPressed: () => setDialogState(
                        () => selectedRating = starValue),
                  );
                }),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final success = await _myApiService.updateFavorit(
                  id: item.id,
                  catatan: catatanController.text.trim().isEmpty
                      ? null : catatanController.text.trim(),
                  rating: selectedRating == 0 ? null : selectedRating,
                );
                if (success) {
                  _loadFavorit();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Berhasil diupdate!')));
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Gagal update. Coba lagi.')));
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingStars(int? rating) {
    if (rating == null || rating == 0) {
      return const Text('Belum ada rating',
          style: TextStyle(color: Colors.grey, fontSize: 12));
    }
    return Row(
      children: List.generate(5, (i) => Icon(
        i < rating ? Icons.star : Icons.star_border,
        color: Colors.amber,
        size: 16,
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('❤️ Favorit Saya'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFavorit,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_errorMessage!, textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadFavorit,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _favoritList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border, size: 80,
                              color: colorScheme.outlineVariant),
                          const SizedBox(height: 16),
                          const Text('Belum ada kopi favorit.',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          const Text('Tambahkan dari halaman Home!',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFavorit,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _favoritList.length,
                        itemBuilder: (context, index) {
                          final item = _favoritList[index];
                          return Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            clipBehavior: Clip.antiAlias,
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Gambar
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      width: 80, height: 80,
                                      child: item.image.isNotEmpty
                                          ? Image.network(item.image,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) =>
                                                  Container(
                                                    color: colorScheme.surfaceContainerHighest,
                                                    child: const Icon(Icons.coffee),
                                                  ))
                                          : Container(
                                              color: colorScheme.surfaceContainerHighest,
                                              child: const Icon(Icons.coffee)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.nama,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15)),
                                        const SizedBox(height: 4),
                                        _buildRatingStars(item.rating),
                                        if (item.catatan != null &&
                                            item.catatan!.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          Text(item.catatan!,
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  color: colorScheme.onSurfaceVariant),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis),
                                        ],
                                      ],
                                    ),
                                  ),
                                  // Tombol aksi
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit_note,
                                            color: Colors.blue),
                                        tooltip: 'Edit catatan & rating',
                                        onPressed: () => _editFavorit(item),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline,
                                            color: Colors.red),
                                        tooltip: 'Hapus dari favorit',
                                        onPressed: () => _hapusFavorit(item),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
