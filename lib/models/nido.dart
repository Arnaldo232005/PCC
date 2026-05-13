class Nido {
  final String idNido;
  final String nombreNido;
  final String localidad;
  final String latitudI;
  final String longitudI;
  final String latitudO;
  final String longitudO;
  final String profundidadHorizontal;
  final String profundidadVertical;
  final String alturaEntrada;
  final String diametro;
  final String elevacionM;
  final String materialNido;
  final String arbolEspecie;
  final String dapCm;
  final String estatus;
  final String direccionEntrada;
  final String observacionesNido;

  const Nido({
    required this.idNido,
    this.nombreNido = '',
    required this.localidad,
    this.latitudI = '',
    this.longitudI = '',
    this.latitudO = '',
    this.longitudO = '',
    this.profundidadHorizontal = '',
    this.profundidadVertical = '',
    this.alturaEntrada = '',
    this.diametro = '',
    this.elevacionM = '',
    this.materialNido = '',
    this.arbolEspecie = '',
    this.dapCm = '',
    this.estatus = '',
    this.direccionEntrada = '',
    this.observacionesNido = '',
  });

  factory Nido.fromMap(Map<String, dynamic> m) => Nido(
        idNido: m['id_nido']?.toString() ?? '',
        nombreNido: m['nombre_nido']?.toString() ?? '',
        localidad: m['localidad']?.toString() ?? '',
        latitudI: m['latitud_i']?.toString() ?? '',
        longitudI: m['longitud_i']?.toString() ?? '',
        latitudO: m['latitud_o']?.toString() ?? '',
        longitudO: m['longitud_o']?.toString() ?? '',
        profundidadHorizontal: m['profundidad_horizontal']?.toString() ?? '',
        profundidadVertical: m['profundidad_vertical']?.toString() ?? '',
        alturaEntrada: m['altura_entrada']?.toString() ?? '',
        diametro: m['diametro']?.toString() ?? '',
        elevacionM: m['elevacion_m']?.toString() ?? '',
        materialNido: m['material_nido']?.toString() ?? '',
        arbolEspecie: m['arbol_especie']?.toString() ?? '',
        dapCm: m['dap_cm']?.toString() ?? '',
        estatus: m['estatus']?.toString() ?? '',
        direccionEntrada: m['direccion_entrada']?.toString() ?? '',
        observacionesNido: m['observaciones_nido']?.toString() ?? '',
      );

  List<String> toRow() => [
        idNido, nombreNido, localidad, latitudI, longitudI, latitudO, longitudO,
        profundidadHorizontal, profundidadVertical, alturaEntrada, diametro,
        elevacionM, materialNido, arbolEspecie, dapCm, estatus, direccionEntrada,
        observacionesNido,
      ];

  static List<String> get headers => [
        'id_nido', 'nombre_nido', 'localidad', 'latitud_i', 'longitud_i', 'latitud_o',
        'longitud_o', 'profundidad_horizontal', 'profundidad_vertical', 'altura_entrada',
        'diametro', 'elevacion_m', 'material_nido', 'arbol_especie', 'dap_cm', 'estatus',
        'direccion_entrada', 'observaciones_nido',
      ];
}
