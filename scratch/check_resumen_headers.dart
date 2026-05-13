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
      }
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
    'censo_resumen_anual'
  ];

  for (final tab in tabs) {
    await checkTab(mainSheetId, tab);
  }
}
