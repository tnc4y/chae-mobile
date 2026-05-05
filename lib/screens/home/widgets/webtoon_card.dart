import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/webtoon.dart';

class WebtoonCard extends StatelessWidget {
  final Webtoon webtoon;
  final VoidCallback onTap;

  const WebtoonCard({super.key, required this.webtoon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  webtoon.coverUrl != null
                      ? CachedNetworkImage(
                          imageUrl: webtoon.coverUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => _shimmer(),
                          errorWidget: (_, __, ___) => _placeholder(),
                        )
                      : _placeholder(),
                  if (webtoon.isPremium)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.premium,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                  ),
                  if (webtoon.avgRating > 0)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.gold,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            webtoon.avgRating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            webtoon.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
          if (webtoon.author != null)
            Text(
              webtoon.author!.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.onSurfaceDim,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  Widget _shimmer() => Shimmer.fromColors(
    baseColor: AppColors.surfaceContainer,
    highlightColor: AppColors.surfaceContainerHigh,
    child: Container(color: AppColors.surfaceContainer),
  );

  Widget _placeholder() => Container(
    color: AppColors.surfaceContainer,
    child: const Icon(
      Icons.auto_stories_outlined,
      color: AppColors.outline,
      size: 40,
    ),
  );
}
