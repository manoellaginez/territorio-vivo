import 'package:go_router/go_router.dart';

import '../screens/about_screen.dart';
import '../screens/alert_detail_screen.dart';
import '../screens/consent_screen.dart';
import '../screens/home_screen.dart';
import '../screens/indicator_detail_screen.dart';
import '../screens/occurrence_form_screen.dart';
import '../screens/settings_screen.dart';
import '../state/settings_provider.dart';

/// Rotas nomeadas, com passagem de parâmetros e redirecionamento por consentimento.
GoRouter buildRouter(SettingsProvider settings) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: settings,
    redirect: (context, state) {
      final atConsent = state.matchedLocation == '/consent';
      if (!settings.consent && !atConsent) return '/consent';
      if (settings.consent && atConsent) return '/';
      return null;
    },
    routes: [
      GoRoute(
        name: 'consent',
        path: '/consent',
        builder: (context, state) => const ConsentScreen(),
      ),
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            name: 'indicator',
            path: 'indicator/:id',
            builder: (context, state) =>
                IndicatorDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            name: 'alert',
            path: 'alert/:id',
            builder: (context, state) =>
                AlertDetailScreen(id: state.pathParameters['id']!),
          ),
          GoRoute(
            name: 'occurrence-new',
            path: 'occurrence/new',
            builder: (context, state) => const OccurrenceFormScreen(),
          ),
          GoRoute(
            name: 'settings',
            path: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            name: 'about',
            path: 'about',
            builder: (context, state) => const AboutScreen(),
          ),
        ],
      ),
    ],
  );
}
