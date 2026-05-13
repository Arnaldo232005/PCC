import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(p),
          const SizedBox(height: 28),
          _statusBanner(p),
          const SizedBox(height: 28),
          _statsGrid(p),
          const SizedBox(height: 28),
          _quickActions(context),
        ],
      ),
    );
  }

  Widget _header(AppProvider p) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Panel de Control',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Text('Cotorra Margariteña · ${DateTime.now().year}',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
    ]);
  }

  Widget _statusBanner(AppProvider p) {
    final isErr     = p.status == AppStatus.error;
    final isLoading = p.status == AppStatus.loading;
    final color = isErr ? AppColors.error : isLoading ? AppColors.warning : AppColors.primary;
    final icon  = isErr ? Icons.error_rounded : isLoading
        ? Icons.hourglass_top_rounded : Icons.cloud_done_rounded;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(children: [
        if (isLoading)
          SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: color))
        else Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(child: Text(
            p.statusMessage.isEmpty ? 'Cargando...' : p.statusMessage,
            style: TextStyle(color: color, fontSize: 13))),
        if (!p.hasWriteAccess && p.status == AppStatus.ready)
          Container(
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
            ),
            child: const Text('Solo lectura',
                style: TextStyle(color: AppColors.warning, fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
      ]),
    );
  }

  Widget _statsGrid(AppProvider p) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.15,
      children: [
        StatCard(title: 'Nidos Registrados', value: '${p.totalNidos}',
            icon: Icons.home_rounded, iconColor: AppColors.primary),
        StatCard(title: 'Monitoreos', value: '${p.totalMonitoreo}',
            icon: Icons.egg_alt_rounded, iconColor: AppColors.accent),
        StatCard(title: 'Registros Censo', value: '${p.totalCenso}',
            icon: Icons.groups_rounded, iconColor: AppColors.warning),
        StatCard(
          title: 'Volantones (${p.lastHistoricoAno})',
          value: p.lastHistoricoTotal.toStringAsFixed(0),
          icon: Icons.bar_chart_rounded, iconColor: AppColors.primaryLight,
          subtitle: 'Último año histórico',
        ),
      ],
    );
  }

  Widget _quickActions(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Acciones Rápidas',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary)),
      const SizedBox(height: 14),
      Row(children: [
        _ActionCard(
          icon: Icons.sync_rounded, label: 'Sincronizar Fuentes',
          color: AppColors.primary,
          onTap: () => Navigator.pushNamed(context, '/sync'),
        ),
        const SizedBox(width: 14),
        _ActionCard(
          icon: Icons.refresh_rounded, label: 'Recargar Datos',
          color: AppColors.accent,
          onTap: () => context.read<AppProvider>().loadAllData(),
        ),
        const SizedBox(width: 14),
        _ActionCard(
          icon: Icons.settings_rounded, label: 'Configuración',
          color: AppColors.textSecondary,
          onTap: () => Navigator.pushNamed(context, '/config'),
        ),
      ]),
    ]);
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({required this.icon, required this.label,
      required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w500,
                fontSize: 13)),
          ]),
        ),
      ),
    );
  }
}
