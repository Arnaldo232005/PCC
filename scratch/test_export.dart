import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = 'https://docs.google.com/spreadsheets/d/1fz4l1IepOSKtdPNiRqrtfdKUlIJuq54TzJdxAdEl-ho/export?format=csv&gid=930102145';
  final res = await http.get(Uri.parse(url));
  print(res.body);
}
