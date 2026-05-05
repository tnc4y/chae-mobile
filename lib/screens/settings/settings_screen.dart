import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/context_colors.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final settings = context.watch<SettingsProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.pop();
      },
      child: Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Ayarlar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: 'Gizlilik', colors: colors),
          const SizedBox(height: 8),
          _SettingCard(
            colors: colors,
            child: SwitchListTile(
              value: settings.incognitoMode,
              onChanged: (v) =>
                  context.read<SettingsProvider>().setIncognitoMode(v),
              activeColor: colors.primary,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.visibility_off_rounded,
                        color: colors.primary, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gizli Mod',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Okuma geçmişi kaydedilmez',
                        style: TextStyle(
                            color: colors.onSurfaceDim, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          const SizedBox(height: 20),
          _SectionTitle(title: 'İçerik', colors: colors),
          const SizedBox(height: 8),
          _SettingCard(
            colors: colors,
            child: SwitchListTile(
              value: settings.matureContent,
              onChanged: (v) => v
                  ? _showMatureConfirmation(context, settings)
                  : context
                      .read<SettingsProvider>()
                      .setMatureContent(false),
              activeColor: AppColors.error,
              title: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.eighteen_up_rating_rounded,
                        color: AppColors.error, size: 20),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '+18 İçerik',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Yetişkin içerikleri göster',
                        style: TextStyle(
                            color: colors.onSurfaceDim, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    ),
    );
  }

  void _showMatureConfirmation(
      BuildContext context, SettingsProvider settings) {
    final colors = context.colors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceContainer,
        title: const Text('+18 İçerik'),
        content: const Text(
          'Bu özelliği etkinleştirmek için 18 yaşından büyük olmanız gerekir. '
          'Yaşınızı doğrulayarak devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              settings.setMatureContent(true, verified: true);
            },
            child: const Text('18 Yaşındayım'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final dynamic colors;

  const _SectionTitle({required this.title, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: context.colors.onSurfaceDim,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  final Widget child;
  final dynamic colors;

  const _SettingCard({required this.child, required this.colors});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: c.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }
}
