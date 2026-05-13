import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import '../models/nido.dart';
import '../models/monitoreo_reproduccion.dart';
import '../models/censo.dart';
import '../models/historico_poblacional.dart';
import '../models/reproduccion_resumen.dart';
import '../models/reproduccion_tasas.dart';
import '../models/censo_resumen.dart';
import '../models/metadata_row.dart';

class ExportService {
  static Future<void> exportToExcel({
    required List<Nido> nidos,
    required List<MonitoreoReproduccion> monitoreo,
    required List<Censo> censo,
    required List<HistoricoPoblacional> historico,
    required List<ReproduccionResumen> reproResumen,
    required List<ReproduccionTasas> reproTasas,
    required List<CensoResumen> censoRes,
    required Map<String, List<MetadataRow>> metadata,
  }) async {
    var excel = Excel.createExcel();

    // 1. Cover Sheet / Dashboard
    Sheet summarySheet = excel['RESUMEN'];
    excel.rename('Sheet1', 'RESUMEN');
    
    _addHeader(summarySheet, 1, 1, 'DASHBOARD DE CONSOLIDACIÓN - PROYECTO CONSERVACIÓN');
    _addHeader(summarySheet, 2, 1, '---------------------------------------------------');
    
    _addLabelValue(summarySheet, 4, 1, 'Fecha del Reporte:', DateTime.now().toString().substring(0, 16));
    _addLabelValue(summarySheet, 5, 1, 'Usuario:', 'Investigador PCC');
    
    _addHeader(summarySheet, 7, 1, 'ESTADÍSTICAS GENERALES');
    _addLabelValue(summarySheet, 8, 1, 'Nidos Activos:', nidos.length.toString());
    _addLabelValue(summarySheet, 9, 1, 'Registros de Monitoreo:', monitoreo.length.toString());
    _addLabelValue(summarySheet, 10, 1, 'Registros de Censo:', censo.length.toString());
    _addLabelValue(summarySheet, 11, 1, 'Histórico Poblacional:', historico.length.toString());

    // 2. Main Data Sheets
    _addStyledSheet(excel, 'DATA_NIDOS', Nido.headers, nidos.map((e) => e.toRow()).toList(), ExcelColor.green700);
    _addStyledSheet(excel, 'DATA_MONITOREO', MonitoreoReproduccion.headers, monitoreo.map((e) => e.toRow()).toList(), ExcelColor.blue700);
    _addStyledSheet(excel, 'DATA_CENSO', Censo.headers, censo.map((e) => e.toRow()).toList(), ExcelColor.orange700);
    _addStyledSheet(excel, 'DATA_HISTORICO', HistoricoPoblacional.headers, historico.map((e) => e.toRow()).toList(), ExcelColor.grey700);

    // 3. Summaries
    _addStyledSheet(excel, 'RESUMEN_REPRODUCCION', ReproduccionResumen.headers, reproResumen.map((e) => e.toRow()).toList(), ExcelColor.teal700);
    _addStyledSheet(excel, 'TASAS_ANUALES', ReproduccionTasas.headers, reproTasas.map((e) => e.toRow()).toList(), ExcelColor.indigo700);
    _addStyledSheet(excel, 'RESUMEN_CENSO', CensoResumen.headers, censoRes.map((e) => e.toRow()).toList(), ExcelColor.deepOrange700);

    // 4. Unified Metadata Dictionary
    Sheet metaSheet = excel['DICCIONARIO_DATOS'];
    int currentMetaRow = 0;
    metadata.forEach((key, rows) {
      _addHeader(metaSheet, currentMetaRow, 0, 'DICCIONARIO: ${key.toUpperCase()}');
      currentMetaRow++;
      _addInternalHeader(metaSheet, currentMetaRow, MetadataRow.headers, ExcelColor.blueGrey700);
      currentMetaRow++;
      for (var r in rows) {
        var rowData = r.toRow();
        for (int c = 0; c < rowData.length; c++) {
          var cell = metaSheet.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: currentMetaRow));
          cell.value = TextCellValue(rowData[c]);
          cell.cellStyle = CellStyle(
            backgroundColorHex: currentMetaRow % 2 == 0 ? ExcelColor.white : ExcelColor.grey100,
            bottomBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.grey300),
          );
        }
        currentMetaRow++;
      }
      currentMetaRow += 2; // Gap between sections
    });

    final bytes = excel.save();
    if (bytes == null) return;

    final fileName = "REPORTE_PROYECTO_PCC_${DateTime.now().day}_${DateTime.now().month}.xlsx";

    if (kIsWeb) {
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    }
  }

  static void _addHeader(Sheet sheet, int row, int col, String text) {
    var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cell.value = TextCellValue(text);
    cell.cellStyle = CellStyle(
      bold: true,
      fontSize: 12,
      fontColorHex: ExcelColor.black,
    );
  }

  static void _addInternalHeader(Sheet sheet, int row, List<String> headers, ExcelColor color) {
    for (int i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row));
      cell.value = TextCellValue(headers[i].toUpperCase());
      cell.cellStyle = CellStyle(
        backgroundColorHex: color,
        fontColorHex: ExcelColor.white,
        bold: true,
        horizontalAlign: HorizontalAlign.Center,
      );
    }
  }

  static void _addLabelValue(Sheet sheet, int row, int col, String label, String value) {
    var cellLabel = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row));
    cellLabel.value = TextCellValue(label);
    cellLabel.cellStyle = CellStyle(bold: true, backgroundColorHex: ExcelColor.grey200);

    var cellValue = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col + 1, rowIndex: row));
    cellValue.value = TextCellValue(value);
    cellValue.cellStyle = CellStyle(horizontalAlign: HorizontalAlign.Left);
  }

  // Refactoring _addStyledSheet to work with the sheet name for better clarity
  static void _addStyledSheet(Excel excel, String name, List<String> headers, List<List<String>> rows, ExcelColor headerColor) {
    Sheet sheetObject = excel[name];
    
    // Header Style
    var headerStyle = CellStyle(
      backgroundColorHex: headerColor,
      fontColorHex: ExcelColor.white,
      bold: true,
      fontSize: 11,
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
      bottomBorder: Border(borderStyle: BorderStyle.Medium, borderColorHex: ExcelColor.black),
    );

    // Add Headers
    for (int i = 0; i < headers.length; i++) {
      var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i].toUpperCase());
      cell.cellStyle = headerStyle;
      sheetObject.setColumnWidth(i, 22.0); // Wider for better design
    }

    // Add Rows with Zebra Stripes
    for (int r = 0; r < rows.length; r++) {
      bool isEven = r % 2 == 0;
      var rowStyle = CellStyle(
        backgroundColorHex: isEven ? ExcelColor.white : ExcelColor.grey100,
        horizontalAlign: HorizontalAlign.Left,
        verticalAlign: VerticalAlign.Center,
        bottomBorder: Border(borderStyle: BorderStyle.Thin, borderColorHex: ExcelColor.grey300),
      );

      for (int c = 0; c < rows[r].length; c++) {
        var cell = sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: c, rowIndex: r + 1));
        cell.value = TextCellValue(rows[r][c]);
        cell.cellStyle = rowStyle;
      }
    }
  }
}
