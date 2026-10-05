# Plan: modo ensayo de tolva (Valija de Ensayo 9 Canales)

Plan escrito el 02/10/2026 a partir del anteproyecto *Valija de Ensayo 9 Canales* (Balanzas Hook, Sector Desarrollo).
Cada paso es una rama corta en camelCase que termina en un PR a `main`. Los commits van en español, en una línea.
Al cerrar cada PR se marca su casilla.

**Cómo usar este plan:** pedir "hacé el paso N de docs/plan_ensayo.md". Antes de implementarlo, se lee el paso y,
si hace falta, se cambia acá mismo. Cada paso deja la app compilando y usable.

## Contexto

La app ya recibe los 9 platos por WiFi UDP. Ahora se va a usar para **ensayar una tolva Cestari a campo**: ver cuánto
carga cada celda durante maniobras reales (marcha, giro, badén, pendiente, frenada). Hoy el indicador de la máquina
suma las 9 celdas y no puede mostrar el reparto entre ellas. La app solo guarda una foto de los 9 pesos, y con eso no
se ven los picos.

### Decisiones tomadas

- Se quitan el botón `< H >` y el comando `resethold`. Queda el `> 0 <` de cada plato y se agrega un **Cero general**.
- Se quitan el FAB **Guardar** y las **pesadas** (modelo, tablas, historial). Los reemplazan los **ensayos**.
- **Inicio del ensayo**: una pantalla pide la **identificación de la tolva** y la **capacidad nominal de cada celda**.
  Para cargar las capacidades se usa el dibujo `assets/tolva.png` (vista desde arriba, vertical), con un campo junto a
  cada celda. En la misma pantalla está el **umbral de alarma en %**, común a las 9.
- Las capacidades y el umbral se guardan en **SharedPreferences** (no en la base). En el próximo inicio de ensayo
  aparecen precargados, y el usuario los puede modificar.
- **Estático**: con la tolva parada, un botón toma los 9 pesos como referencia. Vale para todas las maniobras
  siguientes hasta que se vuelva a tomar. Cualquier cero lo borra, porque deja de ser válido.
- **Maniobra**: se habilita solo con un estático tomado. Mientras dura, cada peso que llega de cada plato se compara
  con el máximo y el mínimo anteriores. **No se guarda cada lectura.** Al terminar se guardan, por plato: estático,
  máximo, mínimo, cantidad de lecturas y la capacidad usada.
- Las maniobras se numeran solas dentro del ensayo (1, 2, 3…) y guardan su hora de inicio y fin.

### Cálculos por plato y maniobra

| Dato | Fórmula |
|---|---|
| Factor de cresta | máx ÷ estático (`-` si el estático es ≤ 0) |
| % cap. nominal | máx × 100 ÷ capacidad (`-` si la capacidad es 0 o está vacía) |
| Estado | `EXCEDE` si % > 100; `AL LÍMITE` si % ≥ umbral; `NORMAL` si no; `-` sin capacidad |

Ejemplo del documento: C2 con estático 2.410, máx. 5.980 y capacidad 5.000 da FC 2,48, 119,6 % y `EXCEDE`.

### Dibujo de la tolva (`assets/tolva.png`)

La imagen mide 1000 × 2868 px (proporción 0,349) y es una vista superior con la lanza y el enganche arriba. Las celdas
se ubican con **fracciones del ancho y del alto** de la imagen, para que el campo quede en su lugar con cualquier
tamaño de pantalla. Valores iniciales, medidos sobre el dibujo y a ajustar en el teléfono:

| Plato | Dónde está en el dibujo | x | y |
|---|---|---|---|
| 1 ENGANCHE | a la izquierda de la lanza, a la altura del recuadro chico (que está en x 0,46) | 0,40 | 0,12 |
| 2 / 3 J1 IZQ / DER | 1ª línea transversal del bastidor, al borde exterior de las ruedas izq / der | 0,06 / 0,94 | 0,43 |
| 4 / 5 J2 | 2ª línea transversal | 0,06 / 0,94 | 0,57 |
| 6 / 7 J3 | 3ª línea transversal | 0,06 / 0,94 | 0,70 |
| 8 / 9 J4 | 4ª línea transversal | 0,06 / 0,94 | 0,84 |

Las fracciones van como constantes en `lib/config/platos.dart`, junto a `nombrePlato(n)`, así hay un solo lugar donde
corregirlas. Marcan dónde se pega el campo: en el enganche y el lado izq el campo **termina** en x (queda a la
izquierda); en el lado der **empieza** en x. En y queda centrado.

### Limitación conocida

El máx/mín solo ve los pesos que **llegan por UDP**. Si el firmware manda pocas tramas por segundo, se pueden perder
picos cortos (el documento pide unas 50 muestras/s por canal). Por eso se guardan las `lecturas` de cada plato: con la
duración de la maniobra dan la tasa real que hubo.

---

## Pasos

### [x] Paso 1 · `quitarHold`: quitar el reset hold
- `PlatoWidget`: quitar el botón `< H >` y que `> 0 <` quede solo (centrado o más ancho).
- `ComandosPlato`: borrar `enviarResetHold`.
- `Conexion` (`Providers/tcp_conexion.dart`): borrar `enviarHold`.
- Revisar los comentarios y `CLAUDE.md` que nombran el reset hold.

### [x] Paso 2 · `ceroGeneral`: cero a los 9 platos con un botón
- `ComandosPlato.enviarCeroGeneral()` → `Future<List<int>>` con los platos que fallaron. Manda `enviarCero(n)` **en
  secuencia** de 1 a 9: `Conexion.cn` es un solo socket, así que en paralelo no funciona.
- `NuevePlatosPage`: barra de acciones arriba, debajo del AppBar, por ahora con un solo botón **Cero general** (widget
  nuevo `BarraEnsayo` en `Pages/nueve_platos/widgets/`, exportado en `export_home_wigets.dart`).
- SnackBar con `positiveColor` si salió bien, o `errorColor` con la lista de platos que fallaron (por nombre, con
  `nombrePlato(n)`).
- Test: no aplica (es TCP). Se prueba con las balanzas.

### [x] Paso 3 · `preferenciasEnsayo`: capacidades y umbral en SharedPreferences (sin UI)
- Dependencia nueva `shared_preferences`.
- Nuevo `lib/helpers/preferencias_ensayo.dart`, clase `PreferenciasEnsayo` con:
  - `Future<List<String>> leerCapacidades()`: 9 valores, índice 0 = plato 1, `''` si nunca se cargó;
  - `Future<String> leerUmbral()`: `'90'` por defecto;
  - `Future<void> guardar({required List<String> capacidades, required String umbral})`.
  - Claves: `capacidad_plato1` .. `capacidad_plato9` y `umbral_alarma`.
- Nada de esto va a la base ni a `tconfig`: la configuración de puertos no se toca.
- Test nuevo `test/helpers/preferencias_ensayo_test.dart` con `SharedPreferences.setMockInitialValues`: valores por
  defecto, guardar y volver a leer.

### [x] Paso 4 · `inicioEnsayo`: pantalla de inicio con tolva y capacidades sobre el dibujo
- Constantes de posición de cada celda en `lib/config/platos.dart` (ver la tabla "Dibujo de la tolva").
- Nuevo `lib/Controllers/ensayo_controller.dart` (GetxController, `Get.put` en `main.dart`). Por ahora solo:
  `tolva`, `capacidades` (9 String), `umbral` e `iniciarEnsayo(tolva, capacidades, umbral)`. Se completa en los pasos
  siguientes.
- Nueva `lib/Pages/inicio_ensayo/inicio_ensayo_page.dart` (ruta `'inicioEnsayo'`), con scroll:
  - arriba, el campo **Identificación de la tolva** (obligatorio);
  - el dibujo `tolva.png` en un `AspectRatio(1000 / 2868)` con `LayoutBuilder` + `Stack`. Cada celda lleva un campo
    numérico chico (kg) en `Positioned`, según sus fracciones x/y: los izq a la izquierda del larguero y los der a la
    derecha, sin tapar el dibujo, y el enganche junto a la lanza. Cada campo lleva arriba la etiqueta `nombrePlato(n)`.
    Como la imagen es muy alta, se dibuja al ancho disponible y la pantalla se desplaza;
  - abajo, **Umbral de alarma (%)** y el botón **Comenzar ensayo**.
- Al abrir la pantalla, los 9 campos y el umbral se precargan con `PreferenciasEnsayo`. La tolva arranca vacía.
- **Comenzar ensayo**: valida la tolva no vacía y que las capacidades sean números ≥ 0 (vacío = sin alarma para esa
  celda; si hay alguna vacía, se avisa pero se deja seguir). Después guarda en `PreferenciasEnsayo`, llama
  `EnsayoController.iniciarEnsayo(...)` y reemplaza la ruta por `'platos'` (así "atrás" vuelve al Home).
- Home: "Iniciar Pesaje" pasa a **"Iniciar ensayo"** y navega a `'inicioEnsayo'`.
- `NuevePlatosPage`: AppBar con el nombre de la tolva.
- `assets/tolva.png` ya está en `assets/` (lo cubre `pubspec.yaml`); se agrega al repo en este paso.

### [x] Paso 5 · `registroMaxMin`: máximo y mínimo por plato (sin UI)
- Nueva clase pura `lib/domain/entities/registro_max_min.dart`: `registrar(double peso)`, `maximo`, `minimo`,
  `lecturas`, `hayDatos` y `reiniciar()`.
- `PesoController`:
  - campos `registrando` y `registro`, y estado Rx para la UI (`maximo`, `minimo`, `lecturas` como String / int);
  - `iniciarRegistro()` reinicia y pone `registrando = true`;
  - `detenerRegistro()` corta y devuelve el registro;
  - dentro del `listen` UDP, si `registrando`, se llama `registro.registrar(double.tryParse(reading.peso))`, salteando
    los null. Así se comparan **todas** las tramas, no solo las que llega a dibujar la pantalla.
- Test nuevo `test/domain/registro_max_min_test.dart`: secuencia de pesos, primera lectura (máx = mín), negativos,
  reinicio.

### [x] Paso 6 · `tomarEstatico`: referencia estática
- `EnsayoController`: `estaticos` (RxList<String>, vacía = sin estático), `estado` (`sinEstatico` / `listo` /
  `registrando`), `tomarEstatico()` y `borrarEstatico()`.
- `NuevePlatosPage`:
  - **quitar el FAB Guardar** y `showDialogGuardarPesada`;
  - en `BarraEnsayo`, botón **Tomar estático**. Si hay platos desconectados, pide confirmación antes.
- `PlatoWidget`: nueva línea `E: <estático>` (vacía si no hay estático).
- Cero general y cero de un plato → `borrarEstatico()` y un SnackBar: "Volvé a tomar el estático".
- Estado intermedio aceptado: el historial de pesadas sigue existiendo, pero ya no se pueden guardar pesadas nuevas.

### [x] Paso 7 · `registrarManiobra`: iniciar y terminar maniobra (todavía sin guardar)
- `BarraEnsayo`: botón **Registrar maniobra**, habilitado solo en estado `listo`. Mientras corre cambia a
  **Terminar maniobra** y muestra el número de maniobra y el tiempo transcurrido.
- `EnsayoController.iniciarManiobra()`: llama `iniciarRegistro()` en los 9 `PesoController` y guarda la hora de inicio.
  `terminarManiobra()`: los detiene y arma el resultado con las capacidades del ensayo.
- Modelo `lib/models/ensayos/maniobra_plato.dart`: `plato`, `estatico`, `maximo`, `minimo`, `lecturas`, `capacidad` y
  los getters `factorCresta`, `porCapacidad` y `estado(umbral)` (fórmulas de la tabla de arriba). Pesos con 2
  decimales y % con 1, como el resto de la app.
- `PlatoWidget`: durante la maniobra muestra `máx / mín` en vivo.
- Durante la maniobra: Cero general, Tomar estático y los `> 0 <` quedan deshabilitados.
- Al terminar: diálogo con la tabla de resultados. Widget nuevo `TablaManiobra` con plato, estático, máx, mín, FC,
  % cap y estado con color, igual que la tabla del punto 06 del documento. Quedó en `lib/Widgets/tabla_maniobra.dart`
  para reutilizarlo en el historial (paso 11).
- Hecho así: `terminarManiobra()` devuelve un record `ResultadoManiobra` (número, inicio, fin y los 9
  `ManiobraPlato`); en el paso 10 lo reemplaza `ManiobraModel`. Descartar no consume el número de maniobra.
- `PopScope`: si se sale con una maniobra en curso, pide confirmación y la descarta.
- Test nuevo `test/Models/maniobra_plato_test.dart`: los casos de borde (= umbral, = 100 %, > 100 %, capacidad 0 o
  vacía, estático 0) y los valores de ejemplo del documento.

### [x] Paso 8 · `alarmaUmbral`: resaltar el plato que se pasa
- `PlatoWidget` recibe un `nivelAlarma` (normal / alLimite / excede), calculado con el **máximo** de la maniobra (o el
  peso actual si no hay maniobra) contra `EnsayoController.capacidades[n - 1]` y `umbral`.
- Se dibuja con el borde y el título en ámbar (al límite) o rojo (excede). Sin capacidad cargada no hay alarma.
- Reutilizar la función pura `estadoCelda(peso:, capacidad:, umbral:)` de `maniobra_plato.dart` (la usa
  `ManiobraPlato.estado`), para no duplicar la fórmula.
- Hecho así: `nivelAlarma` es un `EstadoCelda` (por defecto `sinDato`) y lo calcula `EnsayoController.alarma(n, peso:,
  maximo:)`; si la maniobra todavía no recibió lecturas usa el peso actual. Los colores son los de
  `TablaManiobra.colorEstado` (borde de 3 px; en ámbar el título va en negro). Tests en `ensayo_controller_test` y
  `test/widgets/nueve_platos/plato_widget_alarma_test.dart`.

### [x] Paso 9 · `pantallaEncendida`: que no se apague la pantalla en la maniobra
- Dependencia nueva `wakelock_plus`: `WakelockPlus.enable()` en `iniciarManiobra` y `disable()` en
  `terminarManiobra`, al descartar y en `onClose`.
- Probar en el teléfono que una maniobra de varios minutos con la pantalla sin tocar sigue recibiendo datos.
- Hecho así: `EnsayoController` recibe `pantallaEncendida` (por defecto `WakelockPlus.toggle`, con el error solo en
  `debugPrint`) para que los tests no toquen el plugin. Un ensayo nuevo con la maniobra en curso la descarta y también
  apaga el wakelock. Test en `ensayo_controller_test`.

### [x] Paso 10 · `guardarManiobras`: ensayos y maniobras en la base
- Tablas nuevas (`dbVersion = 2`; `onUpgrade` con `oldVersion < 2` las crea y `onCreate` también):

  | Tabla | Columnas |
  |---|---|
  | `tensayos` | `id`, `tolva`, `fecha` (dd/MM/yyyy), `created_at` (ISO 8601) |
  | `tmaniobras` | `id`, `ensayo_id` FK → `tensayos` `ON DELETE CASCADE`, `numero`, `hora_inicio`, `hora_fin`, `duracion_ms`, `umbral` |
  | `tmaniobras_platos` | `maniobra_id` FK → `tmaniobras` `ON DELETE CASCADE`, `plato`, `estatico`, `maximo`, `minimo`, `lecturas`, `capacidad`; PK (`maniobra_id`, `plato`) |

  La capacidad y el umbral se **copian** en cada maniobra, porque en SharedPreferences cambian en el próximo ensayo y
  la maniobra guardada tiene que seguir mostrando el mismo estado.
- Modelos `EnsayoModel` y `ManiobraModel` (cabecera + `List<ManiobraPlato>`), con `toDb` / `fromDb`.
- Cadena como la de pesadas: `tables/db_ensayos.dart`, `db_maniobras.dart` y `db_maniobras_platos.dart`; interfaz,
  `ServiceEnsayos` y `HelpersEnsayos` (SnackBar). En `DBconeccion`:
  - `insertEnsayo`;
  - `insertManiobra` (cabecera + 9 filas en una transacción; devuelve el id o -1);
  - `getEnsayos` (con sus maniobras, id descendente);
  - `deleteEnsayo`, `deleteManiobra` y `deleteEnsayos`.
- `EnsayoController`: la fila de `tensayos` se inserta al tomar el **primer** estático (así no quedan ensayos vacíos),
  y `terminarManiobra` guarda antes de mostrar el diálogo.
- Mock nuevo en `test/moks/` y test `test/BaseDeDatos/ensayos/service_ensayos_test.dart`.
- Hecho así: la fila de `tensayos` se inserta al guardar la **primera maniobra**, no al tomar el estático (tampoco
  quedan ensayos sin maniobras y `tomarEstatico` sigue siendo síncrono); la fecha es la de esa maniobra. Si falla, la
  próxima maniobra lo reintenta. `terminarManiobra()` pasó a `Future<ManiobraModel?>`: corta el registro antes del
  primer `await`, guarda y devuelve la maniobra con sus ids (`guardada` = tiene id). `ManiobraModel` reemplaza al
  record `ResultadoManiobra` y lleva `hora_inicio` / `hora_fin` como `HH:mm:ss`. `HelpersEnsayos.avisarGuardado`
  muestra el SnackBar y el diálogo usa el umbral copiado en la maniobra. `EnsayoController` recibe `ensayos`
  (`ServiceEnsayos`, por defecto con `DBconeccion.db`) para los tests. Mock en memoria `test/moks/db_ensayos_mock.dart`
  (ids, orden y cascada) y test nuevo `test/Models/ensayo_model_test.dart` (`toDb` / `fromDb`).

### [x] Paso 11 · `historialEnsayos`: ver los ensayos guardados
- Nueva `lib/Pages/ensayos/ensayos_page.dart` (ruta `'ensayos'`), con un provider/stream como el de pesadas:
  - una tarjeta por ensayo (tolva, fecha y cantidad de maniobras) que se expande con una `TablaManiobra` por maniobra
    (número, hora y duración);
  - borrar un ensayo deslizando (el mismo SnackBar OK/cancel de hoy) y borrar todo con `DialogBorrar`.
- Home: el botón "ver pesadas" de la barra inferior pasa a "ver ensayos".
- Hecho así: el provider es una sola clase, `lib/Providers/ensayos/ensayos_provider.dart` (`EnsayosProvider` sobre
  `ServiceEnsayos`, stream sin broadcast; `getEnsayos`, `borrarEnsayo`, `borrarEnsayos`; después de `dispose` no
  emite). `EnsayosPage` es un `StatefulWidget` que recibe `ensayos` (`ServiceEnsayos`) para los tests; el ensayo
  deslizado se oculta mientras está el SnackBar y vuelve si se cancela. La tarjeta es `TarjetaEnsayo`
  (`Pages/ensayos/widgets/`, un `ExpansionTile`), y el horario de la maniobra sale de `descripcionManiobra`, que
  comparte con el diálogo (`dialog_maniobra.dart`). `DialogBorrar` pasó a `lib/Widgets/` con `titulo`, `mensaje` y
  `onBorrar` (lo usan pesadas y ensayos; `HelpersPesadas.borrarTodasPesadas` ahora espera el borrado). La ruta
  `'pesadas'` sigue registrada, pero sin botón que lleve a ella, hasta el paso 13. Tests nuevos
  `test/Providers/ensayos_provider_test.dart` y `test/widgets/ensayos/ensayos_page_test.dart`.

### [x] Paso 12 · `exportarEnsayos`: XLSX de maniobras
- `exportar_xml.dart`: `ensayos.xlsx` con la hoja `maniobras`, **una fila por maniobra y plato**: `ensayo_id`, `tolva`,
  `fecha`, `maniobra`, `hora_inicio`, `hora_fin`, `duracion_s`, `plato`, `nombre`, `capacidad`, `estatico`, `maximo`,
  `minimo`, `lecturas`, `factor_cresta`, `por_cap`, `estado`.
- `ManiobraModel.toExportRows()` arma las filas. Test del orden de columnas.
- `compartirArchivo` comparte `ensayos.xlsx` (asunto "Balanzas Hook, ensayo 9 platos").
- Hecho así: `toExportRows(tolva:, fecha:)` recibe los datos del ensayo (la maniobra solo tiene `ensayoId`);
  `duracion_s` va con 1 decimal y `estado` usa el umbral copiado en la maniobra. `Exportar.writeFileEnsayos` genera
  el archivo (1, 0 sin maniobras, -1 si falla) con las filas de `Exportar.filasEnsayos`, de los ensayos más viejos a
  los más nuevos. Como ya no hay botón que genere el archivo, el botón compartir del Home lo genera en el momento y
  después lo comparte; sin maniobras avisa con un SnackBar. `writeFile` (pesadas) sigue para `PesadasPage` hasta el
  paso 13. Test nuevo `test/Models/maniobra_export_test.dart`.

### [x] Paso 13 · `quitarPesadas`: borrar el código y las tablas de pesadas
- Borrar:
  - `models/pesadas/*` y `tables/db_pesadas_*`;
  - interfaces, services y helpers de pesadas;
  - `Providers/pesadas/*` y `Pages/pesadas/*` (lo que no se haya reutilizado);
  - `DialogWidget` si ya no lo usa nadie;
  - `CalculosController.calcularPayload9Platos`. Quedan el total y los % en vivo.
- `dbVersion = 3`: `onUpgrade` con `oldVersion < 3` hace `DROP TABLE` de `tpesadas_9platos` y `tpesadas_base`.
  `onCreate` deja de crearlas.
- Tests: quitar los de pesadas (`pesada_9platos_payload_test`, `service_pesadas_test`, `list_pesaje`) y la parte del
  payload en `calculos_9platos_test`.

### [ ] Paso 14 · `claudeMdEnsayo`: documentación final
- Actualizar `CLAUDE.md`: qué es la app (modo ensayo), pantalla de inicio con el dibujo de la tolva, SharedPreferences,
  flujo estático → maniobra, esquema de la base v3, exportación, tests y estado de `flutter analyze`.
- `README.md`: historial.
- Marcar todos los pasos de este plan.

---

## A confirmar (antes del paso que corresponda)

- **Tasa real del firmware**: medirla en el banco con las `lecturas` del paso 10. Si es baja, el pico tendría que
  retenerlo el firmware; eso es otro plan.
- **Mínimo**: el documento lo usa para detectar si el apoyo se levanta. ¿Hace falta un estado propio (por ejemplo
  "SE DESCARGA" si el mín. queda cerca de 0)? Hoy no está previsto.
- **Nombre de la maniobra**: por ahora es solo un número. Si después se quiere elegir el paso del protocolo (02 Reparto
  estático … 08 Arranque y frenada), se agrega en el paso 7 o 10.
- **Tolva**: hoy arranca vacía en cada ensayo. ¿Conviene precargar la última, también desde SharedPreferences?
  (paso 4).
- **Posición de los campos sobre el dibujo**: las fracciones de la tabla son una primera medida; se ajustan viendo la
  pantalla en el teléfono y en la tablet (paso 4).

## Verificación en cada paso

1. `fvm flutter analyze` (sin warnings nuevos; siguen los info previos) y `fvm flutter test`.
2. `fvm flutter build apk --debug`.
3. Con las balanzas, según el paso:
   - instalar **sobre** la versión anterior y comprobar que la migración conserva los puertos (pasos 10 y 13);
   - inicio de ensayo: cargar capacidades, salir, volver a entrar y comprobar que siguen ahí y se pueden cambiar
     (paso 4);
   - Cero general;
   - Tomar estático;
   - maniobra cargando y descargando un plato a mano (máx/mín lo siguen y la alarma se enciende);
   - apagar un plato a mitad de la maniobra: no se rompe y queda con pocas lecturas;
   - la maniobra aparece en el historial y en el XLSX.
