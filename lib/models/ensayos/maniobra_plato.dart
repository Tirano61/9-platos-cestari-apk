/// Estado de una celda contra su capacidad nominal.
enum EstadoCelda {
  normal('NORMAL'),
  alLimite('AL LÍMITE'),
  excede('EXCEDE'),
  /// Sin capacidad cargada o sin peso valido.
  sinDato('-');

  const EstadoCelda(this.texto);

  /// Texto que se muestra en la tabla.
  final String texto;
}

/// % de [capacidad] que representa [peso], redondeado a 1 decimal (como se
/// muestra). null si la capacidad esta vacia o es <= 0, o si el peso es invalido.
double? porcentajeCapacidad(String peso, String capacidad) {
  final valor = double.tryParse(peso);
  final cap = double.tryParse(capacidad);
  if (valor == null || cap == null || cap <= 0) return null;
  // Se compara con el valor redondeado, asi el estado coincide con el % que se ve.
  return double.parse((valor * 100 / cap).toStringAsFixed(1));
}

/// `excede` si el % de la capacidad es > 100, `alLimite` si es >= [umbral],
/// `normal` si no, y `sinDato` sin capacidad. Con un umbral invalido solo se
/// distingue `excede` de `normal`.
EstadoCelda estadoCelda({
  required String peso,
  required String capacidad,
  required String umbral,
}) {
  final por = porcentajeCapacidad(peso, capacidad);
  if (por == null) return EstadoCelda.sinDato;
  if (por > 100) return EstadoCelda.excede;
  final limite = double.tryParse(umbral);
  if (limite != null && por >= limite) return EstadoCelda.alLimite;
  return EstadoCelda.normal;
}

/// Resultado de un plato en una maniobra.
class ManiobraPlato {
  const ManiobraPlato({
    required this.plato,
    required this.estatico,
    required this.maximo,
    required this.minimo,
    required this.lecturas,
    required this.capacidad,
  });

  /// Fila de tmaniobras_platos (sin maniobra_id, lo pone la base).
  factory ManiobraPlato.fromDb(Map<String, dynamic> row) => ManiobraPlato(
        plato: row['plato'] as int,
        estatico: (row['estatico'] ?? '').toString(),
        maximo: (row['maximo'] ?? '').toString(),
        minimo: (row['minimo'] ?? '').toString(),
        lecturas: (row['lecturas'] as int?) ?? 0,
        capacidad: (row['capacidad'] ?? '').toString(),
      );

  Map<String, dynamic> toDb() => {
        'plato': plato,
        'estatico': estatico,
        'maximo': maximo,
        'minimo': minimo,
        'lecturas': lecturas,
        'capacidad': capacidad,
      };

  /// Numero de plato (1..9).
  final int plato;

  /// Pesos con 2 decimales. [maximo] y [minimo] quedan `''` si el plato no
  /// mando ningun peso durante la maniobra.
  final String estatico;
  final String maximo;
  final String minimo;

  /// Cantidad de pesos recibidos durante la maniobra.
  final int lecturas;

  /// Capacidad nominal en kg usada en la maniobra (`''` = sin capacidad).
  final String capacidad;

  /// Maximo / estatico con 2 decimales; `-` si el estatico es <= 0 o no hay maximo.
  String get factorCresta {
    final est = double.tryParse(estatico);
    final max = double.tryParse(maximo);
    if (est == null || est <= 0 || max == null) return '-';
    return (max / est).toStringAsFixed(2);
  }

  /// Maximo como % de la capacidad, con 1 decimal; `-` sin capacidad.
  String get porCapacidad => porcentajeCapacidad(maximo, capacidad)?.toStringAsFixed(1) ?? '-';

  /// Estado del maximo contra la capacidad y el [umbral] (%).
  EstadoCelda estado(String umbral) =>
      estadoCelda(peso: maximo, capacidad: capacidad, umbral: umbral);
}
