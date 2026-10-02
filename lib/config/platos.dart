/// Disposicion de los platos de la tolva: el plato 1 es el enganche y
/// los platos 2..9 son 4 juegos de celdas izq/der (J1 = 2/3 ... J4 = 8/9).
const int cantidadPlatos = 9;

/// Nombre de cada plato: el indice 0 es el plato 1.
const List<String> nombresPlatos = [
  'ENGANCHE',
  'J1 IZQ',
  'J1 DER',
  'J2 IZQ',
  'J2 DER',
  'J3 IZQ',
  'J3 DER',
  'J4 IZQ',
  'J4 DER',
];

/// Nombre del plato [plato] (1..cantidadPlatos).
String nombrePlato(int plato) => nombresPlatos[plato - 1];
