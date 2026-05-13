class Censo {
  final String ano;
  final String mes;
  final String dia;
  final String localidad;
  final String latitud;
  final String longitud;
  final String nIndividuos;
  final String nObservadores;
  final String horaInicio;
  final String horaFin;
  final String elevacionM;
  final String errorObservacion;
  final String clima;
  final String humedad;
  final String viento;
  final String aguilaPresente;

  const Censo({
    required this.ano,
    this.mes = '',
    this.dia = '',
    required this.localidad,
    this.latitud = '',
    this.longitud = '',
    required this.nIndividuos,
    this.nObservadores = '',
    this.horaInicio = '',
    this.horaFin = '',
    this.elevacionM = '',
    this.errorObservacion = '',
    this.clima = '',
    this.humedad = '',
    this.viento = '',
    this.aguilaPresente = '',
  });

  factory Censo.fromMap(Map<String, dynamic> m) => Censo(
        ano: m['año']?.toString() ?? m['ano']?.toString() ?? '',
        mes: m['mes']?.toString() ?? '',
        dia: m['dia']?.toString() ?? '',
        localidad: m['localidad']?.toString() ?? '',
        latitud: m['latitud']?.toString() ?? '',
        longitud: m['longitud']?.toString() ?? '',
        nIndividuos: m['n_individuos']?.toString() ?? '',
        nObservadores: m['n_observadores']?.toString() ?? '',
        horaInicio: m['hora_inicio']?.toString() ?? '',
        horaFin: m['hora_fin']?.toString() ?? '',
        elevacionM: m['elevacion_m']?.toString() ?? '',
        errorObservacion: m['error_observacion']?.toString() ?? '',
        clima: m['clima']?.toString() ?? '',
        humedad: m['humedad']?.toString() ?? '',
        viento: m['viento']?.toString() ?? '',
        aguilaPresente: m['aguila_presente']?.toString() ?? '',
      );

  List<String> toRow() => [
        ano, mes, dia, localidad, latitud, longitud, nIndividuos,
        nObservadores, horaInicio, horaFin, elevacionM, errorObservacion,
        clima, humedad, viento, aguilaPresente,
      ];

  static List<String> get headers => [
        'año', 'mes', 'dia', 'localidad', 'latitud', 'longitud', 'n_individuos',
        'n_observadores', 'hora_inicio', 'hora_fin', 'elevacion_m', 'error_observacion',
        'clima', 'humedad', 'viento', 'aguila_presente',
      ];

  String get uniqueKey => '${ano}_${mes}_${dia}_$localidad';
}
