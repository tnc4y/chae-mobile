import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/app_constants.dart';
import 'config/env.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'services/revenuecat_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: Env.supabaseUrl,
    anonKey: Env.supabaseAnon,
  );

  await RevenueCatService.instance.initialize(
    appUserId: Supabase.instance.client.auth.currentUser?.id,
  );

  final themeProvider = ThemeProvider();
  await themeProvider.initialize();

  final settingsProvider = SettingsProvider();
  await settingsProvider.initialize();

  runApp(ChaeApp(
    themeProvider: themeProvider,
    settingsProvider: settingsProvider,
  ));
}

class ChaeApp extends StatelessWidget {
  final ThemeProvider themeProvider;
  final SettingsProvider settingsProvider;

  const ChaeApp({
    super.key,
    required this.themeProvider,
    required this.settingsProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider.value(value: settingsProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (_, tp, __) => MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.from(tp.current.palette),
          routerConfig: buildRouter(),
        ),
      ),
    );
  }
}