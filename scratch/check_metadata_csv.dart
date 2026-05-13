import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = 'https://docs.google.com/spreadsheets/d/1fz4l1IepOSKtdPNiRqrtfdKUlIJuq54TzJdxAdEl-ho/gviz/tq?tqx=out:csv&sheet=metadata_nidos&headers=1';
  final res = await http.get(Uri.parse(url));
  final lines = LineSplitter.split(res.body).toList();
  for (int i=0; i<3 && i<lines.length; i++) {
    print(lines[i]);
  }
}
