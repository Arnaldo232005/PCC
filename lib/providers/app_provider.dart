import 'package:flutter/foundation.dart';
import '../models/nido.dart';
import '../models/monitoreo_reproduccion.dart';
import '../models/censo.dart';
import '../models/historico_poblacional.dart';
import '../models/reproduccion_resumen.dart';
import '../models/reproduccion_tasas.dart';
import '../models/censo_resumen.dart';
import '../models/metadata_row.dart';
import '../services/supabase_service.dart';

enum AppStatus { idle, loading, error, ready }

class AppProvider extends ChangeNotifier {
  final _supabaseService = SupabaseService();

  AppStatus _status = AppStatus.idle;
  String _statusMessage = '';

  List<Nido> nidos = [];
  List<MonitoreoReproduccion> monitoreo = [];
  List<Censo> censo = [];
  List<HistoricoPoblacional> historico = [];

  List<ReproduccionResumen> reproduccionResumen = [];
  List<ReproduccionTasas> reproduccionTasas = [];
  List<CensoResumen> censoResumen = [];

  Map<String, List<MetadataRow>> metadata = {};

  AppStatus get status => _status;
  String get statusMessage => _statusMessage;
  bool get isConnected => true; 
  bool get hasWriteAccess => true;

  AppProvider() {
    loadAllData(loadMetadata: true);
  }

  Future<void> loadAllData({bool loadMetadata = false}) async {
    _setStatus(AppStatus.loading, 'Cargando datos...');
    try {
      final futures = [
        _supabaseService.getNidos(),
        _supabaseService.getMonitoreo(),
        _supabaseService.getCenso(),
        _supabaseService.getHistorico(),
        _supabaseService.getReproduccionResumen(),
        _supabaseService.getReproduccionTasas(),
        _supabaseService.getCensoResumen(),
      ];

      if (loadMetadata || metadata.isEmpty) {
        futures.addAll([
          _supabaseService.getMetadata('metadata_reproduccion'),
          _supabaseService.getMetadata('metadata_nidos'),
          _supabaseService.getMetadata('metadata_censo'),
          _supabaseService.getMetadata('metadata_historico'),
          _supabaseService.getMetadata('metadata_tasas_anuales'),
        ]);
      }

      final results = await Future.wait(futures);

      nidos     = results[0] as List<Nido>;
      monitoreo = results[1] as List<MonitoreoReproduccion>;
      censo     = results[2] as List<Censo>;
      historico = results[3] as List<HistoricoPoblacional>;
      historico.sort((a, b) => a.anoInt.compareTo(b.anoInt));

      reproduccionResumen = results[4] as List<ReproduccionResumen>;
      reproduccionTasas = results[5] as List<ReproduccionTasas>;
      censoResumen = results[6] as List<CensoResumen>;

      if (results.length > 7) {
        metadata['reproduccion'] = results[7] as List<MetadataRow>;
        metadata['nidos'] = results[8] as List<MetadataRow>;
        metadata['censo'] = results[9] as List<MetadataRow>;
        metadata['historico'] = results[10] as List<MetadataRow>;
        metadata['tasas_anuales'] = results[11] as List<MetadataRow>;
      }

      _setStatus(AppStatus.ready, 'Datos actualizados');
    } catch (e) {
      _setStatus(AppStatus.error, 'Error: $e');
    }
  }

  void _setStatus(AppStatus s, String msg) {
    _status = s;
    _statusMessage = msg;
    notifyListeners();
  }

  // --- Escritura Optimizada ---

  Future<bool> addNido(Nido nido) async {
    final success = await _supabaseService.addNido(nido);
    if (success) {
      nidos.add(nido); // Actualización local instantánea
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateNido(int index, Nido nido) async {
    final success = await _supabaseService.updateNido(nido);
    if (success) {
      nidos[index] = nido; // Actualización local instantánea
      notifyListeners();
    }
    return success;
  }

  Future<bool> addMonitoreo(MonitoreoReproduccion item) async {
    final success = await _supabaseService.addMonitoreo(item);
    if (success) {
      monitoreo.add(item);
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateMonitoreo(int index, MonitoreoReproduccion item) async {
    final oldItem = monitoreo[index];
    final success = await _supabaseService.updateMonitoreo(item, oldItem);
    if (success) {
      monitoreo[index] = item;
      notifyListeners();
    }
    return success;
  }

  Future<bool> addCenso(Censo item) async {
    final success = await _supabaseService.addCenso(item);
    if (success) {
      censo.add(item);
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateCenso(int index, Censo item) async {
    final oldItem = censo[index];
    final success = await _supabaseService.updateCenso(item, oldItem);
    if (success) {
      censo[index] = item;
      notifyListeners();
    }
    return success;
  }

  Future<bool> addHistorico(HistoricoPoblacional item) async {
    final success = await _supabaseService.addHistorico(item);
    if (success) {
      historico.add(item);
      historico.sort((a, b) => a.anoInt.compareTo(b.anoInt));
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateHistorico(int index, HistoricoPoblacional item) async {
    final oldItem = historico[index];
    final success = await _supabaseService.updateHistorico(item, oldItem);
    if (success) {
      historico[index] = item;
      historico.sort((a, b) => a.anoInt.compareTo(b.anoInt));
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateReproduccionResumen(int index, ReproduccionResumen item) async {
    final oldItem = reproduccionResumen[index];
    final success = await _supabaseService.updateReproduccionResumen(item, oldItem);
    if (success) {
      reproduccionResumen[index] = item;
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateReproduccionTasas(int index, ReproduccionTasas item) async {
    final oldItem = reproduccionTasas[index];
    final success = await _supabaseService.updateReproduccionTasas(item, oldItem);
    if (success) {
      reproduccionTasas[index] = item;
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateCensoResumen(int index, CensoResumen item) async {
    final oldItem = censoResumen[index];
    final success = await _supabaseService.updateCensoResumen(item, oldItem);
    if (success) {
      censoResumen[index] = item;
      notifyListeners();
    }
    return success;
  }

  Future<bool> updateMetadataRow(String key, int index, MetadataRow item) async {
    final oldItem = metadata[key]![index];
    final tableName = 'metadata_$key';
    final success = await _supabaseService.updateMetadata(tableName, item, oldItem);
    if (success) {
      metadata[key]![index] = item;
      notifyListeners();
    }
    return success;
  }

  int get totalNidos => nidos.length;
  int get totalMonitoreo => monitoreo.length;
  int get totalCenso => censo.length;

  double get lastHistoricoTotal =>
      historico.isEmpty ? 0 : historico.last.totalDouble;

  String get lastHistoricoAno =>
      historico.isEmpty ? '-' : historico.last.ano;
}
