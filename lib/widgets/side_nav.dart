import 'package:flutter/material.dart';
import '../core/theme.dart';

class SideNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const SideNav({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.eco_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PCC', style: TextStyle(
                        color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
                    Text('Monitoreo', style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('PANEL', style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 10,
                  fontWeight: FontWeight.w600, letterSpacing: 1.2)),
            ),
          ),
          ..._buildItems(context),
          const Spacer(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _buildItems(BuildContext context) {
    const items = [
      (Icons.dashboard_rounded, 'Inicio', 0),
      (Icons.home_rounded, 'Nidos', 1),
      (Icons.egg_alt_rounded, 'Reproducción', 2),
      (Icons.groups_rounded, 'Censo', 3),
      (Icons.bar_chart_rounded, 'Histórico', 4),
      (Icons.menu_book_rounded, 'Metadatos', 5),
      (Icons.ios_share_rounded, 'Exportar', 6),
    ];
    return items.map((item) => _NavItem(
      icon: item.$1, label: item.$2, index: item.$3,
      selectedIndex: selectedIndex,
      onTap: () => onDestinationSelected(item.$3),
    )).toList();
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon, required this.label, required this.index,
    required this.selectedIndex, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: 18),
            const SizedBox(width: 10),
            Text(label,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 13,
                )),
            if (isSelected) ...[
              const Spacer(),
              Container(width: 3, height: 16,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(2))),
            ],
          ],
        ),
      ),
    );
  }
}
