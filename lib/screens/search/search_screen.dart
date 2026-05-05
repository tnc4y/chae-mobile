import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/genre.dart';
import '../../models/webtoon.dart';
import '../../services/webtoon_service.dart';
import '../home/widgets/webtoon_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _service = WebtoonService();
  final _ctrl = TextEditingController();
  Timer? _debounce;

  List<Webtoon> _results = [];
  List<Webtoon> _all = [];
  bool _loading = false;
  bool _searched = false;
  String? _selectedGenreSlug;

  final _genres = const [
    Genre(id: '1', name: 'Aksiyon', color: '#FF6B6B', slug: 'action'),
    Genre(id: '2', name: 'Romantik', color: '#FF8FA3', slug: 'romance'),
    Genre(id: '3', name: 'Fantezi', color: '#9B72CF', slug: 'fantasy'),
    Genre(id: '4', name: 'Korku', color: '#4A4A6A', slug: 'horror'),
    Genre(id: '5', name: 'Komedi', color: '#FFD700', slug: 'comedy'),
    Genre(id: '6', name: 'Drama', color: '#22D3EE', slug: 'drama'),
    Genre(id: '7', name: 'Macera', color: '#4ADE80', slug: 'adventure'),
    Genre(id: '8', name: 'Dövüş', color: '#FB923C', slug: 'martial-arts'),
  ];

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _loading = true);
    try {
      final data = await _service.fetchList();
      if (mounted) {
        setState(() {
          _all = data;
          _results = data;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _search(query));
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = _all;
        _searched = false;
      });
      return;
    }
    setState(() {
      _loading = true;
      _searched = true;
    });
    try {
      final data = await _service.search(query.trim());
      if (mounted) setState(() => _results = data);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _filterByGenre(String slug) async {
    setState(() {
      _selectedGenreSlug = slug;
      _loading = true;
    });
    try {
      final data = await _service.fetchByGenre(slug);
      if (mounted) setState(() => _results = data);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _clearGenre() {
    setState(() {
      _selectedGenreSlug = null;
      _results = _all;
    });
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Keşfet'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _ctrl,
              onChanged: _onChanged,
              style: const TextStyle(color: AppColors.onBackground),
              decoration: InputDecoration(
                hintText: 'Webtoon ara...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.onSurfaceDim),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.onSurfaceDim),
                        onPressed: () {
                          _ctrl.clear();
                          _search('');
                        },
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildGenreFilter(),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  Widget _buildGenreFilter() => SizedBox(
    height: 48,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _genres.length + 1,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) {
        if (i == 0) {
          final isAll = _selectedGenreSlug == null;
          return FilterChip(
            label: const Text('Tümü'),
            selected: isAll,
            onSelected: (_) => _clearGenre(),
            backgroundColor: AppColors.surfaceContainer,
            selectedColor: AppColors.primary.withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: isAll ? AppColors.primary : AppColors.onSurface,
              fontWeight: isAll ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: isAll ? AppColors.primary : AppColors.outline,
            ),
          );
        }
        final genre = _genres[i - 1];
        final isSelected = _selectedGenreSlug == genre.slug;
        Color genreColor = AppColors.primary;
        if (genre.color != null) {
          try {
            genreColor = Color(int.parse(genre.color!.replaceFirst('#', '0xFF')));
          } catch (_) {}
        }
        return FilterChip(
          label: Text(genre.name),
          selected: isSelected,
          onSelected: (_) => isSelected ? _clearGenre() : _filterByGenre(genre.slug!),
          backgroundColor: AppColors.surfaceContainer,
          selectedColor: genreColor.withValues(alpha: 0.2),
          labelStyle: TextStyle(
            color: isSelected ? genreColor : AppColors.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
          side: BorderSide(
            color: isSelected ? genreColor : AppColors.outline,
          ),
        );
      },
    ),
  );

  Widget _buildResults() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 56, color: AppColors.outline),
            const SizedBox(height: 12),
            Text(
              _searched ? 'Sonuç bulunamadı' : 'Aramak için yazın',
              style: const TextStyle(color: AppColors.onSurfaceDim),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
        childAspectRatio: 0.55,
      ),
      itemCount: _results.length,
      itemBuilder: (_, i) => WebtoonCard(
        webtoon: _results[i],
        onTap: () => context.push('/home/webtoon/${_results[i].slug}'),
      ),
    );
  }
}
