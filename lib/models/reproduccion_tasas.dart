class ReproduccionTasas {
  final String ano;
  final String promedioTasaEclosion;
  final String promedioTasaSaqueo;
  final String promedioTasaDepredacion;
  final String promedioExitoReproductivo;
  final String promedioProductividadNido;

  const ReproduccionTasas({
    required this.ano,
    this.promedioTasaEclosion = '',
    this.promedioTasaSaqueo = '',
    this.promedioTasaDepredacion = '',
    this.promedioExitoReproductivo = '',
    this.promedioProductividadNido = '',
  });

  factory ReproduccionTasas.fromMap(Map<String, dynamic> m) => ReproduccionTasas(
        ano: m['año']?.toString() ?? m['ano']?.toString() ?? '',
        promedioTasaEclosion: m['promedio_tasa_eclosion']?.toString() ?? '',
        promedioTasaSaqueo: m['promedio_tasa_saqueo']?.toString() ?? '',
        promedioTasaDepredacion: m['promedio_tasa_depredacion']?.toString() ?? '',
        promedioExitoReproductivo: m['promedio_exito_reproductivo']?.toString() ?? '',
        promedioProductividadNido: m['promedio_productividad_nido']?.toString() ?? '',
      );

  List<String> toRow() => [
        ano, promedioTasaEclosion, promedioTasaSaqueo, promedioTasaDepredacion,
        promedioExitoReproductivo, promedioProductividadNido,
      ];
  static List<String> get headers => [
        'año', 'promedio_tasa_eclosion', 'promedio_tasa_saqueo', 'promedio_tasa_depredacion',
        'promedio_exito_reproductivo', 'promedio_productividad_nido',
      ];
}
