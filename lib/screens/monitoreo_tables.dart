import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../models/reproduccion_resumen.dart';
import '../models/reproduccion_tasas.dart';
import '../providers/app_provider.dart';

class ResumenTable extends StatelessWidget {
  final List<ReproduccionResumen> data;
  const ResumenTable({super.key, required this.data});

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
            columnSpacing: 20,
            showCheckboxColumn: false,
            horizontalMargin: 20,
            columns: const [
              DataColumn(label: Text('ID Nido')),
              DataColumn(label: Text('Nombre')),
              DataColumn(label: Text('Loc.')),
              DataColumn(label: Text('Año')),
              DataColumn(label: Text('Act.')),
              DataColumn(label: Text('H. Tot.')),
              DataColumn(label: Text('H. Ecl.')),
              DataColumn(label: Text('P. Nat.')),
              DataColumn(label: Text('P. Saq.')),
              DataColumn(label: Text('P. Dep/Mue')),
              DataColumn(label: Text('V. Int.')),
              DataColumn(label: Text('V. Tot.')),
              DataColumn(label: Text('T. Ecl.')),
              DataColumn(label: Text('T. Saq.')),
              DataColumn(label: Text('T. Dep/Mue')),
              DataColumn(label: Text('Exito R.')),
              DataColumn(label: Text('Prod. Par.')),
              DataColumn(label: Text('Prod. Nido')),
              DataColumn(label: Text('Acciones')),
            ],
            source: _ResumenDataSource(context, data),
          ),
        ),
      ),
    );
  }
}

class _ResumenDataSource extends DataTableSource {
  final BuildContext context;
  final List<ReproduccionResumen> data;
  _ResumenDataSource(this.context, this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final m = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(m.idNido, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600))),
        DataCell(Text(m.nombreNido)),
        DataCell(Text(m.localidad)),
        DataCell(Text(m.ano)),
        DataCell(Text(m.nidosActivos)),
        DataCell(Text(m.huevosTotales)),
        DataCell(Text(m.huevosEclosionados)),
        DataCell(Text(m.pichonesNaturalesTotal)),
        DataCell(Text(m.pichonesSaqueados)),
        DataCell(Text(m.pichonesDepredadosMuertos)),
        DataCell(Text(m.volantonesIntroducidos)),
        DataCell(Text(m.volantonesTotales, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(m.tasaEclosion)),
        DataCell(Text(m.tasaSaqueo)),
        DataCell(Text(m.tasaDepredacionMuertes)),
        DataCell(Text(m.exitoReproductivo, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold))),
        DataCell(Text(m.productividadPareja)),
        DataCell(Text(m.productividadPorNido)),
        DataCell(IconButton(
          icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.accent),
          onPressed: () => _showEditResumen(context, index, m),
        )),
      ],
    );
  }
  @override bool get isRowCountApproximate => false;
  @override int get rowCount => data.length;
  @override int get selectedRowCount => 0;
}

void _showEditResumen(BuildContext context, int index, ReproduccionResumen item) {
  showDialog(context: context, builder: (context) => _EditResumenDialog(index: index, item: item));
}

class _EditResumenDialog extends StatefulWidget {
  final int index;
  final ReproduccionResumen item;
  const _EditResumenDialog({required this.index, required this.item});
  @override State<_EditResumenDialog> createState() => _EditResumenDialogState();
}

class _EditResumenDialogState extends State<_EditResumenDialog> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final m = widget.item;
    _controllers = {
      'Activos': TextEditingController(text: m.nidosActivos),
      'H. Totales': TextEditingController(text: m.huevosTotales),
      'H. Eclosionados': TextEditingController(text: m.huevosEclosionados),
      'P. Naturales': TextEditingController(text: m.pichonesNaturalesTotal),
      'P. Saqueados': TextEditingController(text: m.pichonesSaqueados),
      'P. Dep/Mue': TextEditingController(text: m.pichonesDepredadosMuertos),
      'V. Introd': TextEditingController(text: m.volantonesIntroducidos),
      'V. Totales': TextEditingController(text: m.volantonesTotales),
      'Tasa Ecl': TextEditingController(text: m.tasaEclosion),
      'Tasa Saq': TextEditingController(text: m.tasaSaqueo),
      'Tasa Dep': TextEditingController(text: m.tasaDepredacionMuertes),
      'Exito R': TextEditingController(text: m.exitoReproductivo),
      'Prod P': TextEditingController(text: m.productividadPareja),
      'Prod N': TextEditingController(text: m.productividadPorNido),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text('Editar Resumen: ${widget.item.idNido} (${widget.item.ano})'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _controllers.entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                controller: e.value,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
                decoration: InputDecoration(labelText: e.key, isDense: true),
              ),
            )).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }

  Future<void> _save() async {
    final newItem = ReproduccionResumen(
      idNido: widget.item.idNido,
      nombreNido: widget.item.nombreNido,
      localidad: widget.item.localidad,
      ano: widget.item.ano,
      nidosActivos: _controllers['Activos']!.text,
      huevosTotales: _controllers['H. Totales']!.text,
      huevosEclosionados: _controllers['H. Eclosionados']!.text,
      pichonesNaturalesTotal: _controllers['P. Naturales']!.text,
      pichonesSaqueados: _controllers['P. Saqueados']!.text,
      pichonesDepredadosMuertos: _controllers['P. Dep/Mue']!.text,
      volantonesIntroducidos: _controllers['V. Introd']!.text,
      volantonesTotales: _controllers['V. Totales']!.text,
      tasaEclosion: _controllers['Tasa Ecl']!.text,
      tasaSaqueo: _controllers['Tasa Saq']!.text,
      tasaDepredacionMuertes: _controllers['Tasa Dep']!.text,
      exitoReproductivo: _controllers['Exito R']!.text,
      productividadPareja: _controllers['Prod P']!.text,
      productividadPorNido: _controllers['Prod N']!.text,
    );
    final p = context.read<AppProvider>();
    final success = await p.updateReproduccionResumen(widget.index, newItem);
    if (mounted && success) Navigator.pop(context);
  }
}

class TasasTable extends StatelessWidget {
  final List<ReproduccionTasas> data;
  const TasasTable({super.key, required this.data});

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
            columnSpacing: 20,
            showCheckboxColumn: false,
            horizontalMargin: 20,
            columns: const [
              DataColumn(label: Text('Año')),
              DataColumn(label: Text('Prom. Tasa Eclosión')),
              DataColumn(label: Text('Prom. Tasa Saqueo')),
              DataColumn(label: Text('Prom. Tasa Depredación')),
              DataColumn(label: Text('Prom. Éxito Reprod.')),
              DataColumn(label: Text('Prom. Productividad')),
              DataColumn(label: Text('Acciones')),
            ],
            source: _TasasDataSource(context, data),
          ),
        ),
      ),
    );
  }
}

class _TasasDataSource extends DataTableSource {
  final BuildContext context;
  final List<ReproduccionTasas> data;
  _TasasDataSource(this.context, this.data);

  @override
  DataRow? getRow(int index) {
    if (index >= data.length) return null;
    final m = data[index];
    return DataRow.byIndex(
      index: index,
      cells: [
        DataCell(Text(m.ano, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600))),
        DataCell(Text(m.promedioTasaEclosion)),
        DataCell(Text(m.promedioTasaSaqueo)),
        DataCell(Text(m.promedioTasaDepredacion)),
        DataCell(Text(m.promedioExitoReproductivo)),
        DataCell(Text(m.promedioProductividadNido)),
        DataCell(IconButton(
          icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.accent),
          onPressed: () => _showEditTasas(context, index, m),
        )),
      ],
    );
  }
  @override bool get isRowCountApproximate => false;
  @override int get rowCount => data.length;
  @override int get selectedRowCount => 0;
}

void _showEditTasas(BuildContext context, int index, ReproduccionTasas item) {
  showDialog(context: context, builder: (context) => _EditTasasDialog(index: index, item: item));
}

class _EditTasasDialog extends StatefulWidget {
  final int index;
  final ReproduccionTasas item;
  const _EditTasasDialog({required this.index, required this.item});
  @override State<_EditTasasDialog> createState() => _EditTasasDialogState();
}

class _EditTasasDialogState extends State<_EditTasasDialog> {
  late final Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    final m = widget.item;
    _controllers = {
      'Tasa Ecl': TextEditingController(text: m.promedioTasaEclosion),
      'Tasa Saq': TextEditingController(text: m.promedioTasaSaqueo),
      'Tasa Dep': TextEditingController(text: m.promedioTasaDepredacion),
      'Exito R': TextEditingController(text: m.promedioExitoReproductivo),
      'Prod Nido': TextEditingController(text: m.promedioProductividadNido),
    };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.card,
      title: Text('Editar Tasas Anuales: ${widget.item.ano}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: _controllers.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextField(
            controller: e.value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
            decoration: InputDecoration(labelText: e.key, isDense: true),
          ),
        )).toList(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }

  Future<void> _save() async {
    final newItem = ReproduccionTasas(
      ano: widget.item.ano,
      promedioTasaEclosion: _controllers['Tasa Ecl']!.text,
      promedioTasaSaqueo: _controllers['Tasa Saq']!.text,
      promedioTasaDepredacion: _controllers['Tasa Dep']!.text,
      promedioExitoReproductivo: _controllers['Exito R']!.text,
      promedioProductividadNido: _controllers['Prod Nido']!.text,
    );
    final p = context.read<AppProvider>();
    final success = await p.updateReproduccionTasas(widget.index, newItem);
    if (mounted && success) Navigator.pop(context);
  }
}
