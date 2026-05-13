import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../models/censo.dart';
import '../models/censo_resumen.dart';

class CensoScreen extends StatefulWidget {
  const CensoScreen({super.key});
  @override State<CensoScreen> createState() => _CensoScreenState();
}

class _CensoScreenState extends State<CensoScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final filtered = p.censo.asMap().entries.where((e) {
      final c = e.value;
      return _search.isEmpty ||
          c.localidad.toLowerCase().contains(_search.toLowerCase()) ||
          c.ano.contains(_search);
    }).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: p.hasWriteAccess ? FloatingActionButton.extended(
          onPressed: () => _showCensoDialog(context),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Añadir Censo'),
        ) : null,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 80),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Censo', style: TextStyle(fontSize: 24,
                  fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              Text('Conteos poblacionales en campo', style: TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
            ]),
            const Spacer(),
            SizedBox(
              width: 220,
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Buscar año o localidad...',
                  prefixIcon: const Icon(Icons.search, size: 16, color: AppColors.textSecondary),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  filled: true, fillColor: AppColors.surface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.border)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8),
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
              Tab(text: 'Registros de Campo'),
              Tab(text: 'Resumen por Localidad'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                p.censo.isEmpty ? const _Empty() : _CensoTable(entries: filtered),
                p.censoResumen.isEmpty ? const _Empty() : _CensoResumenTable(data: p.censoResumen),
              ],
            ),
          ),
        ]),
        ),
      ),
    );
  }
}

void _showCensoDialog(BuildContext context, {Censo? item, int? index}) {
  showDialog(
    context: context,
    builder: (context) => _CensoFormDialog(item: item, index: index),
  );
}

class _CensoTable extends StatelessWidget {
  final List<MapEntry<int, Censo>> entries;
  const _CensoTable({required this.entries});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.card,
          borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Theme(
        data: Theme.of(context).copyWith(
          cardColor: AppColors.card,
          dividerColor: AppColors.border,
        ),
        child: SingleChildScrollView(
          child: PaginatedDataTable(
            header: null,
            rowsPerPage: 10,
            columnSpacing: 24,
            showCheckboxColumn: false,
            horizontalMargin: 20,
            columns: [
              const DataColumn(label: Text('Año')),
              const DataColumn(label: Text('Mes')),
              const DataColumn(label: Text('Día')),
              const DataColumn(label: Text('Localidad')),
              const DataColumn(label: Text('Latitud')),
              const DataColumn(label: Text('Longitud')),
              const DataColumn(label: Text('Individuos')),
              const DataColumn(label: Text('N° Observadores')),
              const DataColumn(label: Text('Hora Inicio')),
              const DataColumn(label: Text('Hora Fin')),
              const DataColumn(label: Text('Elevación')),
              const DataColumn(label: Text('Error Obs.')),
              const DataColumn(label: Text('Clima')),
              const DataColumn(label: Text('Humedad')),
              const DataColumn(label: Text('Viento')),
              const DataColumn(label: Text('Águila Presente')),
              if (p.hasWriteAccess) const DataColumn(label: Text('Acciones')),
            ],
            source: _CensoDataSource(context, entries, p.hasWriteAccess),
          ),
        ),
      ),
    );
  }
}

class _CensoDataSource extends DataTableSource {
  final BuildContext context;
  final List<MapEntry<int, Censo>> entries;
  final bool hasWriteAccess;

  _CensoDataSource(this.context, this.entries, this.hasWriteAccess);

  @override
  DataRow? getRow(int index) {
    if (index >= entries.length) return null;
    final entry = entries[index];
    final idx = entry.key;
    final c = entry.value;

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(c.ano, style: const TextStyle(
            color: AppColors.accent, fontWeight: FontWeight.w600))),
        DataCell(Text(c.mes)),
        DataCell(Text(c.dia)),
        DataCell(Text(c.localidad)),
        DataCell(Text(c.latitud)),
        DataCell(Text(c.longitud)),
        DataCell(Text(c.nIndividuos, style: const TextStyle(
            color: AppColors.primaryLight, fontWeight: FontWeight.w600))),
        DataCell(Text(c.nObservadores)),
        DataCell(Text(c.horaInicio)),
        DataCell(Text(c.horaFin)),
        DataCell(Text(c.elevacionM)),
        DataCell(Text(c.errorObservacion)),
        DataCell(Text(c.clima)),
        DataCell(Text(c.humedad)),
        DataCell(Text(c.viento)),
        DataCell(Text(c.aguilaPresente)),
        if (hasWriteAccess)
          DataCell(IconButton(
            tooltip: 'Editar',
            icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.accent),
            onPressed: () => _showCensoDialog(context, item: c, index: idx),
          )),
      ],
    );
  }
  @override bool get isRowCountApproximate => false;
  @override int get rowCount => entries.length;
  @override int get selectedRowCount => 0;
}

class _CensoResumenTable extends StatelessWidget {
  final List<CensoResumen> data;
  const _CensoResumenTable({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: AppColors.card,
          borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Theme(
        data: Theme.of(context).copyWith(
          cardColor: AppColors.card,
          dividerColor: AppColors.border,
        ),
        child: SingleChildScrollView(
          child: PaginatedDataTable(
            header: null,
            rowsPerPage: 10,
            columnSpacing: 24,
            showCheckboxColumn: false,
            horizontalMargin: 20,
            columns: const [
              DataColumn(label: Text('Localidad')),
              DataColumn(label: Text('Año')),
              DataColumn(label: Text('N° Censos')),
              DataColumn(label: Text('Total Individuos')),
              DataColumn(label: Text('Promedio')),
              DataColumn(label: Text('Máximo')),
              DataColumn(label: Text('Acciones')),
            ],
            source: _CensoResumenDataSource(context, data),
          ),
        ),
      ),
    );
  }
}

class _CensoResumenDataSource extends DataTableSource {
  final BuildContext context;
  final List<CensoResumen> data;
  _CensoResumenDataSource(this.context, this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final c = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(c.localidad, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600))),
        DataCell(Text(c.ano)),
        DataCell(Text(c.nCensos)),
        DataCell(Text(c.totalIndividuos, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
        DataCell(Text(c.promedioIndividuos)),
        DataCell(Text(c.maxIndividuos, style: const TextStyle(color: AppColors.warning))),
        DataCell(IconButton(
          icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.accent),
          onPressed: () => _showEditResumen(context, index, c),
        )),
      ],
    );
  }
  @override bool get isRowCountApproximate => false;
  @override int get rowCount => data.length;
  @override int get selectedRowCount => 0;
}

void _showEditResumen(BuildContext context, int index, CensoResumen item) {
  showDialog(context: context, builder: (context) => _EditCensoResumenDialog(index: index, item: item));
}

class _EditCensoResumenDialog extends StatefulWidget {
  final int index;
  final CensoResumen item;
  const _EditCensoResumenDialog({required this.index, required this.item});
  @override State<_EditCensoResumenDialog> createState() => _EditCensoResumenDialogState();
}

class _EditCensoResumenDialogState extends State<_EditCensoResumenDialog> {
  late final TextEditingController _nCensosCtrl;
  late final TextEditingController _totalCtrl;
  late final TextEditingController _promCtrl;
  late final TextEditingController _maxCtrl;

  @override
  void initState() {
    super.initState();
    _nCensosCtrl = TextEditingController(text: widget.item.nCensos);
    _totalCtrl = TextEditingController(text: widget.item.totalIndividuos);
    _promCtrl = TextEditingController(text: widget.item.promedioIndividuos);
    _maxCtrl = TextEditingController(text: widget.item.maxIndividuos);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text('Editar Resumen: ${widget.item.localidad} (${widget.item.ano})'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _field(_nCensosCtrl, 'N° Censos'),
          _field(_totalCtrl, 'Total Individuos'),
          _field(_promCtrl, 'Promedio'),
          _field(_maxCtrl, 'Máximo'),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: ctrl,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        decoration: InputDecoration(labelText: label, isDense: true),
      ),
    );
  }

  Future<void> _save() async {
    final newItem = CensoResumen(
      localidad: widget.item.localidad,
      ano: widget.item.ano,
      nCensos: _nCensosCtrl.text,
      totalIndividuos: _totalCtrl.text,
      promedioIndividuos: _promCtrl.text,
      maxIndividuos: _maxCtrl.text,
    );
    final p = context.read<AppProvider>();
    final success = await p.updateCensoResumen(widget.index, newItem);
    if (mounted && success) Navigator.pop(context);
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.groups_rounded, size: 56, color: AppColors.border),
      SizedBox(height: 16),
      Text('No hay registros de censo.',
          style: TextStyle(color: AppColors.textSecondary)),
    ]));
  }
}

class _CensoFormDialog extends StatefulWidget {
  final Censo? item;
  final int? index;
  const _CensoFormDialog({this.item, this.index});
  @override State<_CensoFormDialog> createState() => _CensoFormDialogState();
}

class _CensoFormDialogState extends State<_CensoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _anoCtrl;
  late final TextEditingController _mesCtrl;
  late final TextEditingController _diaCtrl;
  late final TextEditingController _localidadCtrl;
  late final TextEditingController _latCtrl;
  late final TextEditingController _lonCtrl;
  late final TextEditingController _nIndCtrl;
  late final TextEditingController _nObsCtrl;
  late final TextEditingController _hIniCtrl;
  late final TextEditingController _hFinCtrl;
  late final TextEditingController _elevCtrl;
  late final TextEditingController _errObsCtrl;
  late final TextEditingController _climaCtrl;
  late final TextEditingController _humCtrl;
  late final TextEditingController _vientoCtrl;
  late final TextEditingController _aguilaCtrl;

  @override
  void initState() {
    super.initState();
    final c = widget.item;
    _anoCtrl       = TextEditingController(text: c?.ano ?? DateTime.now().year.toString());
    _mesCtrl       = TextEditingController(text: c?.mes ?? '');
    _diaCtrl       = TextEditingController(text: c?.dia ?? '');
    _localidadCtrl = TextEditingController(text: c?.localidad ?? '');
    _latCtrl       = TextEditingController(text: c?.latitud ?? '');
    _lonCtrl       = TextEditingController(text: c?.longitud ?? '');
    _nIndCtrl      = TextEditingController(text: c?.nIndividuos ?? '');
    _nObsCtrl      = TextEditingController(text: c?.nObservadores ?? '');
    _hIniCtrl      = TextEditingController(text: c?.horaInicio ?? '');
    _hFinCtrl      = TextEditingController(text: c?.horaFin ?? '');
    _elevCtrl      = TextEditingController(text: c?.elevacionM ?? '');
    _errObsCtrl    = TextEditingController(text: c?.errorObservacion ?? '');
    _climaCtrl     = TextEditingController(text: c?.clima ?? '');
    _humCtrl       = TextEditingController(text: c?.humedad ?? '');
    _vientoCtrl    = TextEditingController(text: c?.viento ?? '');
    _aguilaCtrl    = TextEditingController(text: c?.aguilaPresente ?? '');
  }

  @override
  void dispose() {
    for (final c in [_anoCtrl, _mesCtrl, _diaCtrl, _localidadCtrl, _latCtrl, _lonCtrl, _nIndCtrl,
                     _nObsCtrl, _hIniCtrl, _hFinCtrl, _elevCtrl, _errObsCtrl, _climaCtrl, _humCtrl, _vientoCtrl, _aguilaCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(isEditing ? 'Editar Censo' : 'Registrar Nuevo Censo',
          style: const TextStyle(color: AppColors.textPrimary)),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(children: [
                  Expanded(child: _field(_anoCtrl, 'Año', required: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_mesCtrl, 'Mes')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_diaCtrl, 'Día')),
                ]),
                _field(_localidadCtrl, 'Localidad', required: true),
                Row(children: [
                  Expanded(child: _field(_latCtrl, 'Latitud')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_lonCtrl, 'Longitud')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_elevCtrl, 'Elevación (m)')),
                ]),
                Row(children: [
                  Expanded(child: _field(_nIndCtrl, 'N° Individuos', required: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_nObsCtrl, 'N° Observadores')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_aguilaCtrl, 'Águila Presente')),
                ]),
                Row(children: [
                  Expanded(child: _field(_hIniCtrl, 'Hora Inicio')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_hFinCtrl, 'Hora Fin')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_errObsCtrl, 'Error Obs.')),
                ]),
                Row(children: [
                  Expanded(child: _field(_climaCtrl, 'Clima')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_humCtrl, 'Humedad')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_vientoCtrl, 'Viento')),
                ]),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _save,
          child: Text(isEditing ? 'Actualizar' : 'Guardar'),
        ),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        decoration: InputDecoration(labelText: label, isDense: true),
        validator: required ? (v) => v == null || v.isEmpty ? 'Requerido' : null : null,
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final item = Censo(
      ano:              _anoCtrl.text,
      mes:              _mesCtrl.text,
      dia:              _diaCtrl.text,
      localidad:        _localidadCtrl.text,
      latitud:          _latCtrl.text,
      longitud:         _lonCtrl.text,
      nIndividuos:      _nIndCtrl.text,
      nObservadores:    _nObsCtrl.text,
      horaInicio:       _hIniCtrl.text,
      horaFin:          _hFinCtrl.text,
      elevacionM:       _elevCtrl.text,
      errorObservacion: _errObsCtrl.text,
      clima:            _climaCtrl.text,
      humedad:          _humCtrl.text,
      viento:           _vientoCtrl.text,
      aguilaPresente:   _aguilaCtrl.text,
    );

    final p = context.read<AppProvider>();
    final bool success;
    if (widget.index != null) {
      success = await p.updateCenso(widget.index!, item);
    } else {
      success = await p.addCenso(item);
    }

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Censo guardado ✓'),
          backgroundColor: AppColors.primary,
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Error al guardar censo'),
          backgroundColor: AppColors.error,
        ));
      }
    }
  }
}
