import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/router.dart';
import 'core/theme.dart';
import 'state/settings_provider.dart';

class TerritorioVivoApp extends StatefulWidget {
  const TerritorioVivoApp({super.key});

  @override
  State<TerritorioVivoApp> createState() => _TerritorioVivoAppState();
}

class _TerritorioVivoAppState extends State<TerritorioVivoApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = buildRouter(context.read<SettingsProvider>());
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    return MaterialApp.router(
      title: 'Território Vivo',
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
      theme: AppTheme.build(Brightness.light, highContrast: settings.highContrast),
      darkTheme: AppTheme.build(Brightness.dark, highContrast: settings.highContrast),
      themeMode: settings.themeMode,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
