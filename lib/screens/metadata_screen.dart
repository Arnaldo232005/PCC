import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_provider.dart';
import '../models/metadata_row.dart';

class MetadataScreen extends StatelessWidget {
  const MetadataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<AppProvider>();

    return DefaultTabController(
      length: 5,
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Metadatos', style: TextStyle(fontSize: 24,
              fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const Text('Diccionarios de datos y estructura de las tablas', style: TextStyle(
              color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          const TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            dividerColor: AppColors.border,
            tabs: [
              Tab(text: 'Nidos'),
              Tab(text: 'Reproducción'),
              Tab(text: 'Censo'),
              Tab(text: 'Histórico'),
              Tab(text: 'Tasas Anuales'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              children: [
                _MetadataTable(mKey: 'nidos', data: p.metadata['nidos'] ?? []),
                _MetadataTable(mKey: 'reproduccion', data: p.metadata['reproduccion'] ?? []),
                _MetadataTable(mKey: 'censo', data: p.metadata['censo'] ?? []),
                _MetadataTable(mKey: 'historico', data: p.metadata['historico'] ?? []),
                _MetadataTable(mKey: 'tasas_anuales', data: p.metadata['tasas_anuales'] ?? []),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

class _MetadataTable extends StatelessWidget {
  final String mKey;
  final List<MetadataRow> data;
  const _MetadataTable({required this.mKey, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const Center(child: Text('Sin datos', style: TextStyle(color: AppColors.textSecondary)));
    return Container(
      decoration: BoxDecoration(color: AppColors.card,
          borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: DataTable(
              headingRowColor: const WidgetStatePropertyAll(AppColors.surface),
              columnSpacing: 24,
              headingTextStyle: const TextStyle(color: AppColors.textSecondary,
                  fontSize: 12, fontWeight: FontWeight.w600),
              dataTextStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
              columns: const [
                DataColumn(label: Text('Campo')),
                DataColumn(label: Text('Descripción')),
                DataColumn(label: Text('Tipo Dato')),
                DataColumn(label: Text('Valores Permitidos')),
                DataColumn(label: Text('Ejemplo')),
                DataColumn(label: Text('Acciones')),
              ],
              rows: data.asMap().entries.map((entry) {
                final idx = entry.key;
                final m = entry.value;
                return DataRow(cells: [
                  DataCell(Text(m.campo, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
                  DataCell(ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Text(m.descripcion, overflow: TextOverflow.visible))),
                  DataCell(Text(m.tipoDato)),
                  DataCell(Text(m.valoresPermitidos)),
                  DataCell(Text(m.ejemplo)),
                  DataCell(IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.accent),
                    onPressed: () => _showEditDialog(context, mKey, idx, m),
                  )),
                ]);
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, String key, int index, MetadataRow item) {
    showDialog(
      context: context,
      builder: (context) => _MetadataEditDialog(mKey: key, index: index, item: item),
    );
  }
}

class _MetadataEditDialog extends StatefulWidget {
  final String mKey;
  final int index;
  final MetadataRow item;
  const _MetadataEditDialog({required this.mKey, required this.index, required this.item});

  @override State<_MetadataEditDialog> createState() => _MetadataEditDialogState();
}

class _MetadataEditDialogState extends State<_MetadataEditDialog> {
  late final TextEditingController _descCtrl;
  late final TextEditingController _tipoCtrl;
  late final TextEditingController _valsCtrl;
  late final TextEditingController _ejemCtrl;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.item.descripcion);
    _tipoCtrl = TextEditingController(text: widget.item.tipoDato);
    _valsCtrl = TextEditingController(text: widget.item.valoresPermitidos);
    _ejemCtrl = TextEditingController(text: widget.item.ejemplo);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text('Editar Campo: ${widget.item.campo}', style: const TextStyle(color: AppColors.textPrimary)),
      content: SizedBox(
        width: 450,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_descCtrl, 'Descripción', maxLines: 3),
            _field(_tipoCtrl, 'Tipo de Dato'),
            _field(_valsCtrl, 'Valores Permitidos'),
            _field(_ejemCtrl, 'Ejemplo'),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }

  Widget _field(TextEditingController ctrl, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
        decoration: InputDecoration(labelText: label, isDense: true),
      ),
    );
  }

  Future<void> _save() async {
    final newItem = MetadataRow(
      campo: widget.item.campo,
      descripcion: _descCtrl.text,
      tipoDato: _tipoCtrl.text,
      valoresPermitidos: _valsCtrl.text,
      ejemplo: _ejemCtrl.text,
    );
    final p = context.read<AppProvider>();
    final success = await p.updateMetadataRow(widget.mKey, widget.index, newItem);
    if (mounted && success) Navigator.pop(context);
  }
}
