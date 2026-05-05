import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/revenuecat_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _purchaseLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfile();
    });
  }

  Future<void> _openPremiumFlow() async {
    if (_purchaseLoading) return;

    if (!RevenueCatService.instance.isConfigured) {
      _showSnackBar(
        'Premium satın alma hazır değil. RevenueCat API key tanımı eksik.',
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Premium Üyelik',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              const Text(
                'Abonelik satın alabilir veya eski satın alımlarını geri yükleyebilirsin.',
                style: TextStyle(color: AppColors.onSurfaceDim),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _startPurchaseFlow();
                },
                icon: const Icon(Icons.workspace_premium_rounded),
                label: const Text('Abonelik Satın Al'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _restorePurchases();
                },
                icon: const Icon(Icons.restore_rounded),
                label: const Text('Satın Alımları Geri Yükle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startPurchaseFlow() async {
    final profileProvider = context.read<ProfileProvider>();
    setState(() => _purchaseLoading = true);

    try {
      final offerings = await RevenueCatService.instance.getOfferings();
      final packages = offerings.current?.availablePackages ?? [];

      if (packages.isEmpty) {
        _showSnackBar('Şu anda satın alınabilir paket bulunamadı.');
        return;
      }

      final selectedPackage = await _selectPackage(packages);
      if (selectedPackage == null) return;

      final customerInfo = await RevenueCatService.instance.purchasePackage(
        selectedPackage,
      );

      final hasPremium = RevenueCatService.instance.hasPremiumEntitlement(
        customerInfo,
      );

      if (hasPremium) {
        if (!mounted) return;
        await profileProvider.syncPremiumRole(true);
        _showSnackBar('Premium satın alma başarılı.');
      } else {
        _showSnackBar(
          'Satın alma tamamlandı ancak premium entitlement aktif görünmüyor.',
        );
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      _showSnackBar('Satın alma hatası: ${errorCode.name}');
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _purchaseLoading = false);
      }
    }
  }

  Future<void> _restorePurchases() async {
    final profileProvider = context.read<ProfileProvider>();
    setState(() => _purchaseLoading = true);

    try {
      final customerInfo = await RevenueCatService.instance.restorePurchases();
      final hasPremium = RevenueCatService.instance.hasPremiumEntitlement(
        customerInfo,
      );

      if (hasPremium) {
        if (!mounted) return;
        await profileProvider.syncPremiumRole(true);
        _showSnackBar('Satın alımlar geri yüklendi. Premium aktif.');
      } else {
        _showSnackBar('Geri yüklenecek aktif premium bulunamadı.');
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      _showSnackBar('Geri yükleme hatası: ${errorCode.name}');
    } catch (e) {
      _showSnackBar(e.toString());
    } finally {
      if (mounted) {
        setState(() => _purchaseLoading = false);
      }
    }
  }

  Future<Package?> _selectPackage(List<Package> packages) {
    return showModalBottomSheet<Package>(
      context: context,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paket Seç',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...packages.map(
                (package) => Card(
                  color: AppColors.surface,
                  child: ListTile(
                    title: Text(package.storeProduct.title),
                    subtitle: Text(package.storeProduct.description),
                    trailing: Text(
                      package.storeProduct.priceString,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    onTap: () => Navigator.pop(ctx, package),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primary),
    );
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainer,
        title: const Text('Çıkış Yap'),
        content: const Text('Hesabından çıkmak istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().signOut();
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            onPressed: _signOut,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: profileProvider.loading && profile == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: profileProvider.fetchProfile,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (profile != null) ...[
                    _buildAvatar(profile.avatarUrl, profile.displayedName),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        profile.displayedName,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ),
                    Center(
                      child: Text(
                        '@${profile.username}',
                        style: const TextStyle(
                          color: AppColors.onSurfaceDim,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (profile.bio?.isNotEmpty == true) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          profile.bio!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildRoleBadge(profile.role),
                    const SizedBox(height: 24),
                    _buildCoinsCard(profile.coins),
                    const SizedBox(height: 24),
                  ],
                  _buildMenuSection(),
                  const SizedBox(height: 24),
                  _buildSignOutButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatar(String? avatarUrl, String name) => Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: avatarUrl != null
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: avatarUrl,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _avatarPlaceholder(name),
                  ),
                )
              : _avatarPlaceholder(name),
        ),
      );

  Widget _avatarPlaceholder(String name) => Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
      );

  Widget _buildRoleBadge(String role) {
    final isPremium =
        role == 'premium' || role == 'admin' || role == 'moderator';
    if (!isPremium) return const SizedBox.shrink();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.premium, Color(0xFFFFCC02)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.premium.withValues(alpha: 0.4),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              role.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinsCard(int coins) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.toll_rounded,
                  color: AppColors.gold, size: 26),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Coin Bakiyesi',
                  style: TextStyle(color: AppColors.onSurfaceDim, fontSize: 13),
                ),
                Text(
                  '$coins Coin',
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _purchaseLoading ? null : _openPremiumFlow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: Colors.black,
                minimumSize: const Size(80, 36),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
              child: const Text('Satın Al'),
            ),
          ],
        ),
      );

  Widget _buildMenuSection() => Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            _MenuItem(
              icon: Icons.bookmark_rounded,
              label: 'Favorilerim',
              color: AppColors.primary,
              onTap: () => context.go('/favorites'),
            ),
            const Divider(
                height: 1, color: AppColors.outlineVariant, indent: 56),
            _MenuItem(
              icon: Icons.history_rounded,
              label: 'Okuma Geçmişi',
              color: AppColors.tertiary,
              onTap: () {},
            ),
            const Divider(
                height: 1, color: AppColors.outlineVariant, indent: 56),
            _MenuItem(
              icon: Icons.notifications_rounded,
              label: 'Bildirimler',
              color: AppColors.secondary,
              onTap: () => context.go('/notifications'),
            ),
            const Divider(
                height: 1, color: AppColors.outlineVariant, indent: 56),
            _MenuItem(
              icon: Icons.workspace_premium_rounded,
              label: 'Premium Üyelik',
              color: AppColors.premium,
              onTap: _openPremiumFlow,
            ),
            const Divider(
                height: 1, color: AppColors.outlineVariant, indent: 56),
            _MenuItem(
              icon: Icons.settings_rounded,
              label: 'Ayarlar',
              color: AppColors.onSurfaceDim,
              onTap: () {},
            ),
          ],
        ),
      );

  Widget _buildSignOutButton() => OutlinedButton.icon(
        onPressed: _signOut,
        icon: const Icon(Icons.logout_rounded, color: AppColors.error),
        label: const Text(
          'Çıkış Yap',
          style: TextStyle(color: AppColors.error),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          minimumSize: const Size(double.infinity, 50),
        ),
      );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.onSurfaceDim,
            ),
          ],
        ),
      ),
    );
  }
}
