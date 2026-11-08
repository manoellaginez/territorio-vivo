import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'data/services/storage_service.dart';
import 'state/occurrences_provider.dart';
import 'state/settings_provider.dart';
import 'state/territory_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await StorageService.create();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider(storage)),
        ChangeNotifierProvider(create: (_) => OccurrencesProvider(storage)),
        ChangeNotifierProvider(create: (_) => TerritoryProvider(storage)),
      ],
      child: const TerritorioVivoApp(),
    ),
  );
}
