import 'package:http/http.dart' as http;

void main() async {
  final url = 'https://docs.google.com/spreadsheets/d/1fz4l1IepOSKtdPNiRqrtfdKUlIJuq54TzJdxAdEl-ho/edit';
  final res = await http.get(Uri.parse(url));
  final body = res.body;

  // Google Sheets HTML usually contains a Javascript object with the sheet names and GIDs
  // something like: [..., "sheetName", ..., "gid", ...] or similar.
  // We can regex search for the tab names.
  final tabs = ['nidos', 'reproduccion_monitoreo', 'censo_monitoreo', 'historico_tamano_poblacional', 'reproduccion_resumen_anual', 'reproduccion_tasas_anuales', 'censo_resumen_anual', 'metadata_reproduccion', 'metadata_nidos', 'metadata_censo', 'metadata_historico', 'metadata_tasas_anuales'];

  for (final tab in tabs) {
    final regex = RegExp(r'\["' + tab + r'".*?(\d+)\]');
    final match = regex.firstMatch(body);
    if (match != null) {
      print('$tab: ${match.group(1)}');
    } else {
      // Let's try another pattern
      final regex2 = RegExp(tab + r'".*?\[(\d+)\]');
      final match2 = regex2.firstMatch(body);
      if (match2 != null) {
        print('$tab: ${match2.group(1)} (pattern 2)');
      } else {
         // Let's just search the string and print a context window
         final index = body.indexOf('"' + tab + '"');
         if (index != -1) {
             print('$tab context: ${body.substring(index, index + 100)}');
         } else {
             print('$tab: NOT FOUND');
         }
      }
    }
  }
}
