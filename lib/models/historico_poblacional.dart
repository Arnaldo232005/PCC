class HistoricoPoblacional {
  final String ano;
  final String tamanoPoblacionalEstimado;
  final String volantonesNidosNaturales;
  final String volantonesNidosArtificiales;
  final String volantonesTotales;
  final String intervencion1;
  final String intervencion2;
  final String intervencion3;
  final String intervencion4;
  final String intervencion5;
  final String saqueo;

  const HistoricoPoblacional({
    required this.ano,
    this.tamanoPoblacionalEstimado = '',
    this.volantonesNidosNaturales = '',
    this.volantonesNidosArtificiales = '',
    this.volantonesTotales = '',
    this.intervencion1 = '',
    this.intervencion2 = '',
    this.intervencion3 = '',
    this.intervencion4 = '',
    this.intervencion5 = '',
    this.saqueo = '',
  });

  factory HistoricoPoblacional.fromMap(Map<String, dynamic> m) =>
      HistoricoPoblacional(
        ano: m['año']?.toString() ?? m['ano']?.toString() ?? '',
        tamanoPoblacionalEstimado: m['tamaño_poblaciol_estimado']?.toString() ?? m['tamano_poblacional_estimado']?.toString() ?? '',
        volantonesNidosNaturales: m['volantones_nidos_turales']?.toString() ?? m['volantones_nidos_naturales']?.toString() ?? '',
        volantonesNidosArtificiales: m['volantones_nidos_artificiales']?.toString() ?? '',
        volantonesTotales: m['volantones_totales']?.toString() ?? m['n_volantones_total']?.toString() ?? m['volantones']?.toString() ?? '',
        intervencion1: m['intervencion_1']?.toString() ?? '',
        intervencion2: m['intervencion_2']?.toString() ?? '',
        intervencion3: m['intervencion_3']?.toString() ?? '',
        intervencion4: m['intervencion_4']?.toString() ?? '',
        intervencion5: m['intervencion_5']?.toString() ?? '',
        saqueo: m['saqueo']?.toString() ?? '',
      );

  List<String> toRow() => [
        ano, tamanoPoblacionalEstimado, volantonesNidosNaturales,
        volantonesNidosArtificiales, volantonesTotales, intervencion1,
        intervencion2, intervencion3, intervencion4, intervencion5, saqueo,
      ];

  static List<String> get headers => [
        'año', 'tamaño_poblaciol_estimado', 'volantones_nidos_turales',
        'volantones_nidos_artificiales', 'volantones_totales', 'intervencion_1',
        'intervencion_2', 'intervencion_3', 'intervencion_4', 'intervencion_5', 'saqueo'
      ];

  int get anoInt => int.tryParse(ano) ?? 0;
  double get totalDouble => double.tryParse(volantonesTotales) ?? 0;
}
