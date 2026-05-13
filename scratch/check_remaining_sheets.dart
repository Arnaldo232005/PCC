import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> checkTab(String sheetId, String tabName) async {
  final url = 'https://docs.google.com/spreadsheets/d/$sheetId/gviz/tq?tqx=out:csv&sheet=${Uri.encodeComponent(tabName)}';
  try {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      final lines = LineSplitter.split(res.body).toList();
      if (lines.isNotEmpty && !lines.first.contains('<!DOCTYPE html>')) {
        print('TAB: $tabName');
        print('HEADERS: ${lines.first}');
        if (lines.length > 1) {
          print('ROW 1: ${lines[1]}');
        }
        print('Total Rows: ${lines.length}');
        print('----------------------------------------');
      } else {
        print('TAB: $tabName - Not found or empty HTML');
      }
    } else {
      print('TAB: $tabName - Status ${res.statusCode}');
    }
  } catch (e) {
    print('Error on $tabName: $e');
  }
}

void main() async {
  const mainSheetId = '1fz4l1IepOSKtdPNiRqrtfdKUlIJuq54TzJdxAdEl-ho';
  final tabs = [
    'reproduccion_resumen_anual',
    'reproduccion_tasas_anuales',
    'censo_resumen_anual',
    'metadata_reproduccion',
    'metadata_nidos',
    'metadata_censo',
    'metadata_historico',
    'metadata_tasas_anuales' // Guessing this one
  ];

  for (final tab in tabs) {
    await checkTab(mainSheetId, tab);
  }
}
