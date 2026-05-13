class CensoResumen {
  final String localidad;
  final String ano;
  final String nCensos;
  final String totalIndividuos;
  final String promedioIndividuos;
  final String maxIndividuos;

  const CensoResumen({
    required this.localidad,
    required this.ano,
    this.nCensos = '',
    this.totalIndividuos = '',
    this.promedioIndividuos = '',
    this.maxIndividuos = '',
  });

  factory CensoResumen.fromMap(Map<String, dynamic> m) => CensoResumen(
        localidad: m['localidad']?.toString() ?? '',
        ano: m['año']?.toString() ?? m['ano']?.toString() ?? '',
        nCensos: m['n_censos']?.toString() ?? '',
        totalIndividuos: m['total_individuos']?.toString() ?? '',
        promedioIndividuos: m['promedio_individuos']?.toString() ?? '',
        maxIndividuos: m['max_individuos']?.toString() ?? '',
      );

  List<String> toRow() => [localidad, ano, nCensos, totalIndividuos, promedioIndividuos, maxIndividuos];
  static List<String> get headers => ['localidad', 'año', 'n_censos', 'total_individuos', 'promedio_individuos', 'max_individuos'];
}
