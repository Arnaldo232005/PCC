class MonitoreoReproduccion {
  final String idNido;
  final String nombreNido;
  final String localidad;
  final String ano;
  final String fechaMonitoreo;
  final String huevosNaturalesTotal;
  final String nidoActivo;
  final String huevosEclosionados;
  final String huevosDepredados;
  final String huevosDestruidos;
  final String huevosInfertiles;
  final String pichonesNaturalesTotal;
  final String pichonesSaqueados;
  final String pichonesDepredados;
  final String polluelosMuertos;
  final String volantonesNaturales;
  final String volantonesIntroducidos;
  final String volantonesTotal;
  final String pichonesTrasladados;
  final String depredador;
  final String observaciones;

  const MonitoreoReproduccion({
    required this.idNido,
    this.nombreNido = '',
    required this.localidad,
    required this.ano,
    this.fechaMonitoreo = '',
    this.huevosNaturalesTotal = '',
    this.nidoActivo = '',
    this.huevosEclosionados = '',
    this.huevosDepredados = '',
    this.huevosDestruidos = '',
    this.huevosInfertiles = '',
    this.pichonesNaturalesTotal = '',
    this.pichonesSaqueados = '',
    this.pichonesDepredados = '',
    this.polluelosMuertos = '',
    this.volantonesNaturales = '',
    this.volantonesIntroducidos = '',
    this.volantonesTotal = '',
    this.pichonesTrasladados = '',
    this.depredador = '',
    this.observaciones = '',
  });

  factory MonitoreoReproduccion.fromMap(Map<String, dynamic> m) =>
      MonitoreoReproduccion(
        idNido: m['id_nido']?.toString() ?? '',
        nombreNido: m['nombre_nido']?.toString() ?? '',
        localidad: m['localidad']?.toString() ?? '',
        ano: m['año']?.toString() ?? m['ano']?.toString() ?? '',
        fechaMonitoreo: m['fecha_monitoreo']?.toString() ?? '',
        huevosNaturalesTotal: m['huevos_turales_total']?.toString() ?? '',
        nidoActivo: m['nido_activo']?.toString() ?? '',
        huevosEclosionados: m['huevos_eclosiodos']?.toString() ?? '',
        huevosDepredados: m['huevos_depredados']?.toString() ?? '',
        huevosDestruidos: m['huevos_destruidos']?.toString() ?? '',
        huevosInfertiles: m['huevos_infertiles']?.toString() ?? '',
        pichonesNaturalesTotal: m['pichones_turales_total']?.toString() ?? '',
        pichonesSaqueados: m['pichones_saqueados']?.toString() ?? '',
        pichonesDepredados: m['pichones_depredados']?.toString() ?? '',
        polluelosMuertos: m['polluelos_muertos_causa_desconocida']?.toString() ?? '',
        volantonesNaturales: m['volantones_turales']?.toString() ?? '',
        volantonesIntroducidos: m['volantones_introducidos']?.toString() ?? '',
        volantonesTotal: m['volantones_total']?.toString() ?? '',
        pichonesTrasladados: m['pichones_trasladados']?.toString() ?? '',
        depredador: m['depredador']?.toString() ?? '',
        observaciones: m['observaciones']?.toString() ?? '',
      );

  List<String> toRow() => [
        idNido, nombreNido, localidad, ano, fechaMonitoreo, huevosNaturalesTotal,
        nidoActivo, huevosEclosionados, huevosDepredados, huevosDestruidos,
        huevosInfertiles, pichonesNaturalesTotal, pichonesSaqueados,
        pichonesDepredados, polluelosMuertos, volantonesNaturales,
        volantonesIntroducidos, volantonesTotal, pichonesTrasladados,
        depredador, observaciones,
      ];

  static List<String> get headers => [
        'id_nido', 'nombre_nido', 'localidad', 'año', 'fecha_monitoreo', 'huevos_turales_total',
        'nido_activo', 'huevos_eclosiodos', 'huevos_depredados', 'huevos_destruidos',
        'huevos_infertiles', 'pichones_turales_total', 'pichones_saqueados',
        'pichones_depredados', 'polluelos_muertos_causa_desconocida', 'volantones_turales',
        'volantones_introducidos', 'volantones_total', 'pichones_trasladados',
        'depredador', 'observaciones',
      ];

  String get uniqueKey => '${idNido}_$ano';
}
