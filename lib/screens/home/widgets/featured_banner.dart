import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/webtoon.dart';

class FeaturedBanner extends StatefulWidget {
  final List<Webtoon> items;
  final void Function(Webtoon) onTap;

  const FeaturedBanner({super.key, required this.items, required this.onTap});

  @override
  State<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends State<FeaturedBanner> {
  final _pageCtrl = PageController(viewportFraction: 0.88);
  int _current = 0;

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: widget.items.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (context, i) {
              final w = widget.items[i];
              return AnimatedScale(
                scale: i == _current ? 1.0 : 0.95,
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: () => widget.onTap(w),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.surfaceContainer,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (w.bannerUrl != null || w.coverUrl != null)
                          CachedNetworkImage(
                            imageUrl: w.bannerUrl ?? w.coverUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                Container(color: AppColors.surfaceContainer),
                          ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.85),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 16,
                          right: 16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  _TypeBadge(type: w.type),
                                  const SizedBox(width: 8),
                                  _StatusBadge(status: w.status),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                w.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  shadows: [
                                    Shadow(blurRadius: 8, color: Colors.black54),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (w.avgRating > 0) ...[
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.gold,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      w.avgRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == _current ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == _current
                    ? AppColors.primary
                    : AppColors.outline,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  const _TypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _color => switch (status) {
    'ongoing' => AppColors.success,
    'completed' => AppColors.tertiary,
    _ => AppColors.warning,
  };

  String get _label => switch (status) {
    'ongoing' => 'Devam Ediyor',
    'completed' => 'Tamamlandı',
    _ => 'Ara Verildi',
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.5)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
