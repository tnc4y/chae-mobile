import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/context_colors.dart';
import '../../models/webtoon.dart';
import '../../providers/settings_provider.dart';
import '../../services/webtoon_service.dart';
import 'widgets/featured_banner.dart';
import 'widgets/section_header.dart';
import 'widgets/webtoon_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _service = WebtoonService();

  List<Webtoon> _featured = [];
  List<Webtoon> _latest = [];
  bool _loadingFeatured = true;
  bool _loadingLatest = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    _loadFeatured();
    _loadLatest();
  }

  Future<void> _loadFeatured() async {
    setState(() => _loadingFeatured = true);
    try {
      final data = await _service.fetchFeatured();
      if (mounted) setState(() => _featured = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loadingFeatured = false);
    }
  }

  Future<void> _loadLatest() async {
    setState(() => _loadingLatest = true);
    try {
      final showMature = context.read<SettingsProvider>().matureContent;
      final data = await _service.fetchList(showMature: showMature);
      if (mounted) setState(() => _latest = data);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loadingLatest = false);
    }
  }

  void _openWebtoon(Webtoon w) => context.push('/home/webtoon/${w.slug}');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      body: RefreshIndicator(
        color: colors.primary,
        backgroundColor: colors.surfaceContainer,
        onRefresh: _loadAll,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(colors),
            if (_error != null)
              SliverToBoxAdapter(child: _buildError(colors)),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildFeaturedSection(colors),
                  const SizedBox(height: 28),
                  SectionHeader(
                    title: 'Son Güncellenenler',
                    actionLabel: 'Tümü',
                    onAction: () => context.go('/search'),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
            _buildLatestGrid(colors),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(c) => SliverAppBar(
        pinned: true,
        backgroundColor: c.background,
        title: ShaderMask(
          shaderCallback: (b) => c.primaryGradient.createShader(b),
          child: const Text(
            'Chae',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: c.onSurface),
            onPressed: () => context.go('/search'),
          ),
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: c.onSurface),
            onPressed: () => context.go('/notifications'),
          ),
          const SizedBox(width: 4),
        ],
      );

  Widget _buildFeaturedSection(c) {
    if (_loadingFeatured) {
      return SizedBox(
        height: 240,
        child: Center(
          child: CircularProgressIndicator(color: c.primary),
        ),
      );
    }
    if (_featured.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Öne Çıkanlar',
            style: TextStyle(
              color: c.onBackground,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 12),
        FeaturedBanner(items: _featured, onTap: _openWebtoon),
      ],
    );
  }

  Widget _buildLatestGrid(c) {
    if (_loadingLatest) {
      return SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: CircularProgressIndicator(color: c.primary),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (ctx, i) => WebtoonCard(
            webtoon: _latest[i],
            onTap: () => _openWebtoon(_latest[i]),
          ),
          childCount: _latest.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 16,
          childAspectRatio: 0.55,
        ),
      ),
    );
  }

  Widget _buildError(c) => Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Yüklenirken hata oluştu. Çekmek için aşağı kaydır.',
                  style: TextStyle(
                      color: AppColors.error.withValues(alpha: 0.8)),
                ),
              ),
            ],
          ),
        ),
      );
}
