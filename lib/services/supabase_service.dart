import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/nido.dart';
import '../models/monitoreo_reproduccion.dart';
import '../models/censo.dart';
import '../models/historico_poblacional.dart';
import '../models/reproduccion_resumen.dart';
import '../models/reproduccion_tasas.dart';
import '../models/censo_resumen.dart';
import '../models/metadata_row.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // ── Helpers ────────────────────────────────────────────────────────────────
  
  Map<String, String> _convertMap(Map<String, dynamic> row) {
    return row.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  Future<List<Nido>> getNidos() async {
    final response = await _client.from('nidos').select().order('created_at');
    return response.map((row) => Nido.fromMap(_convertMap(row))).toList();
  }

  Future<List<MonitoreoReproduccion>> getMonitoreo() async {
    final response = await _client.from('monitoreo_reproduccion').select().order('created_at');
    return response.map((row) => MonitoreoReproduccion.fromMap(_convertMap(row))).toList();
  }

  Future<List<Censo>> getCenso() async {
    final response = await _client.from('censo').select().order('created_at');
    return response.map((row) => Censo.fromMap(_convertMap(row))).toList();
  }

  Future<List<HistoricoPoblacional>> getHistorico() async {
    final response = await _client.from('historico_poblacional').select().order('created_at');
    return response.map((row) => HistoricoPoblacional.fromMap(_convertMap(row))).toList();
  }

  Future<List<ReproduccionResumen>> getReproduccionResumen() async {
    try {
      final response = await _client.from('reproduccion_resumen').select();
      return response.map((row) => ReproduccionResumen.fromMap(_convertMap(row))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<ReproduccionTasas>> getReproduccionTasas() async {
    try {
      final response = await _client.from('reproduccion_tasas').select();
      return response.map((row) => ReproduccionTasas.fromMap(_convertMap(row))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<CensoResumen>> getCensoResumen() async {
    try {
      final response = await _client.from('censo_resumen').select();
      return response.map((row) => CensoResumen.fromMap(_convertMap(row))).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<MetadataRow>> getMetadata(String tableName) async {
    try {
      final response = await _client.from(tableName).select();
      // Filtrar filas donde 'campo' esté vacío (al igual que antes)
      return response
          .map((row) => MetadataRow.fromMap(_convertMap(row)))
          .where((m) => m.campo.isNotEmpty && m.campo.toLowerCase() != 'campo')
          .toList();
    } catch (e) {
      print('Error fetching metadata from $tableName: $e');
      return [];
    }
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<bool> addNido(Nido nido) async {
    try {
      // Create map from headers and row
      final headers = Nido.headers;
      final row = nido.toRow();
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i];
      }
      await _client.from('nidos').insert(map);
      return true;
    } catch (e) {
      print('Supabase addNido error: $e');
      return false;
    }
  }

  Future<bool> addMonitoreo(MonitoreoReproduccion item) async {
    try {
      final headers = MonitoreoReproduccion.headers;
      final row = item.toRow();
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i];
      }
      await _client.from('monitoreo_reproduccion').insert(map);
      return true;
    } catch (e) {
      print('Supabase addMonitoreo error: $e');
      return false;
    }
  }

  Future<bool> addCenso(Censo item) async {
    try {
      final headers = Censo.headers;
      final row = item.toRow();
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i];
      }
      await _client.from('censo').insert(map);
      return true;
    } catch (e) {
      print('Supabase addCenso error: $e');
      return false;
    }
  }

  Future<bool> addHistorico(HistoricoPoblacional item) async {
    try {
      final headers = HistoricoPoblacional.headers;
      final row = item.toRow();
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i];
      }
      await _client.from('historico_poblacional').insert(map);
      return true;
    } catch (e) {
      print('Supabase addHistorico error: $e');
      return false;
    }
  }

  // Update operations (using id_nido for nidos, since we don't have row IDs locally. 
  // For the others, we might need a unique key to update, or just delete and insert if it's simpler.
  // Assuming id_nido is PK for nidos.
  Future<bool> updateNido(Nido nido) async {
    try {
      final headers = Nido.headers;
      final row = nido.toRow();
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i];
      }
      await _client.from('nidos').update(map).eq('id_nido', nido.idNido);
      return true;
    } catch (e) {
      print('Supabase updateNido error: $e');
      return false;
    }
  }

  // For Monitoreo, Censo, and Historico, we need a way to identify rows. 
  // In the old sheets, we used the array index. In Supabase, if we don't fetch the DB `id` column, 
  // we can update by a composite unique key.
  
  Future<bool> updateMonitoreo(MonitoreoReproduccion item, MonitoreoReproduccion oldItem) async {
    try {
      final headers = MonitoreoReproduccion.headers;
      final row = item.toRow();
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i];
      }
      await _client.from('monitoreo_reproduccion')
          .update(map)
          .eq('id_nido', oldItem.idNido)
          .eq('ano', oldItem.ano);
      return true;
    } catch (e) {
      print('Supabase updateMonitoreo error: $e');
      return false;
    }
  }

  Future<bool> updateCenso(Censo item, Censo oldItem) async {
    try {
      final headers = Censo.headers;
      final row = item.toRow();
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i];
      }
      await _client.from('censo')
          .update(map)
          .eq('localidad', oldItem.localidad)
          .eq('ano', oldItem.ano)
          .eq('mes', oldItem.mes)
          .eq('dia', oldItem.dia);
      return true;
    } catch (e) {
      print('Supabase updateCenso error: $e');
      return false;
    }
  }

  Future<bool> updateHistorico(HistoricoPoblacional item, HistoricoPoblacional oldItem) async {
    try {
      final headers = HistoricoPoblacional.headers;
      final row = item.toRow();
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i];
      }
      await _client.from('historico_poblacional')
          .update(map)
          .eq('ano', oldItem.ano);
      return true;
    } catch (e) {
      print('Supabase updateHistorico error: $e');
      return false;
    }
  }

  Future<bool> updateReproduccionResumen(ReproduccionResumen item, ReproduccionResumen oldItem) async {
    try {
      final headers = ReproduccionResumen.headers;
      final row = item.toRow();
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i];
      }
      await _client.from('reproduccion_resumen')
          .update(map)
          .eq('id_nido', oldItem.idNido)
          .eq('ano', oldItem.ano);
      return true;
    } catch (e) {
      print('Supabase updateReproduccionResumen error: $e');
      return false;
    }
  }

  Future<bool> updateReproduccionTasas(ReproduccionTasas item, ReproduccionTasas oldItem) async {
    try {
      final headers = ReproduccionTasas.headers;
      final row = item.toRow();
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i];
      }
      await _client.from('reproduccion_tasas')
          .update(map)
          .eq('ano', oldItem.ano);
      return true;
    } catch (e) {
      print('Supabase updateReproduccionTasas error: $e');
      return false;
    }
  }

  Future<bool> updateCensoResumen(CensoResumen item, CensoResumen oldItem) async {
    try {
      final headers = CensoResumen.headers;
      final row = item.toRow();
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i];
      }
      await _client.from('censo_resumen')
          .update(map)
          .eq('localidad', oldItem.localidad)
          .eq('ano', oldItem.ano);
      return true;
    } catch (e) {
      print('Supabase updateCensoResumen error: $e');
      return false;
    }
  }

  Future<bool> updateMetadata(String tableName, MetadataRow item, MetadataRow oldItem) async {
    try {
      final headers = MetadataRow.headers;
      final row = item.toRow();
      final map = <String, dynamic>{};
      for (int i = 0; i < headers.length; i++) {
        map[headers[i]] = row[i];
      }
      await _client.from(tableName)
          .update(map)
          .eq('campo', oldItem.campo);
      return true;
    } catch (e) {
      print('Supabase updateMetadata error: $e');
      return false;
    }
  }
}
