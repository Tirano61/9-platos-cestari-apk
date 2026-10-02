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
- La **identificación de la tolva** se pide al iniciar el ensayo.
- **Estático**: con la tolva parada, un botón toma los 9 pesos como referencia. Vale para todas las maniobras
  siguientes hasta que se vuelva a tomar. Cualquier cero lo borra, porque deja de ser válido.
- **Maniobra**: se habilita solo con un estático tomado. Mientras dura, cada peso que llega de cada plato se compara
  con el máximo y el mínimo anteriores. **No se guarda cada lectura.** Al terminar se guardan, por plato: estático,
  máximo, mínimo y cantidad de lecturas.
- **Capacidad nominal por celda** (9 valores en la configuración) y un **umbral de alarma en %** común.
- Las maniobras se numeran solas dentro del ensayo (1, 2, 3…) y guardan su hora de inicio y fin.

### Cálculos por plato y maniobra

| Dato | Fórmula |
|---|---|
| Factor de cresta | máx ÷ estático (`-` si el estático es ≤ 0) |
| % cap. nominal | máx × 100 ÷ capacidad (`-` si la capacidad es 0, o sea no configurada) |
| Estado | `EXCEDE` si % > 100; `AL LÍMITE` si % ≥ umbral; `NORMAL` si no; `-` sin capacidad |

Ejemplo del documento: C2 con estático 2.410, máx. 5.980 y capacidad 5.000 da FC 2,48, 119,6 % y `EXCEDE`.

### Limitación conocida

El máx/mín solo ve los pesos que **llegan por UDP**. Si el firmware manda pocas tramas por segundo, se pueden perder
picos cortos (el documento pide unas 50 muestras/s por canal). Por eso se guardan las `lecturas` de cada plato: con la
duración de la maniobra dan la tasa real que hubo.

---

## Pasos

### [ ] Paso 1 · `quitarHold`: quitar el reset hold
- `PlatoWidget`: quitar el botón `< H >` y que `> 0 <` quede solo (centrado o más ancho).
- `ComandosPlato`: borrar `enviarResetHold`.
- `Conexion` (`Providers/tcp_conexion.dart`): borrar `enviarHold`.
- Revisar los comentarios y `CLAUDE.md` que nombran el reset hold.

### [ ] Paso 2 · `ceroGeneral`: cero a los 9 platos con un botón
- `ComandosPlato.enviarCeroGeneral()` → `Future<List<int>>` con los platos que fallaron. Manda `enviarCero(n)` **en
  secuencia** de 1 a 9: `Conexion.cn` es un solo socket, así que en paralelo no funciona.
- `NuevePlatosPage`: barra de acciones arriba, debajo del AppBar, por ahora con un solo botón **Cero general** (widget
  nuevo `BarraEnsayo` en `Pages/nueve_platos/widgets/`, exportado en `export_home_wigets.dart`).
- SnackBar con `positiveColor` si salió bien, o `errorColor` con la lista de platos que fallaron (por nombre, con
  `nombrePlato(n)`).
- Test: no aplica (es TCP). Se prueba con las balanzas.

### [ ] Paso 3 · `capacidadCeldasDb`: capacidad nominal y umbral en la configuración (sin UI)
- `tconfig`: columnas `cap1..cap9` (TEXT, por defecto `'0'`) y `umbral` (TEXT, por defecto `'90'`). En `DBconfig`,
  helper `fconCapacidad(n)` como `fconPlato(n)`.
- `DBconeccion`: `dbVersion = 2`. `onCreate` crea la tabla con las columnas nuevas. `onUpgrade`, si `oldVersion < 2`,
  hace un `ALTER TABLE tconfig ADD COLUMN ...` por columna. **No** se desinstala la app: los puertos tienen que
  sobrevivir.
- `ConfigModel`: `List<String> capacidades` (índice 0 = plato 1), `String umbral` y `capacidad(n)`. `fromJson` usa los
  valores por defecto si falta la columna.
- `ConfigController`: `capacidad(n)` / `setCapacidades(lista)` y `umbral` / `setUmbral`, con el mismo patrón que los puertos.
- `main.dart`: cargar capacidades y umbral junto con los puertos. `first_data.dart`: valores por defecto.
- Test nuevo `test/Models/config_model_test.dart`: ida y vuelta `toJson`/`fromJson` y valores por defecto.

### [ ] Paso 4 · `capacidadCeldasUi`: cargar capacidad y umbral en el diálogo de configuración
- `DialogConfig`: para cada plato, puerto y capacidad (kg) en la misma fila o una debajo de la otra. Se reutiliza
  `InputTextConfig` (si hace falta, con un parámetro para el teclado numérico). Al final, el campo
  "Umbral de alarma (%)".
- Validación simple: vacío o inválido → `'0'` en la capacidad y `'90'` en el umbral.
- `HelpersConfig.upDateConfig` guarda todo. La reconexión de los puertos no cambia.
- Cambiar el título del diálogo a "Configuración" y explicar que la capacidad 0 significa "sin alarma".

### [ ] Paso 5 · `registroMaxMin`: máximo y mínimo por plato (sin UI)
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

### [ ] Paso 6 · `iniciarEnsayo`: identificación de la tolva y estático
- Nuevo `lib/Controllers/ensayo_controller.dart` (GetxController, `Get.put` en `main.dart`). Campos: `tolva`,
  `estaticos` (RxList<String>, vacía = sin estático), `estado` (`sinEstatico` / `listo` / `registrando`).
  Métodos: `iniciarEnsayo(tolva)`, `tomarEstatico()` y `borrarEstatico()`.
- Home: "Iniciar Pesaje" pasa a **"Iniciar ensayo"**. Abre `DialogWidget` con el label "Identificación de la tolva"
  (parametrizar título y label) y después navega a `'platos'`. Con la tolva vacía no avanza.
- `NuevePlatosPage`:
  - AppBar con el nombre de la tolva;
  - **quitar el FAB Guardar** y `showDialogGuardarPesada`;
  - en `BarraEnsayo`, botón **Tomar estático**. Si hay platos desconectados, pide confirmación antes.
- `PlatoWidget`: nueva línea `E: <estático>` (vacía si no hay estático).
- Cero general y cero de un plato → `borrarEstatico()` y un SnackBar: "Volvé a tomar el estático".
- Estado intermedio aceptado: el historial de pesadas sigue existiendo, pero ya no se pueden guardar pesadas nuevas.

### [ ] Paso 7 · `registrarManiobra`: iniciar y terminar maniobra (todavía sin guardar)
- `BarraEnsayo`: botón **Registrar maniobra**, habilitado solo en estado `listo`. Mientras corre cambia a
  **Terminar maniobra** y muestra el número de maniobra y el tiempo transcurrido.
- `EnsayoController.iniciarManiobra()`: llama `iniciarRegistro()` en los 9 `PesoController` y guarda la hora de inicio.
  `terminarManiobra()`: los detiene y arma el resultado.
- Modelo `lib/models/ensayos/maniobra_plato.dart`: `plato`, `estatico`, `maximo`, `minimo`, `lecturas`, `capacidad` y
  los getters `factorCresta`, `porCapacidad` y `estado(umbral)` (fórmulas de la tabla de arriba). Pesos con 2
  decimales y % con 1, como el resto de la app.
- `PlatoWidget`: durante la maniobra muestra `máx / mín` en vivo.
- Durante la maniobra: Cero general, Tomar estático y los `> 0 <` quedan deshabilitados.
- Al terminar: diálogo con la tabla de resultados. Widget nuevo `TablaManiobra` con plato, estático, máx, mín, FC,
  % cap y estado con color, igual que la tabla del punto 06 del documento.
- `PopScope`: si se sale con una maniobra en curso, pide confirmación y la descarta.
- Test nuevo `test/Models/maniobra_plato_test.dart`: los casos de borde (= umbral, = 100 %, > 100 %, capacidad 0,
  estático 0) y los valores de ejemplo del documento.

### [ ] Paso 8 · `alarmaUmbral`: resaltar el plato que se pasa
- `PlatoWidget` recibe un `nivelAlarma` (normal / alLimite / excede), calculado con el **máximo** de la maniobra (o el
  peso actual si no hay maniobra) contra `capacidad(n)` y `umbral`.
- Se dibuja con el borde y el título en ámbar (al límite) o rojo (excede). Sin capacidad configurada no hay alarma.
- Reutilizar `ManiobraPlato.estado` u otra función pura compartida, para no duplicar la fórmula.

### [ ] Paso 9 · `pantallaEncendida`: que no se apague la pantalla en la maniobra
- Dependencia nueva `wakelock_plus`: `WakelockPlus.enable()` en `iniciarManiobra` y `disable()` en
  `terminarManiobra`, al descartar y en `onClose`.
- Probar en el teléfono que una maniobra de varios minutos con la pantalla sin tocar sigue recibiendo datos.

### [ ] Paso 10 · `guardarManiobras`: ensayos y maniobras en la base
- Tablas nuevas (`dbVersion = 3`; `onUpgrade` con `oldVersion < 3` las crea y `onCreate` también):

  | Tabla | Columnas |
  |---|---|
  | `tensayos` | `id`, `tolva`, `fecha` (dd/MM/yyyy), `created_at` (ISO 8601) |
  | `tmaniobras` | `id`, `ensayo_id` FK → `tensayos` `ON DELETE CASCADE`, `numero`, `hora_inicio`, `hora_fin`, `duracion_ms`, `umbral` |
  | `tmaniobras_platos` | `maniobra_id` FK → `tmaniobras` `ON DELETE CASCADE`, `plato`, `estatico`, `maximo`, `minimo`, `lecturas`, `capacidad`; PK (`maniobra_id`, `plato`) |

  La capacidad y el umbral se **copian** en cada maniobra, para que el estado no cambie si después se toca la
  configuración.
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

### [ ] Paso 11 · `historialEnsayos`: ver los ensayos guardados
- Nueva `lib/Pages/ensayos/ensayos_page.dart` (ruta `'ensayos'`), con un provider/stream como el de pesadas:
  - una tarjeta por ensayo (tolva, fecha y cantidad de maniobras) que se expande con una `TablaManiobra` por maniobra
    (número, hora y duración);
  - borrar un ensayo deslizando (el mismo SnackBar OK/cancel de hoy) y borrar todo con `DialogBorrar`.
- Home: el botón "ver pesadas" de la barra inferior pasa a "ver ensayos".

### [ ] Paso 12 · `exportarEnsayos`: XLSX de maniobras
- `exportar_xml.dart`: `ensayos.xlsx` con la hoja `maniobras`, **una fila por maniobra y plato**: `ensayo_id`, `tolva`,
  `fecha`, `maniobra`, `hora_inicio`, `hora_fin`, `duracion_s`, `plato`, `nombre`, `capacidad`, `estatico`, `maximo`,
  `minimo`, `lecturas`, `factor_cresta`, `por_cap`, `estado`.
- `ManiobraModel.toExportRows()` arma las filas. Test del orden de columnas.
- `compartirArchivo` comparte `ensayos.xlsx` (asunto "Balanzas Hook, ensayo 9 platos").

### [ ] Paso 13 · `quitarPesadas`: borrar el código y las tablas de pesadas
- Borrar:
  - `models/pesadas/*` y `tables/db_pesadas_*`;
  - interfaces, services y helpers de pesadas;
  - `Providers/pesadas/*` y `Pages/pesadas/*` (lo que no se haya reutilizado);
  - `CalculosController.calcularPayload9Platos`. Quedan el total y los % en vivo.
- `dbVersion = 4`: `onUpgrade` con `oldVersion < 4` hace `DROP TABLE` de `tpesadas_9platos` y `tpesadas_base`.
  `onCreate` deja de crearlas.
- Tests: quitar los de pesadas (`pesada_9platos_payload_test`, `service_pesadas_test`, `list_pesaje`) y la parte del
  payload en `calculos_9platos_test`.

### [ ] Paso 14 · `claudeMdEnsayo`: documentación final
- Actualizar `CLAUDE.md`: qué es la app (modo ensayo), flujo estático → maniobra, esquema de la base v4, exportación,
  tests y estado de `flutter analyze`.
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

## Verificación en cada paso

1. `fvm flutter analyze` (sin warnings nuevos; siguen los 3 info previos) y `fvm flutter test`.
2. `fvm flutter build apk --debug`.
3. Con las balanzas, según el paso:
   - instalar **sobre** la versión anterior y comprobar que la migración conserva los puertos (pasos 3, 10 y 13);
   - Cero general;
   - Tomar estático;
   - maniobra cargando y descargando un plato a mano (máx/mín lo siguen y la alarma se enciende);
   - apagar un plato a mitad de la maniobra: no se rompe y queda con pocas lecturas;
   - la maniobra aparece en el historial y en el XLSX.
