class MetadataRow {
  final String campo;
  final String descripcion;
  final String tipoDato;
  final String valoresPermitidos;
  final String ejemplo;

  const MetadataRow({
    required this.campo,
    this.descripcion = '',
    this.tipoDato = '',
    this.valoresPermitidos = '',
    this.ejemplo = '',
  });

  factory MetadataRow.fromMap(Map<String, dynamic> m) => MetadataRow(
        campo: m['Campo']?.toString() ?? m['campo']?.toString() ?? '',
        descripcion: m['Descripción']?.toString() ?? m['descripcion']?.toString() ?? '',
        tipoDato: m['Tipo_Dato']?.toString() ?? m['tipo_dato']?.toString() ?? '',
        valoresPermitidos: m['Valores_Permitidos']?.toString() ?? m['valores_permitidos']?.toString() ?? '',
        ejemplo: m['Ejemplo']?.toString() ?? m['ejemplo']?.toString() ?? '',
      );

  List<String> toRow() => [campo, descripcion, tipoDato, valoresPermitidos, ejemplo];
  static List<String> get headers => ['Campo', 'Descripción', 'Tipo de Dato', 'Valores Permitidos', 'Ejemplo'];
}
