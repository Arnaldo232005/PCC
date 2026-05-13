import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const mainSheetId = '1fz4l1IepOSKtdPNiRqrtfdKUlIJuq54TzJdxAdEl-ho';
  final url = 'https://docs.google.com/spreadsheets/d/$mainSheetId/gviz/tq?tqx=out:csv&sheet=nidos';
  final res = await http.get(Uri.parse(url));
  final lines = LineSplitter.split(res.body).toList();
  print('nidos headers: ${lines.first}');
}
