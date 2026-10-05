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

/// Dibujo de la tolva vista desde arriba, con la lanza y el enganche arriba.
const String imagenTolva = 'assets/tolva.png';

/// Ancho / alto de [imagenTolva] (1000 x 2868 px).
const double proporcionTolva = 1000 / 2868;

/// Donde va el campo de cada plato sobre [imagenTolva], en fracciones del
/// ancho (x) y del alto (y) de la imagen. El indice 0 es el plato 1.
///
/// En el enganche y el lado izq el campo termina en x (queda a la izquierda);
/// en el lado der empieza en x (queda a la derecha). En y queda centrado.
/// Son una primera medida sobre el dibujo: se ajustan viendolas en el telefono.
const List<({double x, double y})> posicionesCeldas = [
  (x: 0.40, y: 0.12), // ENGANCHE, junto a la lanza
  (x: 0.20, y: 0.43), (x: 0.80, y: 0.43), // J1
  (x: 0.20, y: 0.57), (x: 0.80, y: 0.57), // J2
  (x: 0.20, y: 0.70), (x: 0.80, y: 0.70), // J3
  (x: 0.20, y: 0.84), (x: 0.80, y: 0.84), // J4
];

/// Posicion del campo del plato [plato] (1..cantidadPlatos) sobre [imagenTolva].
({double x, double y}) posicionCelda(int plato) => posicionesCeldas[plato - 1];

/// true en los platos del lado derecho (3, 5, 7, 9).
bool esLadoDerecho(int plato) => plato > 1 && plato.isOdd;
