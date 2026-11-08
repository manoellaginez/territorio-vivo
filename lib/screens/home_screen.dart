import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../state/settings_provider.dart';
import '../state/territory_provider.dart';
import 'alerts_tab.dart';
import 'citizen_tab.dart';
import 'dashboards_tab.dart';
import 'overview_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TerritoryProvider>().init(context.read<SettingsProvider>().thresholds);
    });
  }

  static const _titles = ['Visão geral', 'Painéis', 'Alertas', 'Cidadão'];

  @override
  Widget build(BuildContext context) {
    final pending = context.watch<TerritoryProvider>().pendingAlertCount;
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          IconButton(
            tooltip: 'Sobre os dados e o método',
            icon: const Icon(Icons.info_outline),
            onPressed: () => context.pushNamed('about'),
          ),
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.pushNamed('settings'),
          ),
        ],
      ),
      body: IndexedStack(
        index: _index,
        children: [
          OverviewTab(onSeeAlerts: () => setState(() => _index = 2)),
          const DashboardsTab(),
          const AlertsTab(),
          const CitizenTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Visão geral',
          ),
          const NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Painéis',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: pending > 0,
              label: Text('$pending'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: const Icon(Icons.notifications),
            label: 'Alertas',
          ),
          const NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Cidadão',
          ),
        ],
      ),
    );
  }
}
