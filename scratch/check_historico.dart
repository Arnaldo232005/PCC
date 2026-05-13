import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> checkTab(String sheetId, String tabName) async {
  final url = 'https://docs.google.com/spreadsheets/d/$sheetId/gviz/tq?tqx=out:csv&sheet=${Uri.encodeComponent(tabName)}';
  try {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) {
      print('Status: 200');
      print('Body Length: ${res.body.length}');
      final lines = LineSplitter.split(res.body).toList();
      print('Lines count: ${lines.length}');
      print('TAB: $tabName');
      for (int i = 0; i < lines.length && i < 30; i++) {
        print('ROW $i: ${lines[i]}');
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}

void main() async {
  const id = '1fz4l1IepOSKtdPNiRqrtfdKUlIJuq54TzJdxAdEl-ho';
  await checkTab(id, 'historico_poblacional');
}
