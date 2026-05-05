import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_themes.dart';
import '../../core/theme/context_colors.dart';
import '../../providers/theme_provider.dart';

class ThemesScreen extends StatelessWidget {
  const ThemesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeProvider = context.watch<ThemeProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop();
      },
      child: Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Temalar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'ÜCRETSİZ',
            style: TextStyle(
              color: colors.onSurfaceDim,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _buildThemeGrid(
            context,
            AppThemes.all.where((t) => !t.isPremium).toList(),
            themeProvider,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'PREMIUM',
                style: TextStyle(
                  color: colors.onSurfaceDim,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  gradient: colors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (!themeProvider.premiumUnlocked)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: colors.primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium_rounded,
                      color: colors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Premium temalar için abonelik gerekiyor.',
                      style: TextStyle(
                          color: colors.onSurface, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          _buildThemeGrid(
            context,
            AppThemes.all.where((t) => t.isPremium).toList(),
            themeProvider,
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildThemeGrid(
    BuildContext context,
    List<AppThemePreset> themes,
    ThemeProvider themeProvider,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.3,
      ),
      itemCount: themes.length,
      itemBuilder: (_, i) => _ThemeCard(
        preset: themes[i],
        isSelected: themeProvider.current.id == themes[i].id,
        isLocked: themes[i].isPremium && !themeProvider.premiumUnlocked,
        onTap: () => _selectTheme(context, themes[i], themeProvider),
      ),
    );
  }

  Future<void> _selectTheme(
    BuildContext context,
    AppThemePreset preset,
    ThemeProvider themeProvider,
  ) async {
    final success = await themeProvider.setTheme(preset);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu tema için Premium üyelik gerekiyor.'),
        ),
      );
    }
  }
}

class _ThemeCard extends StatelessWidget {
  final AppThemePreset preset;
  final bool isSelected;
  final bool isLocked;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.preset,
    required this.isSelected,
    required this.isLocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = preset.palette;
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: p.surfaceContainer,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? p.primary : colors.outlineVariant,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: p.primary.withValues(alpha: 0.35),
                    blurRadius: 12,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Color preview dots
                _dot(p.primary),
                const SizedBox(width: 4),
                _dot(p.secondary),
                const SizedBox(width: 4),
                _dot(p.tertiary),
                const Spacer(),
                if (isLocked)
                  Icon(Icons.lock_rounded,
                      size: 14, color: colors.onSurfaceDim)
                else if (isSelected)
                  Icon(Icons.check_circle_rounded,
                      size: 16, color: p.primary),
              ],
            ),
            const Spacer(),
            Text(
              preset.name,
              style: TextStyle(
                color: p.onBackground,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            // Mini UI preview bar
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      gradient: p.primaryGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
