import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/chapter.dart';

class ChapterListItem extends StatelessWidget {
  final Chapter chapter;
  final bool isUnlocked;
  final VoidCallback onTap;

  const ChapterListItem({
    super.key,
    required this.chapter,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = chapter.isPremium && !isUnlocked;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isLocked
                    ? AppColors.premium.withValues(alpha: 0.15)
                    : AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isLocked
                    ? const Icon(Icons.lock_rounded, size: 18, color: AppColors.premium)
                    : Text(
                        '${chapter.chapterNumber}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.displayTitle,
                    style: TextStyle(
                      color: isLocked
                          ? AppColors.onSurfaceDim
                          : AppColors.onSurface,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.visibility_outlined, size: 13, color: AppColors.onSurfaceDim),
                      const SizedBox(width: 4),
                      Text(
                        '${chapter.viewCount}',
                        style: const TextStyle(
                          color: AppColors.onSurfaceDim,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.favorite_outline, size: 13, color: AppColors.onSurfaceDim),
                      const SizedBox(width: 4),
                      Text(
                        '${chapter.likeCount}',
                        style: const TextStyle(
                          color: AppColors.onSurfaceDim,
                          fontSize: 11,
                        ),
                      ),
                      if (chapter.publishedAt != null) ...[
                        const SizedBox(width: 10),
                        Text(
                          _formatDate(chapter.publishedAt!),
                          style: const TextStyle(
                            color: AppColors.onSurfaceDim,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (isLocked)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.premium.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.toll_rounded, size: 13, color: AppColors.premium),
                    const SizedBox(width: 4),
                    Text(
                      '${chapter.coinCost}',
                      style: const TextStyle(
                        color: AppColors.premium,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
            else
              const Icon(
                Icons.play_circle_outline_rounded,
                color: AppColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Bugün';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return '${date.day}.${date.month}.${date.year}';
  }
}
