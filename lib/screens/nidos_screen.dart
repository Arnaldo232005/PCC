import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../models/nido.dart';

class NidosScreen extends StatefulWidget {
  const NidosScreen({super.key});
  @override State<NidosScreen> createState() => _NidosScreenState();
}

class _NidosScreenState extends State<NidosScreen> {
  String _search = '';
  String _filterLocalidad = 'Todos';

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    final localidades = ['Todos', ...{...p.nidos.map((n) => n.localidad).where((l) => l.isNotEmpty)}];
    final filtered = p.nidos.where((n) {
      final matchSearch = _search.isEmpty ||
          n.idNido.toLowerCase().contains(_search.toLowerCase()) ||
          n.localidad.toLowerCase().contains(_search.toLowerCase());
      final matchLocal = _filterLocalidad == 'Todos' || n.localidad == _filterLocalidad;
      return matchSearch && matchLocal;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: p.hasWriteAccess ? FloatingActionButton.extended(
        onPressed: () => _showNidoDialog(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Añadir Nido'),
      ) : null,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(28, 28, 28, 80),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Nidos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
            Text('Características y ubicación completa', style: TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
          ]),
          const Spacer(),
          _SearchField(onChanged: (v) => setState(() => _search = v)),
          const SizedBox(width: 12),
          _LocalidadFilter(localidades: localidades, selected: _filterLocalidad,
              onChanged: (v) => setState(() => _filterLocalidad = v)),
        ]),
        const SizedBox(height: 20),
        _countChip(filtered.length, p.nidos.length),
        const SizedBox(height: 16),
        Expanded(child: p.nidos.isEmpty
            ? const _EmptyState(message: 'No hay nidos cargados.')
            : _NidosTable(nidos: filtered)),
      ]),
    ),
    );
  }

  Widget _countChip(int shown, int total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.divider, borderRadius: BorderRadius.circular(20)),
      child: Text('Mostrando $shown de $total nidos',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    );
  }
}

void _showNidoDialog(BuildContext context, {Nido? nido, int? index}) {
  showDialog(
    context: context,
    builder: (context) => _NidoFormDialog(nido: nido, index: index),
  );
}

class _NidosTable extends StatelessWidget {
  final List<Nido> nidos;
  const _NidosTable({required this.nidos});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          cardColor: AppColors.card,
          dividerColor: AppColors.border,
        ),
        child: SingleChildScrollView(
          child: PaginatedDataTable(
            header: null,
            rowsPerPage: 10,
            columnSpacing: 20,
            showCheckboxColumn: false,
            horizontalMargin: 20,
            columns: const [
              DataColumn(label: Text('ID Nido')),
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Localidad')),
              DataColumn(label: Text('Lat. I')),
              DataColumn(label: Text('Lon. I')),
              DataColumn(label: Text('Lat. O')),
              DataColumn(label: Text('Lon. O')),
              DataColumn(label: Text('Prof. Horiz.')),
              DataColumn(label: Text('Prof. Vert.')),
              DataColumn(label: Text('Alt. Ent.')),
              DataColumn(label: Text('Diámetro')),
              DataColumn(label: Text('Elevación')),
              DataColumn(label: Text('Material')),
              DataColumn(label: Text('Árbol/Especie')),
              DataColumn(label: Text('DAP')),
              DataColumn(label: Text('Estatus')),
              DataColumn(label: Text('Dir. Ent.')),
              DataColumn(label: Text('Obs.')),
              DataColumn(label: Text('Acciones')),
            ],
            source: _NidosDataSource(context, nidos, p.hasWriteAccess),
          ),
        ),
      ),
    );
  }
}

class _NidosDataSource extends DataTableSource {
  final BuildContext context;
  final List<Nido> nidos;
  final bool hasWriteAccess;

  _NidosDataSource(this.context, this.nidos, this.hasWriteAccess);

  @override
  DataRow? getRow(int index) {
    if (index >= nidos.length) return null;
    final n = nidos[index];

    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(n.idNido, style: const TextStyle(
            color: AppColors.primary, fontWeight: FontWeight.w600))),
        DataCell(Text(n.nombreNido)),
        DataCell(Text(n.localidad)),
        DataCell(Text(n.latitudI)),
        DataCell(Text(n.longitudI)),
        DataCell(Text(n.latitudO)),
        DataCell(Text(n.longitudO)),
        DataCell(Text(n.profundidadHorizontal)),
        DataCell(Text(n.profundidadVertical)),
        DataCell(Text(n.alturaEntrada)),
        DataCell(Text(n.diametro)),
        DataCell(Text(n.elevacionM)),
        DataCell(Text(n.materialNido)),
        DataCell(Text(n.arbolEspecie)),
        DataCell(Text(n.dapCm)),
        DataCell(_EstadoChip(estado: n.estatus)),
        DataCell(Text(n.direccionEntrada)),
        DataCell(Text(n.observacionesNido)),
        DataCell(
          hasWriteAccess
              ? IconButton(
                  icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.accent),
                  onPressed: () => _showNidoDialog(context, nido: n, index: index),
                )
              : const SizedBox(),
        ),
      ],
    );
  }

  @override bool get isRowCountApproximate => false;
  @override int get rowCount => nidos.length;
  @override int get selectedRowCount => 0;
}

class _EstadoChip extends StatelessWidget {
  final String estado;
  const _EstadoChip({required this.estado});
  @override
  Widget build(BuildContext context) {
    final color = estado.toLowerCase().contains('activ')
        ? AppColors.primary
        : estado.toLowerCase().contains('inacti')
            ? AppColors.error
            : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(estado.isEmpty ? '-' : estado,
          style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _SearchField extends StatelessWidget {
  final ValueChanged<String> onChanged;
  const _SearchField({required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: TextField(
        onChanged: onChanged,
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
    );
  }
}

class _LocalidadFilter extends StatelessWidget {
  final List<String> localidades;
  final String selected;
  final ValueChanged<String> onChanged;
  const _LocalidadFilter({required this.localidades, required this.selected, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selected, dropdownColor: AppColors.card,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          items: localidades.map((l) => DropdownMenuItem(value: l, child: Text(l))).toList(),
          onChanged: (v) => v != null ? onChanged(v) : null,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});
  @override
  Widget build(BuildContext context) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.home_rounded, size: 56, color: AppColors.border),
      const SizedBox(height: 16),
      Text(message, style: const TextStyle(color: AppColors.textSecondary)),
    ]));
  }
}

class _NidoFormDialog extends StatefulWidget {
  final Nido? nido;
  final int? index;
  const _NidoFormDialog({this.nido, this.index});
  @override State<_NidoFormDialog> createState() => _NidoFormDialogState();
}

class _NidoFormDialogState extends State<_NidoFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nombreController = TextEditingController();
  final _localidadController = TextEditingController();
  final _latIController = TextEditingController();
  final _lonIController = TextEditingController();
  final _latOController = TextEditingController();
  final _lonOController = TextEditingController();
  final _profHController = TextEditingController();
  final _profVController = TextEditingController();
  final _altEController = TextEditingController();
  final _diamController = TextEditingController();
  final _elevacionController = TextEditingController();
  final _materialController = TextEditingController();
  final _arbolController = TextEditingController();
  final _dapController = TextEditingController();
  final _estatusController = TextEditingController();
  final _dirEController = TextEditingController();
  final _obsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.nido != null) {
      _idController.text = widget.nido!.idNido;
      _nombreController.text = widget.nido!.nombreNido;
      _localidadController.text = widget.nido!.localidad;
      _latIController.text = widget.nido!.latitudI;
      _lonIController.text = widget.nido!.longitudI;
      _latOController.text = widget.nido!.latitudO;
      _lonOController.text = widget.nido!.longitudO;
      _profHController.text = widget.nido!.profundidadHorizontal;
      _profVController.text = widget.nido!.profundidadVertical;
      _altEController.text = widget.nido!.alturaEntrada;
      _diamController.text = widget.nido!.diametro;
      _elevacionController.text = widget.nido!.elevacionM;
      _materialController.text = widget.nido!.materialNido;
      _arbolController.text = widget.nido!.arbolEspecie;
      _dapController.text = widget.nido!.dapCm;
      _estatusController.text = widget.nido!.estatus;
      _dirEController.text = widget.nido!.direccionEntrada;
      _obsController.text = widget.nido!.observacionesNido;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text(widget.nido == null ? 'Añadir Nuevo Nido' : 'Editar Nido',
          style: const TextStyle(color: AppColors.textPrimary)),
      content: SizedBox(
        width: 600,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section('Básico'),
                Row(children: [
                  Expanded(child: _buildField(_idController, 'ID Nido', required: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(_nombreController, 'Nombre')),
                ]),
                _buildField(_localidadController, 'Localidad', required: true),
                
                _section('Ubicación'),
                Row(children: [
                  Expanded(child: _buildField(_latIController, 'Latitud I')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(_lonIController, 'Longitud I')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(_latOController, 'Latitud O')),
                ]),
                Row(children: [
                  Expanded(child: _buildField(_lonOController, 'Longitud O')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(_elevacionController, 'Elevación (m)')),
                ]),

                _section('Características del Nido'),
                Row(children: [
                  Expanded(child: _buildField(_profHController, 'Prof. Horizontal')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(_profVController, 'Prof. Vertical')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(_altEController, 'Altura Entrada')),
                ]),
                Row(children: [
                  Expanded(child: _buildField(_diamController, 'Diámetro')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(_materialController, 'Material')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(_dirEController, 'Dir. Entrada')),
                ]),
                Row(children: [
                  Expanded(child: _buildField(_arbolController, 'Especie Árbol')),
                  const SizedBox(width: 10),
                  Expanded(child: _buildField(_dapController, 'DAP (cm)')),
                ]),

                _section('Estado'),
                _buildField(_estatusController, 'Estatus (Activo/Inactivo)'),
                _buildField(_obsController, 'Observaciones', maxLines: 3),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(title, style: const TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.bold)),
  );

  Widget _buildField(TextEditingController controller, String label, {bool required = false, int maxLines = 1}) {
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
    final nido = Nido(
      idNido: _idController.text,
      nombreNido: _nombreController.text,
      localidad: _localidadController.text,
      latitudI: _latIController.text,
      longitudI: _lonIController.text,
      latitudO: _latOController.text,
      longitudO: _lonOController.text,
      profundidadHorizontal: _profHController.text,
      profundidadVertical: _profVController.text,
      alturaEntrada: _altEController.text,
      diametro: _diamController.text,
      elevacionM: _elevacionController.text,
      materialNido: _materialController.text,
      arbolEspecie: _arbolController.text,
      dapCm: _dapController.text,
      estatus: _estatusController.text,
      direccionEntrada: _dirEController.text,
      observacionesNido: _obsController.text,
    );
    final p = context.read<AppProvider>();
    final success = widget.nido == null ? await p.addNido(nido) : await p.updateNido(widget.index!, nido);
    if (mounted && success) Navigator.pop(context);
  }
}
