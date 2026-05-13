import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../models/monitoreo_reproduccion.dart';
import 'monitoreo_tables.dart';

class MonitoreoScreen extends StatefulWidget {
  const MonitoreoScreen({super.key});
  @override State<MonitoreoScreen> createState() => _MonitoreoScreenState();
}

class _MonitoreoScreenState extends State<MonitoreoScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final filtered = p.monitoreo.asMap().entries.where((e) {
      final m = e.value;
      return _search.isEmpty ||
          m.idNido.toLowerCase().contains(_search.toLowerCase()) ||
          m.localidad.toLowerCase().contains(_search.toLowerCase()) ||
          m.ano.contains(_search);
    }).toList();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: p.hasWriteAccess ? FloatingActionButton.extended(
          onPressed: () => _showMonitoreoDialog(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Añadir Monitoreo'),
        ) : null,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 80),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Reproducción', style: TextStyle(fontSize: 24,
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text('Monitoreo completo de nidos', style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
            ]),
            const Spacer(),
            SizedBox(
              width: 220,
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Buscar...',
                  prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border)),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          const TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            dividerColor: AppColors.border,
            tabs: [
              Tab(text: 'Monitoreo Detallado'),
              Tab(text: 'Resumen Anual por Nido'),
              Tab(text: 'Tasas Anuales'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                p.monitoreo.isEmpty ? const _Empty() : _MonitoreoTable(entries: filtered),
                p.reproduccionResumen.isEmpty ? const _Empty() : ResumenTable(data: p.reproduccionResumen),
                p.reproduccionTasas.isEmpty ? const _Empty() : TasasTable(data: p.reproduccionTasas),
              ],
            ),
          ),
        ]),
        ),
      ),
    );
  }
}

void _showMonitoreoDialog(BuildContext context, {MonitoreoReproduccion? item, int? index}) {
  showDialog(
    context: context,
    builder: (context) => _MonitoreoFormDialog(item: item, index: index),
  );
}

class _MonitoreoTable extends StatelessWidget {
  final List<MapEntry<int, MonitoreoReproduccion>> entries;
  const _MonitoreoTable({required this.entries});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
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
            rowsPerPage: 10,
            columnSpacing: 15,
            showCheckboxColumn: false,
            horizontalMargin: 15,
            columns: const [
              DataColumn(label: Text('ID Nido')),
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Loc.')),
              DataColumn(label: Text('Año')),
              DataColumn(label: Text('Fecha')),
              DataColumn(label: Text('H. Nat.')),
              DataColumn(label: Text('Act.')),
              DataColumn(label: Text('H. Ecl.')),
              DataColumn(label: Text('H. Dep.')),
              DataColumn(label: Text('H. Des.')),
              DataColumn(label: Text('H. Inf.')),
              DataColumn(label: Text('P. Nat.')),
              DataColumn(label: Text('P. Saq.')),
              DataColumn(label: Text('P. Dep.')),
              DataColumn(label: Text('P. Mue.')),
              DataColumn(label: Text('V. Nat.')),
              DataColumn(label: Text('V. Int.')),
              DataColumn(label: Text('V. Tot.')),
              DataColumn(label: Text('P. Trasl.')),
              DataColumn(label: Text('Depredador')),
              DataColumn(label: Text('Obs.')),
              DataColumn(label: Text('Acciones')),
            ],
            source: _MonitoreoDataSource(context, entries, p.hasWriteAccess),
          ),
        ),
      ),
    );
  }
}

class _MonitoreoDataSource extends DataTableSource {
  final BuildContext context;
  final List<MapEntry<int, MonitoreoReproduccion>> entries;
  final bool hasWriteAccess;

  _MonitoreoDataSource(this.context, this.entries, this.hasWriteAccess);

  @override
  DataRow? getRow(int index) {
    if (index >= entries.length) return null;
    final entry = entries[index];
    final idx = entry.key;
    final m = entry.value;

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(m.idNido, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
        DataCell(Text(m.nombreNido)),
        DataCell(Text(m.localidad)),
        DataCell(Text(m.ano)),
        DataCell(Text(m.fechaMonitoreo)),
        DataCell(_NumCell(m.huevosNaturalesTotal, AppColors.warning)),
        DataCell(Text(m.nidoActivo)),
        DataCell(_NumCell(m.huevosEclosionados, AppColors.accent)),
        DataCell(_NumCell(m.huevosDepredados, AppColors.error)),
        DataCell(_NumCell(m.huevosDestruidos, AppColors.textSecondary)),
        DataCell(_NumCell(m.huevosInfertiles, AppColors.divider)),
        DataCell(_NumCell(m.pichonesNaturalesTotal, AppColors.primaryLight)),
        DataCell(_NumCell(m.pichonesSaqueados, AppColors.error)),
        DataCell(_NumCell(m.pichonesDepredados, AppColors.error)),
        DataCell(_NumCell(m.polluelosMuertos, AppColors.textSecondary)),
        DataCell(_NumCell(m.volantonesNaturales, AppColors.primary)),
        DataCell(_NumCell(m.volantonesIntroducidos, AppColors.accent)),
        DataCell(_NumCell(m.volantonesTotal, AppColors.primary)),
        DataCell(_NumCell(m.pichonesTrasladados, AppColors.divider)),
        DataCell(Text(m.depredador)),
        DataCell(Text(m.observaciones)),
        DataCell(
          hasWriteAccess
              ? IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.accent),
                  onPressed: () => _showMonitoreoDialog(context, item: m, index: idx),
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  @override bool get isRowCountApproximate => false;
  @override int get rowCount => entries.length;
  @override int get selectedRowCount => 0;
}

class _NumCell extends StatelessWidget {
  final String value;
  final Color color;
  const _NumCell(this.value, this.color);
  @override
  Widget build(BuildContext context) {
    final n = int.tryParse(value);
    return Text(n?.toString() ?? (value.isEmpty ? '-' : value),
        style: TextStyle(color: n != null && n > 0 ? color : AppColors.textSecondary,
            fontWeight: FontWeight.w600));
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.egg_alt_rounded, size: 56, color: AppColors.border),
      SizedBox(height: 16),
      Text('No hay registros de reproducción.', style: TextStyle(color: AppColors.textSecondary)),
    ]));
  }
}

class _MonitoreoFormDialog extends StatefulWidget {
  final MonitoreoReproduccion? item;
  final int? index;
  const _MonitoreoFormDialog({this.item, this.index});
  @override State<_MonitoreoFormDialog> createState() => _MonitoreoFormDialogState();
}

class _MonitoreoFormDialogState extends State<_MonitoreoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _idNidoCtrl;
  late final TextEditingController _anoCtrl;
  late final TextEditingController _localidadCtrl;
  late final TextEditingController _fechaCtrl;
  late final TextEditingController _nidoActivoCtrl;
  late final TextEditingController _huevosNatCtrl;
  late final TextEditingController _huevosEclosCtrl;
  late final TextEditingController _huevosDeprCtrl;
  late final TextEditingController _huevosDestCtrl;
  late final TextEditingController _huevosInfCtrl;
  late final TextEditingController _pichonesNatCtrl;
  late final TextEditingController _pichonesSaqCtrl;
  late final TextEditingController _pichonesDeprCtrl;
  late final TextEditingController _polluMuertCtrl;
  late final TextEditingController _volanNatCtrl;
  late final TextEditingController _volanIntrCtrl;
  late final TextEditingController _volanTotCtrl;
  late final TextEditingController _pichonesTraslCtrl;
  late final TextEditingController _depredadorCtrl;
  late final TextEditingController _obsCtrl;

  @override
  void initState() {
    super.initState();
    final m = widget.item;
    _idNidoCtrl       = TextEditingController(text: m?.idNido ?? '');
    _anoCtrl          = TextEditingController(text: m?.ano ?? '');
    _localidadCtrl    = TextEditingController(text: m?.localidad ?? '');
    _fechaCtrl        = TextEditingController(text: m?.fechaMonitoreo ?? '');
    _nidoActivoCtrl   = TextEditingController(text: m?.nidoActivo ?? '');
    _huevosNatCtrl    = TextEditingController(text: m?.huevosNaturalesTotal ?? '');
    _huevosEclosCtrl  = TextEditingController(text: m?.huevosEclosionados ?? '');
    _huevosDeprCtrl   = TextEditingController(text: m?.huevosDepredados ?? '');
    _huevosDestCtrl   = TextEditingController(text: m?.huevosDestruidos ?? '');
    _huevosInfCtrl    = TextEditingController(text: m?.huevosInfertiles ?? '');
    _pichonesNatCtrl  = TextEditingController(text: m?.pichonesNaturalesTotal ?? '');
    _pichonesSaqCtrl  = TextEditingController(text: m?.pichonesSaqueados ?? '');
    _pichonesDeprCtrl = TextEditingController(text: m?.pichonesDepredados ?? '');
    _polluMuertCtrl   = TextEditingController(text: m?.polluelosMuertos ?? '');
    _volanNatCtrl     = TextEditingController(text: m?.volantonesNaturales ?? '');
    _volanIntrCtrl    = TextEditingController(text: m?.volantonesIntroducidos ?? '');
    _volanTotCtrl     = TextEditingController(text: m?.volantonesTotal ?? '');
    _pichonesTraslCtrl = TextEditingController(text: m?.pichonesTrasladados ?? '');
    _depredadorCtrl   = TextEditingController(text: m?.depredador ?? '');
    _obsCtrl          = TextEditingController(text: m?.observaciones ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(widget.item == null ? 'Registrar Monitoreo' : 'Editar Monitoreo'),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section('Identificación'),
                Row(children: [
                  Expanded(child: _field(_idNidoCtrl, 'ID Nido', required: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_anoCtrl, 'Año', required: true)),
                ]),
                Row(children: [
                  Expanded(child: _field(_localidadCtrl, 'Localidad')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_fechaCtrl, 'Fecha')),
                ]),
                _field(_nidoActivoCtrl, 'Nido Activo (SI/NO)'),

                _section('Huevos'),
                Row(children: [
                  Expanded(child: _field(_huevosNatCtrl, 'Naturales')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_huevosEclosCtrl, 'Eclosionados')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_huevosDeprCtrl, 'Depredados')),
                ]),
                Row(children: [
                  Expanded(child: _field(_huevosDestCtrl, 'Destruidos')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_huevosInfCtrl, 'Infértiles')),
                ]),

                _section('Pichones'),
                Row(children: [
                  Expanded(child: _field(_pichonesNatCtrl, 'Naturales')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_pichonesSaqCtrl, 'Saqueados')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_pichonesDeprCtrl, 'Depredados')),
                ]),
                Row(children: [
                  Expanded(child: _field(_polluMuertCtrl, 'Muertos')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_pichonesTraslCtrl, 'Trasladados')),
                ]),

                _section('Volantones'),
                Row(children: [
                  Expanded(child: _field(_volanNatCtrl, 'Naturales')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_volanIntrCtrl, 'Introducidos')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_volanTotCtrl, 'Total')),
                ]),

                _section('Otros'),
                _field(_depredadorCtrl, 'Depredador'),
                _field(_obsCtrl, 'Observaciones', maxLines: 3),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(title, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
  );

  Widget _field(TextEditingController controller, String label, {bool required = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        decoration: InputDecoration(labelText: label, isDense: true),
        validator: required ? (v) => v == null || v.isEmpty ? 'Requerido' : null : null,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final item = MonitoreoReproduccion(
      idNido: _idNidoCtrl.text,
      ano: _anoCtrl.text,
      localidad: _localidadCtrl.text,
      fechaMonitoreo: _fechaCtrl.text,
      nidoActivo: _nidoActivoCtrl.text,
      huevosNaturalesTotal: _huevosNatCtrl.text,
      huevosEclosionados: _huevosEclosCtrl.text,
      huevosDepredados: _huevosDeprCtrl.text,
      huevosDestruidos: _huevosDestCtrl.text,
      huevosInfertiles: _huevosInfCtrl.text,
      pichonesNaturalesTotal: _pichonesNatCtrl.text,
      pichonesSaqueados: _pichonesSaqCtrl.text,
      pichonesDepredados: _pichonesDeprCtrl.text,
      polluelosMuertos: _polluMuertCtrl.text,
      volantonesNaturales: _volanNatCtrl.text,
      volantonesIntroducidos: _volanIntrCtrl.text,
      volantonesTotal: _volanTotCtrl.text,
      pichonesTrasladados: _pichonesTraslCtrl.text,
      depredador: _depredadorCtrl.text,
      observaciones: _obsCtrl.text,
    );
    final p = context.read<AppProvider>();
    final success = widget.item == null ? await p.addMonitoreo(item) : await p.updateMonitoreo(widget.index!, item);
    if (mounted && success) Navigator.pop(context);
  }
}
