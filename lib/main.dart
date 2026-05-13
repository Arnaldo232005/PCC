import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme.dart';
import 'core/secrets.dart';
import 'providers/app_provider.dart';
import 'widgets/side_nav.dart';
import 'screens/home_screen.dart';
import 'screens/nidos_screen.dart';
import 'screens/monitoreo_screen.dart';
import 'screens/censo_screen.dart';
import 'screens/historico_screen.dart';
import 'screens/metadata_screen.dart';
import 'screens/export_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: AppSecrets.supabaseUrl,
    anonKey: AppSecrets.supabaseAnonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const PccApp(),
    ),
  );
}

class PccApp extends StatelessWidget {
  const PccApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PCC - Monitoreo Cotorra Margariteña',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  final int initialIndex;
  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;

  final _screens = const [
    HomeScreen(),
    NidosScreen(),
    MonitoreoScreen(),
    CensoScreen(),
    HistoricoScreen(),
    MetadataScreen(),
    ExportScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(children: [
        _TopBar(
            onReload: p.loadAllData,
            isConnected: p.isConnected,
            statusMessage: p.statusMessage),
        Expanded(
          child: Row(children: [
            SideNav(
              selectedIndex: _currentIndex,
              onDestinationSelected: (i) => setState(() => _currentIndex = i),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: KeyedSubtree(
                  key: ValueKey(_currentIndex),
                  child: _screens[_currentIndex],
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onReload;
  final bool isConnected;
  final String statusMessage;

  const _TopBar({required this.onReload, required this.isConnected, required this.statusMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        const Icon(Icons.eco_rounded, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        const Text('PCC · Cotorra Margariteña',
            style: TextStyle(color: AppColors.textPrimary,
                fontWeight: FontWeight.w600, fontSize: 13)),
        const Spacer(),
        Container(width: 6, height: 6,
            decoration: const BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(statusMessage.isEmpty ? 'Cargando...' : statusMessage,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        const SizedBox(width: 16),
        IconButton(tooltip: 'Recargar', onPressed: onReload,
            icon: const Icon(Icons.refresh_rounded,
                color: AppColors.textSecondary, size: 18)),
      ]),
    );
  }
}
