import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/context_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/theme_provider.dart';
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

    final colors = context.colors;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surfaceContainer,
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
              Text(
                'Abonelik satın alabilir veya eski satın alımlarını geri yükleyebilirsin.',
                style: TextStyle(color: colors.onSurfaceDim),
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
    final themeProvider = context.read<ThemeProvider>();
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
        await themeProvider.refreshPremiumStatus();
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
    final themeProvider = context.read<ThemeProvider>();
    setState(() => _purchaseLoading = true);

    try {
      final customerInfo = await RevenueCatService.instance.restorePurchases();
      final hasPremium = RevenueCatService.instance.hasPremiumEntitlement(
        customerInfo,
      );

      if (hasPremium) {
        if (!mounted) return;
        await profileProvider.syncPremiumRole(true);
        await themeProvider.refreshPremiumStatus();
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
    final colors = context.colors;
    return showModalBottomSheet<Package>(
      context: context,
      backgroundColor: colors.surfaceContainer,
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
                  color: colors.surface,
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
      SnackBar(
        content: Text(message),
        backgroundColor: context.colors.primary,
      ),
    );
  }

  Future<void> _signOut() async {
    final colors = context.colors;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: colors.surfaceContainer,
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
    final colors = context.colors;
    final profileProvider = context.watch<ProfileProvider>();
    final profile = profileProvider.profile;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout_rounded, color: colors.error),
            onPressed: _signOut,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: profileProvider.loading && profile == null
          ? Center(
              child: CircularProgressIndicator(color: colors.primary))
          : RefreshIndicator(
              color: colors.primary,
              onRefresh: profileProvider.fetchProfile,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  if (profile != null) ...[
                    _buildAvatar(context, profile.avatarUrl, profile.displayedName),
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
                        style: TextStyle(
                          color: colors.onSurfaceDim,
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
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    _buildRoleBadge(context, profile.role),
                    const SizedBox(height: 24),
                    _buildCoinsCard(context),
                    const SizedBox(height: 24),
                  ],
                  _buildMenuSection(context),
                  const SizedBox(height: 24),
                  _buildSignOutButton(context),
                ],
              ),
            ),
    );
  }

  Widget _buildAvatar(BuildContext context, String? avatarUrl, String name) {
    final colors = context.colors;
    return Center(
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: colors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: colors.primary.withValues(alpha: 0.3),
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
  }

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

  Widget _buildRoleBadge(BuildContext context, String role) {
    final colors = context.colors;
    final isPremium =
        role == 'premium' || role == 'admin' || role == 'moderator';
    if (!isPremium) return const SizedBox.shrink();

    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [colors.premium, const Color(0xFFFFCC02)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colors.premium.withValues(alpha: 0.4),
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

  Widget _buildCoinsCard(BuildContext context) {
    final colors = context.colors;
    final profile = context.read<ProfileProvider>().profile;
    final coins = profile?.coins ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.gold.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.toll_rounded, color: colors.gold, size: 26),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coin Bakiyesi',
                style: TextStyle(color: colors.onSurfaceDim, fontSize: 13),
              ),
              Text(
                '$coins Coin',
                style: TextStyle(
                  color: colors.gold,
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
              backgroundColor: colors.gold,
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
  }

  Widget _buildMenuSection(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _MenuItem(
            icon: Icons.bookmark_rounded,
            label: 'Favorilerim',
            color: colors.primary,
            onTap: () => context.go('/favorites'),
          ),
          Divider(height: 1, color: colors.outlineVariant, indent: 56),
          _MenuItem(
            icon: Icons.history_rounded,
            label: 'Okuma Geçmişi',
            color: colors.tertiary,
            onTap: () {},
          ),
          Divider(height: 1, color: colors.outlineVariant, indent: 56),
          _MenuItem(
            icon: Icons.notifications_rounded,
            label: 'Bildirimler',
            color: colors.secondary,
            onTap: () => context.go('/notifications'),
          ),
          Divider(height: 1, color: colors.outlineVariant, indent: 56),
          _MenuItem(
            icon: Icons.workspace_premium_rounded,
            label: 'Premium Üyelik',
            color: colors.premium,
            onTap: _openPremiumFlow,
          ),
          Divider(height: 1, color: colors.outlineVariant, indent: 56),
          _MenuItem(
            icon: Icons.palette_rounded,
            label: 'Temalar',
            color: colors.primary,
            onTap: () => context.push('/themes'),
          ),
          Divider(height: 1, color: colors.outlineVariant, indent: 56),
          _MenuItem(
            icon: Icons.settings_rounded,
            label: 'Ayarlar',
            color: colors.onSurfaceDim,
            onTap: () => context.push('/settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _signOut,
      icon: Icon(Icons.logout_rounded, color: AppColors.error),
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
    final colors = context.colors;
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
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: colors.onSurfaceDim,
            ),
          ],
        ),
      ),
    );
  }
}
