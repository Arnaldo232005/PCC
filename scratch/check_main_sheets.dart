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
        for (int i = 0; i < lines.length; i++) {
          final cols = lines[i].split(',');
          if (cols.isNotEmpty) print('ROW $i: ${cols[0]}');
        }
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
    'metadata_historico',
  ];

  for (final tab in tabs) {
    await checkTab(mainSheetId, tab);
  }
}
