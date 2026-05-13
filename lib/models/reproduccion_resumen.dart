class ReproduccionResumen {
  final String idNido;
  final String nombreNido;
  final String localidad;
  final String ano;
  final String nidosActivos;
  final String huevosTotales;
  final String huevosEclosionados;
  final String pichonesNaturalesTotal;
  final String pichonesSaqueados;
  final String pichonesDepredadosMuertos;
  final String volantonesIntroducidos;
  final String volantonesTotales;
  final String tasaEclosion;
  final String tasaSaqueo;
  final String tasaDepredacionMuertes;
  final String exitoReproductivo;
  final String productividadPareja;
  final String productividadPorNido;

  const ReproduccionResumen({
    required this.idNido,
    this.nombreNido = '',
    this.localidad = '',
    this.ano = '',
    this.nidosActivos = '',
    this.huevosTotales = '',
    this.huevosEclosionados = '',
    this.pichonesNaturalesTotal = '',
    this.pichonesSaqueados = '',
    this.pichonesDepredadosMuertos = '',
    this.volantonesIntroducidos = '',
    this.volantonesTotales = '',
    this.tasaEclosion = '',
    this.tasaSaqueo = '',
    this.tasaDepredacionMuertes = '',
    this.exitoReproductivo = '',
    this.productividadPareja = '',
    this.productividadPorNido = '',
  });

  factory ReproduccionResumen.fromMap(Map<String, dynamic> m) => ReproduccionResumen(
        idNido: m['id_nido']?.toString() ?? '',
        nombreNido: m['nombre_nido']?.toString() ?? '',
        localidad: m['localidad']?.toString() ?? '',
        ano: m['año']?.toString() ?? m['ano']?.toString() ?? '',
        nidosActivos: m['nidos_activos']?.toString() ?? '',
        huevosTotales: m['huevos_totales']?.toString() ?? '',
        huevosEclosionados: m['huevos_eclosionados']?.toString() ?? '',
        pichonesNaturalesTotal: m['pichones_naturales_total']?.toString() ?? '',
        pichonesSaqueados: m['pichones_saqueados_total']?.toString() ?? m['pichones_saqueados']?.toString() ?? '',
        pichonesDepredadosMuertos: m['pichones_depredados_muertos']?.toString() ?? '',
        volantonesIntroducidos: m['volantones_introducidos']?.toString() ?? '',
        volantonesTotales: m['volantones_totales']?.toString() ?? '',
        tasaEclosion: m['tasa_eclosion']?.toString() ?? '',
        tasaSaqueo: m['tasa_saqueo']?.toString() ?? '',
        tasaDepredacionMuertes: m['tasa_depredacion_muertes']?.toString() ?? '',
        exitoReproductivo: m['exito_reproducitivo']?.toString() ?? m['exito_reproductivo']?.toString() ?? '',
        productividadPareja: m['productividad_pareja']?.toString() ?? '',
        productividadPorNido: m['productividad_por_nido']?.toString() ?? '',
      );

  List<String> toRow() => [
        idNido, nombreNido, localidad, ano, nidosActivos, huevosTotales,
        huevosEclosionados, pichonesNaturalesTotal, pichonesSaqueados,
        pichonesDepredadosMuertos, volantonesIntroducidos, volantonesTotales,
        tasaEclosion, tasaSaqueo, tasaDepredacionMuertes, exitoReproductivo,
        productividadPareja, productividadPorNido,
      ];

  static List<String> get headers => [
        'id_nido', 'nombre_nido', 'localidad', 'año', 'nidos_activos', 'huevos_totales',
        'huevos_eclosionados', 'pichones_naturales_total', 'pichones_saqueados_total',
        'pichones_depredados_muertos', 'volantones_introducidos', 'volantones_totales',
        'tasa_eclosion', 'tasa_saqueo', 'tasa_depredacion_muertes', 'exito_reproducitivo',
        'productividad_pareja', 'productividad_por_nido',
      ];
}
