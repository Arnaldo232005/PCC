import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../models/historico_poblacional.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});
  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final data = p.historico;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: p.hasWriteAccess
          ? FloatingActionButton.extended(
              onPressed: () => _showHistoricoDialog(context),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Añadir Año'),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 80),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Histórico Poblacional',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          const Text('Evolución del tamaño de la población',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 24),
          if (data.isNotEmpty) ...[
            _SummaryRow(data: data),
            const SizedBox(height: 24),
            Expanded(child: _HistoricoTable(data: data)),
          ] else
            const Expanded(child: _Empty()),
        ]),
      ),
    );
  }
}

void _showHistoricoDialog(BuildContext context,
    {HistoricoPoblacional? item, int? index}) {
  showDialog(
    context: context,
    builder: (context) => _HistoricoFormDialog(item: item, index: index),
  );
}

class _SummaryRow extends StatelessWidget {
  final List<HistoricoPoblacional> data;
  const _SummaryRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final maxVal =
        data.map((h) => h.totalDouble).reduce((a, b) => a > b ? a : b);
    final maxH = data.firstWhere((h) => h.totalDouble == maxVal);
    final last = data.last;
    return Row(children: [
      _MiniStat(
          'Años de datos', '${data.length}', Icons.calendar_today_rounded),
      const SizedBox(width: 14),
      _MiniStat('Máx. volantones', '${maxVal.toStringAsFixed(0)} (${maxH.ano})',
          Icons.trending_up_rounded,
          color: AppColors.primary),
      const SizedBox(width: 14),
      _MiniStat('Último año', '${last.volantonesTotales} (${last.ano})',
          Icons.bar_chart_rounded,
          color: AppColors.accent),
    ]);
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MiniStat(this.label, this.value, this.icon,
      {this.color = AppColors.textSecondary});

  @override
  Widget build(BuildContext context) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border)),
          child: Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(value,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.w700, fontSize: 15)),
              Text(label,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 11)),
            ]),
          ]),
        ),
      );
}

class _HistoricoTable extends StatelessWidget {
  final List<HistoricoPoblacional> data;
  const _HistoricoTable({required this.data});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final sorted = [...data];
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border)),
      child: Theme(
        data: Theme.of(context).copyWith(
          cardColor: AppColors.card,
          dividerColor: AppColors.border,
        ),
        child: SingleChildScrollView(
          child: PaginatedDataTable(
            header: null,
            rowsPerPage: 5, // Smaller because it's in a card
            columnSpacing: 24,
            showCheckboxColumn: false,
            horizontalMargin: 20,
            columns: [
              const DataColumn(label: Text('Año')),
              const DataColumn(label: Text('Pob. Est.')),
              const DataColumn(label: Text('Vol. Nat.')),
              const DataColumn(label: Text('Vol. Art.')),
              const DataColumn(label: Text('Total')),
              const DataColumn(label: Text('Int. 1')),
              const DataColumn(label: Text('Int. 2')),
              const DataColumn(label: Text('Int. 3')),
              const DataColumn(label: Text('Int. 4')),
              const DataColumn(label: Text('Int. 5')),
              const DataColumn(label: Text('Saqueo')),
              if (p.hasWriteAccess) const DataColumn(label: Text('Acciones')),
            ],
            source: _HistoricoDataSource(
                context, sorted.reversed.toList(), p.hasWriteAccess, sorted),
          ),
        ),
      ),
    );
  }
}

class _HistoricoDataSource extends DataTableSource {
  final BuildContext context;
  final List<HistoricoPoblacional> data;
  final bool hasWriteAccess;
  final List<HistoricoPoblacional> originalList;

  _HistoricoDataSource(
      this.context, this.data, this.hasWriteAccess, this.originalList);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final h = data[index];
    final originalIndex = originalList.indexOf(h);

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(h.ano,
            style: const TextStyle(
                color: AppColors.accent, fontWeight: FontWeight.w600))),
        DataCell(Text(h.tamanoPoblacionalEstimado)),
        DataCell(Text(h.volantonesNidosNaturales)),
        DataCell(Text(h.volantonesNidosArtificiales)),
        DataCell(Text(h.volantonesTotales,
            style: const TextStyle(
                color: AppColors.primaryLight, fontWeight: FontWeight.w700))),
        DataCell(Text(h.intervencion1)),
        DataCell(Text(h.intervencion2)),
        DataCell(Text(h.intervencion3)),
        DataCell(Text(h.intervencion4)),
        DataCell(Text(h.intervencion5)),
        DataCell(Text(h.saqueo)),
        if (hasWriteAccess)
          DataCell(IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_rounded,
                size: 18, color: AppColors.accent),
            onPressed: () =>
                _showHistoricoDialog(context, item: h, index: originalIndex),
          )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;
  @override
  int get rowCount => data.length;
  @override
  int get selectedRowCount => 0;
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.bar_chart_rounded, size: 56, color: AppColors.border),
      SizedBox(height: 16),
      Text('No hay datos históricos. Sincroniza las fuentes.',
          style: TextStyle(color: AppColors.textSecondary)),
    ]));
  }
}

// ── Form Dialog ───────────────────────────────────────────────────────────────

class _HistoricoFormDialog extends StatefulWidget {
  final HistoricoPoblacional? item;
  final int? index;
  const _HistoricoFormDialog({this.item, this.index});
  @override
  State<_HistoricoFormDialog> createState() => _HistoricoFormDialogState();
}

class _HistoricoFormDialogState extends State<_HistoricoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _anoCtrl;
  late final TextEditingController _pobEstCtrl;
  late final TextEditingController _volanNatCtrl;
  late final TextEditingController _volanArtCtrl;
  late final TextEditingController _volanTotCtrl;
  late final TextEditingController _int1Ctrl;
  late final TextEditingController _int2Ctrl;
  late final TextEditingController _int3Ctrl;
  late final TextEditingController _int4Ctrl;
  late final TextEditingController _int5Ctrl;
  late final TextEditingController _saqueoCtrl;

  @override
  void initState() {
    super.initState();
    final h = widget.item;
    _anoCtrl =
        TextEditingController(text: h?.ano ?? DateTime.now().year.toString());
    _pobEstCtrl =
        TextEditingController(text: h?.tamanoPoblacionalEstimado ?? '');
    _volanNatCtrl =
        TextEditingController(text: h?.volantonesNidosNaturales ?? '');
    _volanArtCtrl =
        TextEditingController(text: h?.volantonesNidosArtificiales ?? '');
    _volanTotCtrl = TextEditingController(text: h?.volantonesTotales ?? '');
    _int1Ctrl = TextEditingController(text: h?.intervencion1 ?? '');
    _int2Ctrl = TextEditingController(text: h?.intervencion2 ?? '');
    _int3Ctrl = TextEditingController(text: h?.intervencion3 ?? '');
    _int4Ctrl = TextEditingController(text: h?.intervencion4 ?? '');
    _int5Ctrl = TextEditingController(text: h?.intervencion5 ?? '');
    _saqueoCtrl = TextEditingController(text: h?.saqueo ?? '');
  }

  @override
  void dispose() {
    for (final c in [
      _anoCtrl,
      _pobEstCtrl,
      _volanNatCtrl,
      _volanArtCtrl,
      _volanTotCtrl,
      _int1Ctrl,
      _int2Ctrl,
      _int3Ctrl,
      _int4Ctrl,
      _int5Ctrl,
      _saqueoCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(isEditing ? 'Editar Año Histórico' : 'Añadir Año Histórico',
          style: const TextStyle(color: AppColors.textPrimary)),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Identificación ──
                _section('Identificación'),
                Row(children: [
                  Expanded(child: _field(_anoCtrl, 'Año', required: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_pobEstCtrl, 'Población Estimada')),
                ]),

                // ── Volantones ──
                _section('Volantones'),
                Row(children: [
                  Expanded(
                      child: _field(_volanNatCtrl, 'Vol. Nidos Naturales')),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _field(_volanArtCtrl, 'Vol. Nidos Artificiales')),
                ]),
                _field(_volanTotCtrl, 'Total Volantones'),

                // ── Intervenciones ──
                _section('Intervenciones'),
                Row(children: [
                  Expanded(child: _field(_int1Ctrl, 'Intervención 1')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_int2Ctrl, 'Intervención 2')),
                ]),
                Row(children: [
                  Expanded(child: _field(_int3Ctrl, 'Intervención 3')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_int4Ctrl, 'Intervención 4')),
                ]),
                _field(_int5Ctrl, 'Intervención 5'),

                // ── Otros ──
                _section('Otros'),
                _field(_saqueoCtrl, 'Saqueo'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _save,
          child: Text(isEditing ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }

  Widget _section(String text) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.primary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8)),
      );

  Widget _field(TextEditingController ctrl, String label,
      {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: ctrl,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        decoration: InputDecoration(labelText: label, isDense: true),
        validator: required
            ? (v) => v == null || v.isEmpty ? 'Requerido' : null
            : null,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final item = HistoricoPoblacional(
      ano: _anoCtrl.text,
      tamanoPoblacionalEstimado: _pobEstCtrl.text,
      volantonesNidosNaturales: _volanNatCtrl.text,
      volantonesNidosArtificiales: _volanArtCtrl.text,
      volantonesTotales: _volanTotCtrl.text,
      intervencion1: _int1Ctrl.text,
      intervencion2: _int2Ctrl.text,
      intervencion3: _int3Ctrl.text,
      intervencion4: _int4Ctrl.text,
      intervencion5: _int5Ctrl.text,
      saqueo: _saqueoCtrl.text,
    );

    final p = context.read<AppProvider>();
    final bool success;
    if (widget.index != null) {
      success = await p.updateHistorico(widget.index!, item);
    } else {
      success = await p.addHistorico(item);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(widget.index != null
              ? 'Año histórico actualizado en Sheets ✓'
              : 'Año histórico guardado ✓'),
          backgroundColor: AppColors.primary,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error al guardar datos históricos'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }
}
