# CLAUDE.md — Platos Cestari (Balanzas Hook)

Referencia rápida del proyecto para trabajar con Claude Code. Código, comentarios, commits y esta guía están en español.

## Qué es la app

App Flutter (Android es el único target real) para pesar una tolva de 3 ejes de Cestari con **9 balanzas inalámbricas** ("platos", una por celda) de Balanzas Hook. Hay un solo tipo de pesaje: **9 platos**.

```
            [1 ENGANCHE]
   [2 J1 IZQ]  JUEGO 1  [3 J1 DER]
   [4 J2 IZQ]  JUEGO 2  [5 J2 DER]
   [6 J3 IZQ]  JUEGO 3  [7 J3 DER]
   [8 J4 IZQ]  JUEGO 4  [9 J4 DER]
     LADO IZQ             LADO DER
```

- Plato 1: enganche. Platos 2..9: 4 **juegos** de celdas izq/der (J1 = 2/3 … J4 = 8/9). Los juegos no corresponden a ejes.
- Cálculos: peso y % de cada plato, subtotal y % de cada juego, lado izq (2+4+6+8) y lado der (3+5+7+9) con su % (`CalculosController`; la pantalla de pesaje ya no los muestra), y total. El enganche no suma a ningún lado.
- Conexión **solo WiFi UDP**: cada plato emite datagramas a su puerto (8001..8009 por defecto). El cero se manda por TCP a la IP del plato. No hay BLE ni reset hold.

Identidad:

- package Dart `nueve_platos_cestari`;
- `applicationId` / namespace `com.dramirez.nueveplatoscestari` (se instala junto a la app vieja "Platos" sin pisarla);
- label Android y título: "Platos Cestari";
- versión en `pubspec.yaml`: `1.0.1+1`.

La app no va al Play Store. Nació como copia de "Cuatro Platos" y se reformó en 10 PRs ([docs/plan_9_platos.md](docs/plan_9_platos.md), todos hechos).

## Ramas y flujo de trabajo

- `main` es la rama principal (`origin/main`) y la base de todos los PRs.
- Flujo: rama feature corta con nombre camelCase → PR → merge a `main`. Commits en español, una línea.
- Remotos:
  - `origin` = Balanzas-Hook/9-platos-cestari-apk;
  - `gittirano` = Tirano61/9-platos-cestari-apk (espejo).

## Toolchain y comandos

- Flutter fijado con FVM: `3.41.6` (`.fvmrc`). Dart SDK `>=3.0.0`. VS Code usa `.fvm/flutter_sdk`.
- `fvm` es un `.bat` (Pub cache): funciona desde PowerShell/cmd, no desde Git Bash. Desde Git Bash usar `.fvm/flutter_sdk/bin/flutter.bat`.
- Android: AGP 8.11.1, Kotlin 2.2.20, `minifyEnabled true` en release, firma con `android/key.properties`. Permisos: `INTERNET` y `READ/WRITE_EXTERNAL_STORAGE` (exportación).
- `android/key.properties` y `local.properties` están versionados en git (el primero con credenciales del keystore). No los toques ni los muestres salvo que se pida.
- Dependencias principales: `get`, `udp`, `http`, `sqflite`, `shared_preferences`, `wakelock_plus`, `excel`, `share_plus`, `path_provider`, `permission_handler`, `intl`, `flutter_native_splash`.

```powershell
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter run                      # dispositivo Android conectado
fvm flutter build apk --debug
fvm flutter build apk --release      # usa android/key.properties
fvm dart run flutter_native_splash:create   # regenerar splash (assets/splash*.png, color #153a65)
fvm dart run flutter_launcher_icons         # regenerar icono (assets/icon.png)
```

Para probar la conexión real hacen falta las balanzas físicas: UDP no se puede simular desde el emulador sin las antenas.

Estado de `flutter analyze` al 06/10/2026: 0 errores, 0 warnings, 2 `info` preexistentes (`file_names` en `homePage.dart` y `SizeScreen.dart`). No introducir nuevos; no hace falta corregir estos salvo que se pida. `flutter test`: 122 tests en verde.

## Mapa del código (`lib/`)

Las carpetas viejas usan mayúscula inicial (`Controllers`, `Pages`, `BaseDeDatos`, `Providers`, `Widgets`, `Theme`); las nuevas usan minúscula (`data`, `domain`, `models`, `helpers`, `config`). Mantener el estilo de la carpeta donde se toca.

```
lib/main.dart                      Bootstrap: Get.put(ConfigController), un PesoController por plato
                                   (tag 'plato1'..'plato9'), carga la config de la DB (o inserta los
                                   puertos por defecto), arranca recibirPeso() de cada plato, rutas.
lib/config/
  platos.dart                      cantidadPlatos = 9 y nombrePlato(n): 'ENGANCHE', 'J1 IZQ' .. 'J4 DER'.
                                   Dibujo de la tolva: imagenTolva, proporcionTolva y posicionCelda(n)
                                   (fracciones x/y donde va el campo de cada celda), esLadoDerecho(n).
  SizeScreen.dart                  Singleton SizeScreen.sc(): screenWidth e isMinWidth (>= 420 px,
                                   se usa como "tablet vs telefono").
  theme.dart                       ThemeApp (colores y estilos de la app).
lib/Theme/theme.dart               ThemePlatos.cn (errorColor / positiveColor de los SnackBar).
lib/Controllers/
  config_controller.dart           Lista de RxString con los puertos: puerto(n) / setPuerto(n, v) /
                                   setPuertos(lista), cantidadPlatos.
  peso_controller.dart             PesoController(plato: n), uno por plato. Escucha UDP, actualiza
                                   pesoModel (RecibirPesoModel), timer de 1 s que marca desconexion a
                                   los 5 s sin datos y reabre el socket si hace falta. Registro de
                                   max/min: iniciarRegistro() / detenerRegistro() (devuelve el
                                   RegistroMaxMin; el Rx queda con los ultimos valores), limpiarRegistro()
                                   (maniobra descartada: vacia el Rx) y Rx maximo / minimo / lecturas para la UI.
  calculos_controllers.dart        Singleton CalculosController.cn: total (setPesoTotalByList /
                                   pesoTotal) y porcentajes en vivo de platos, juegos y lados.
  ensayo_controller.dart           EnsayoController (Get.put en main.dart): tolva, capacidades (9 String,
                                   '' = sin alarma) y umbral del ensayo en curso; iniciarEnsayo(...) (borra
                                   el estatico, descarta la maniobra y reinicia la numeracion). Estatico:
                                   estaticos (RxList, vacia = sin estatico), estado (EstadoEnsayo
                                   sinEstatico / listo / registrando), tomarEstatico() (lee los 9
                                   PesoController; los tests inyectan leerPesos) y borrarEstatico() (devuelve
                                   si habia uno). alarma(n, peso:, maximo:): EstadoCelda del plato (el max
                                   durante la maniobra, si no el peso actual) con estadoCelda. Maniobra: numeroManiobra, inicioManiobra,
                                   iniciarManiobra() (solo en listo; iniciarRegistro en los 9 platos y
                                   pantalla encendida con wakelock_plus hasta terminar / descartar),
                                   terminarManiobra() (async: corta el registro, guarda y devuelve el
                                   ManiobraModel; la fila del ensayo se inserta con la primera maniobra) y
                                   descartarManiobra() (no consume el numero). Los tests inyectan los
                                   PesoController con platos, el wakelock con pantallaEncendida y la base
                                   con ensayos (ServiceEnsayos).
  controllers_export.dart          Barrel de calculos + peso_controller.
lib/data/udp/udp_scale_parser.dart Parsea el datagrama "ADC = peso,estable,x,tension" -> ScaleReading.
lib/domain/entities/scale_reading.dart  Lectura normalizada (peso, estable, tension, sourceId).
lib/domain/entities/registro_max_min.dart  RegistroMaxMin (clase pura): registrar(peso), maximo, minimo,
                                   lecturas, hayDatos y reiniciar().
lib/models/
  config_model.dart                ConfigModel: List<String> puertos (indice 0 = plato 1), puerto(n).
                                   Claves JSON = columnas tconfig plato1..plato9.
  recibir_peso_model.dart          Estado Rx de un plato: peso, estable, tension (nivel 1..5),
                                   adreess (IP de origen), conexion.
  ensayos/ensayo_model.dart        EnsayoModel (id, tolva, fecha, createdAt, maniobras; toDb / fromDb).
  ensayos/maniobra_model.dart      ManiobraModel (id, ensayoId, numero, horaInicio / horaFin HH:mm:ss,
                                   duracionMs, umbral copiado, 9 ManiobraPlato; guardada = tiene id).
                                   toExportRows(tolva:, fecha:): una fila XLSX por plato.
  ensayos/maniobra_plato.dart      ManiobraPlato (plato, estatico, maximo, minimo, lecturas, capacidad;
                                   toDb / fromDb; getters factorCresta y porCapacidad, estado(umbral)). Funciones puras
                                   porcentajeCapacidad y estadoCelda (EstadoCelda normal / alLimite / excede /
                                   sinDato, con su texto), comparando el % ya redondeado a 1 decimal.
  calibracion/calibracion_model.dart  CalibracionModel, comun a los dos firmwares (FirmwareCalibracion clasico /
                                   esp32): 10 campos que se envian + capacidadMaxima (solo lectura), null si el
                                   firmware no lo mando; completa, toSaveQuery() (parametros de /save en orden,
                                   StateError si no esta completa) y copyWith.
  calibracion/calibracion_clasica_model.dart  CalibracionClasicaModel.fromJson (respuesta plana de /config?json=1,
                                   17 claves, numeros como num) y toCalibracion().
  calibracion/calibracion_esp32_model.dart  CalibracionEsp32Model.fromJson (Configuracion.Balanza de
                                   /configjson?json=1; sin ella FormatException) y toCalibracion(). floatDesdeU64:
                                   32 bits bajos leidos como float, 2 decimales (solo con type u64).
lib/helpers/
  comandos_plato.dart              ComandosPlato.enviarCero(plato): TCP a la IP del plato.
                                   enviarCeroGeneral(): cero a los 9 en secuencia; devuelve los que fallaron.
                                   ipPlato(n): IP de origen de los datagramas del plato (null si no hay:
                                   adreess '0' o vacio); la usan el cero y la calibracion.
  exportar_xml.dart                A pesar del nombre exporta XLSX: writeFileEnsayos (ensayos.xlsx, hoja
                                   maniobras; filas de filasEnsayos) y compartirArchivo (lo genera y lo
                                   comparte).
  bateria.dart                     Bateria.porcentaje(voltios): 3.0 V = 0 %, 4.2 V = 100 %.
  preferencias_ensayo.dart         PreferenciasEnsayo: capacidad nominal de cada celda y umbral de alarma en
                                   SharedPreferences (leerCapacidades / leerUmbral / guardar). Los usa InicioEnsayoPage.
lib/Providers/
  tcp_conexion.dart                Conexion.cn: socket TCP al puerto 80 de la IP del plato; manda cero
                                   (y calibracion, sin uso) por HTTP GET. No usarlo directo
                                   desde la UI: pasar por ComandosPlato.
  calibracion_wifi.dart            CalibracionWifi (http.Client inyectable, timeout 5 s, errores de red capturados):
                                   leer(ip) prueba /config?json=1 (clasico) y, si falla o no da 200,
                                   /configjson?json=1 (ESP32); null si ninguno. enviar(ip, calibracion): nada si
                                   no esta completa; /save?<toSaveQuery> y con 200 /save?reset=1 -> true.
  ensayos/ensayos_provider.dart    EnsayosProvider(ServiceEnsayos): stream (sin broadcast) de
                                   List<EnsayoModel> para EnsayosPage; getEnsayos / borrarEnsayo /
                                   borrarEnsayos vuelven a emitir la lista; despues de dispose no emite.
lib/BaseDeDatos/
  connections/db_conexion.dart     DBconeccion.db (sqflite). Implementa ConfigInterface y EnsayosInterface.
  tables/                          SQL de cada tabla (ver Base de datos).
  interfaces/ services/ helpers/   Cadena: DBconeccion -> ServiceConfig/ServiceEnsayos ->
                                   HelpersConfig/HelpersEnsayos (los helpers muestran SnackBar
                                   y actualizan GetX). ServiceEnsayos lo usa EnsayoController.
  helpers/settings/first_data.dart puertosPorDefecto (8001..8009).
lib/Pages/
  Home/homePage.dart               Card con el puerto y el estado de conexion de cada plato (fila del
                                   enganche + 4 filas izq/der), boton "Iniciar ensayo" (ruta 'inicioEnsayo'),
                                   engranaje -> DialogConfig, barra inferior (ver ensayos / compartir XLSX).
  Home/widgets/dialog_config.dart  Un InputTextConfig por plato (9 campos con scroll). OK ->
                                   HelpersConfig.upDateConfig los guarda y reconecta.
  inicio_ensayo/                   InicioEnsayoPage (ruta 'inicioEnsayo'), con scroll: identificacion de la
                                   tolva (obligatoria), TolvaCapacidades (tolva.png centrado, como mucho 55 %
                                   del ancho y 65 % del alto de pantalla, con un campo en kg por celda a los
                                   costados, Positioned segun posicionCelda) y umbral (%). Precarga
                                   PreferenciasEnsayo; Comenzar ensayo valida, avisa las celdas sin
                                   capacidad, guarda, llama iniciarEnsayo y reemplaza la ruta por 'platos'.
  nueve_platos/                    NuevePlatosPage (ruta 'platos', AppBar con la tolva del ensayo; tema verde claro
                                   con _temaPesaje y los colores ThemeApp.pesaje*):
                                   PopScope (salir siempre pide confirmacion con confirmarSalida de dialog_salir.dart;
                                   mensajeSalida arma el texto segun el estado: maniobra en curso que se descarta,
                                   maniobras guardadas, estatico que se pierde; con una maniobra en curso la descarta),
                                   BarraEnsayo fija arriba (Cero general, Tomar estatico, Registrar /
                                   Terminar maniobra con numero y cronometro) y, con scroll, RecuadroPesoTotal, PlatoWidget del
                                   enganche, 4 x FilaPlatos (izq | EjeWidget 'JUEGO N' | der).
                                   Widgets: PlatoWidget
                                   (peso, bateria, estable, conexion, boton > 0 < a 2 px del recuadro del peso
                                   (deshabilitado mientras registra), linea 'E: <estatico>', linea
                                   fila '▼ min' (izq) / '▲ max' (der) dentro del recuadro del peso, siempre
                                   visible: en vivo durante la maniobra, los de la ultima al terminar y '-'
                                   si el ensayo no tuvo ninguna, nivelAlarma: borde y titulo ambar / rojo con alLimite / excede), mostrarResultadoManiobra (dialog_maniobra.dart: dialogo con la
                                   TablaManiobra al terminar), formatoDuracion y descripcionManiobra, EjeWidget, FilaPlatos, RecuadroPesoTotal y
                                   BateryWidget.
  ensayos/                         EnsayosPage (ruta 'ensayos', StatefulWidget; recibe ensayos para los tests):
                                   una TarjetaEnsayo por ensayo (ExpansionTile: tolva, fecha, cantidad de
                                   maniobras; al expandirse, numero, descripcionManiobra y TablaManiobra de cada
                                   maniobra). Deslizar oculta el ensayo y muestra el SnackBar OK / cancel (OK o
                                   timeout lo borran, cancel lo vuelve a mostrar). Borrar todo con DialogBorrar.
  calibracion/                     CalibracionPage(plato:) (ruta 'calibracion', el plato va en los arguments;
                                   servicio e ipPlato inyectables): IP y firmware arriba; sin IP aviso y
                                   Reintentar; lee al abrir (si falla, Leer de nuevo); formulario con los 10
                                   campos (enteros solo digitos, decimales con coma o punto) y la capacidad
                                   maxima solo lectura. Enviar calibracion valida (marca los invalidos y no
                                   envia), confirma, deshabilita mientras envia, avisa y vuelve a leer.
lib/Widgets/                       Comunes: BottonBarApp, IconBottonBarWidget, WidgetButton,
                                   ConnectionWidget, DialogBorrar (titulo, mensaje y onBorrar; cierra con
                                   true si borro) y TablaManiobra (plato, estatico, max, min, FC, % cap y
                                   estado con color; columnas al ancho del contenido, va en scroll horizontal).
lib/generated/ + lib/l10n/         intl (en/es/pt) configurado pero casi sin uso (solo la clave "titulo").
```

Rutas registradas en `main.dart`: `home`, `ensayos`, `platos`, `inicioEnsayo`, `calibracion` (arguments = número de plato). Home -> `inicioEnsayo` ->
(reemplazo) `platos`, así "atrás" desde los platos vuelve al Home.

## Estado y patrones

- Estado con **GetX**: `Get.put` en `main.dart`, `Get.find` en widgets, `Obx` para reactividad. No hay otro gestor de estado.
- Un plato se busca con `Get.find<PesoController>(tag: 'plato$n')`. Para recorrer los platos usar `cantidadPlatos` y `nombrePlato(n)` de `config/platos.dart`, no números sueltos.
- Singletons con constructor privado: `CalculosController.cn`, `Conexion.cn`, `ThemePlatos.cn`, `SizeScreen.sc()`, `DBconeccion.db`.
- Los pesos viajan como `String` con 2 decimales (`"0.00"`); se parsean con `double.tryParse` (un valor inválido cuenta como 0). Porcentajes también como `String`, con 1 decimal.
- Feedback al usuario con `SnackBar` desde los helpers; colores en `ThemePlatos.errorColor` / `positiveColor`.
- Layout responsive a mano con `SizeScreen.sc().screenWidth * factor` y `isMinWidth`.

## Flujo de datos de los platos (WiFi UDP + TCP)

1. `PesoController.recibirPeso()` hace `UDP.bind(Endpoint.any(port: puerto(plato)))`. Un contador `_udpGeneracion` descarta binds viejos (OK repetido en la configuración mientras se abría el socket). Si el bind falla, el timer reintenta mientras `_receiver` siga en null.
2. Cada datagrama pasa por `UdpScaleParser` (`ADC = peso,estable,?,tension` + terminador; se toma lo que sigue al `=`). Las tramas inválidas se descartan con `debugPrint`.
3. Se actualiza `RecibirPesoModel`: peso, estable, tensión (nivel de batería 1..5), `adreess` = IP de origen, `conexion = true`, `contador = 0`. Si el plato está registrando (maniobra), el peso pasa por `registrarLectura`, que lo suma al `RegistroMaxMin` (los pesos inválidos se saltean). Así se comparan todas las tramas, no solo las que dibuja la pantalla.
4. Desconexión y reconexión: el timer de 1 s (arranca en `onInit`, se cancela en `onClose`, corre también en el Home) marca desconexión a los 5 s sin datos. Si ya estaba desconectado, llama `_tryReconnect`, que solo reabre si no hay socket (`_receiver == null`): con el socket abierto, el plato está apagado y no hace falta reabrir. Los 5 s se cuentan desde que termina el intento.
5. Cambio de puertos: `HelpersConfig.upDateConfig` guarda, actualiza `ConfigController` y `_refreshScaleConnections()` llama `recibirPeso()` de los 9 platos.
6. El botón `> 0 <` de `PlatoWidget` llama a `ComandosPlato.enviarCero`, que abre un socket TCP al puerto 80 de la IP del plato (`Conexion.cn`), manda `GET /peso?cero=1` y lo cierra. El número de plato sale del `buttonKeyPlato` ('1'..'9'). Sin IP conocida (el plato nunca mandó datos) no se envía nada. La conexión TCP tiene un timeout de 3 s.
7. El botón **Cero general** de `BarraEnsayo` llama a `ComandosPlato.enviarCeroGeneral`, que manda `enviarCero(n)` de 1 a 9 **en secuencia** (`Conexion.cn` es un solo socket) y devuelve los platos que fallaron. El botón queda deshabilitado mientras manda, y un SnackBar avisa el resultado (los fallidos por `nombrePlato(n)`).
8. Cualquier cero que se envió (el de un plato, o el general con al menos un plato OK) llama `EnsayoController.borrarEstatico()`; si había estático, el SnackBar agrega "Volvé a tomar el estático".
9. **Tomar estático** (`BarraEnsayo`) guarda los 9 pesos actuales como referencia (`tomarEstatico`, 2 decimales, inválido = 0) y pasa el estado a `listo`. Si hay platos desconectados pide confirmación antes. Cero general y Tomar estático se deshabilitan en estado `registrando`.
10. **Registrar maniobra** (`BarraEnsayo`, solo en estado `listo`) llama `EnsayoController.iniciarManiobra()`: los 9 platos registran máx/mín y el estado pasa a `registrando`. Mientras corre, `PlatoWidget` muestra `▼ mín` / `▲ máx` en vivo dentro del recuadro del peso (al terminar quedan los de la última maniobra; descartarla los borra), los `> 0 <` se deshabilitan y la barra muestra el número de maniobra y el tiempo. Mientras registra, la pantalla no se apaga (`wakelock_plus`). **Terminar maniobra** llama `terminarManiobra()`, que guarda la maniobra en la base (la primera del ensayo inserta antes la fila de `tensayos`); `HelpersEnsayos.avisarGuardado` avisa con un SnackBar si se guardó y después se muestra el diálogo con la `TablaManiobra`.
11. **Alarma**: en cada `Obx`, `EnsayoController.alarma(n, ...)` compara el máximo de la maniobra (o el peso actual si no hay maniobra o todavía no llegaron lecturas) con la capacidad de la celda y el umbral (`estadoCelda`). `PlatoWidget` pinta el borde y el título en ámbar (al límite) o rojo (excede), con los colores de `TablaManiobra.colorEstado`. Sin capacidad no hay alarma.

## Base de datos (sqflite, `platos.db`, versión 4)

`onCreate` crea todo el esquema. `onUpgrade` con `oldVersion < 2` crea las tablas de ensayos (la v1 solo tenía
`tconfig` y las pesadas) y con `oldVersion < 3` hace `DROP TABLE IF EXISTS` de `tpesadas_9platos` y `tpesadas_base`
(las pesadas de la app vieja se pierden; `tconfig` se conserva). Con `oldVersion < 4` agrega a `tconfig` las columnas
`platoN` que falten (`DBconfig.completarColumnas`, con el puerto por defecto): una base creada en v1 tenía la tabla de 4
platos y el `UPDATE` de la configuración fallaba con "no such column: plato5".

| Tabla | Contenido |
|---|---|
| `tconfig` | Una sola fila (`id = 1`): `plato1..plato9` con los puertos (por defecto 8001..8009). |
| `tensayos` | `id`, `tolva`, `fecha` (dd/MM/yyyy, la de la primera maniobra), `created_at` (ISO 8601). |
| `tmaniobras` | `id`, `ensayo_id` (FK a `tensayos` `ON DELETE CASCADE`, con índice), `numero`, `hora_inicio` / `hora_fin` (HH:mm:ss), `duracion_ms`, `umbral` (copiado del ensayo). |
| `tmaniobras_platos` | PK (`maniobra_id`, `plato`), FK a `tmaniobras` `ON DELETE CASCADE`: `estatico`, `maximo`, `minimo`, `lecturas`, `capacidad` (copiada del ensayo). |

- Ensayos: `insertEnsayo` (cabecera, devuelve el id o -1), `insertManiobra` (cabecera + 9 platos en una transacción,
  id o -1), `getEnsayos` (id descendente, con sus maniobras por número y sus platos) y `deleteEnsayo` /
  `deleteManiobra` / `deleteEnsayos`, que confían en el CASCADE. Los lee `EnsayosPage` (historial).
- `PRAGMA foreign_keys = ON` se ejecuta en `onConfigure`, o sea en cada apertura (en sqflite el pragma es por conexión).
- Si hace falta cambiar el esquema: subir `dbVersion` y escribir `onUpgrade`, o desinstalar la app en el dispositivo de prueba.

## Guardado, historial y exportación

Ya no hay pesadas (se quitaron en el paso 13 del plan de ensayo): solo se guardan las maniobras, en las tablas de ensayos.

1. `NuevePlatosPage` recalcula el total y los % en vivo en cada `Obx` (`setPesoTotalByList` con los 9 pesos); no se guardan.
2. Historial: el botón del Home lleva a `EnsayosPage` (ruta `ensayos`).
3. Exportación de ensayos: `compartirArchivo` (botón compartir del Home) llama `Exportar.writeFileEnsayos`, que genera `ensayos.xlsx` (en `getExternalStorageDirectory()` en Android) con la hoja `maniobras`, **una fila por maniobra y plato**, de los ensayos más viejos a los más nuevos (`Exportar.filasEnsayos`): `ensayo_id`, `tolva`, `fecha`, `maniobra`, `hora_inicio`, `hora_fin`, `duracion_s` (1 decimal), `plato`, `nombre`, `capacidad`, `estatico`, `maximo`, `minimo`, `lecturas`, `factor_cresta`, `por_cap` y `estado` (con el umbral copiado en la maniobra). El encabezado sale de las claves de `ManiobraModel.toExportRows`. Devuelve 1, 0 sin maniobras o -1 si falla; con 0 o -1 un SnackBar avisa y no se comparte. Si no, lo comparte con share_plus (asunto "Balanzas Hook, ensayo 9 platos").

## Tests

- `test/controllers/calculos_9platos_test.dart`: total, subtotal de juego, porcentajes de plato, juego y lado, total cero y pesos inválidos.
- `test/BaseDeDatos/settings/db_config_test.dart`: SQL de `DBconfig.completarColumnas` (tabla de 4 platos y tabla completa).
- `test/BaseDeDatos/ensayos/service_ensayos_test.dart`: `ServiceEnsayos` contra `test/moks/db_ensayos_mock.dart` (base en memoria con ids, orden descendente, cascada y `fallar` para simular -1).
- `test/Providers/ensayos_provider_test.dart`: `EnsayosProvider` contra `DbEnsayosMock` (emite sin oyente, borrar uno y todos, después de `dispose`).
- `test/widgets/ensayos/ensayos_page_test.dart`: `EnsayosPage` en un teléfono angosto (tarjetas, expandir con las tablas, deslizar con cancel y OK, borrar todo).
- `test/Models/ensayo_model_test.dart`: `toDb` / `fromDb` de `EnsayoModel`, `ManiobraModel` y `ManiobraPlato`, y `copyWith`.
- `test/Models/maniobra_export_test.dart`: orden de columnas y valores de `ManiobraModel.toExportRows` (ejemplo del documento, plato sin capacidad ni lecturas) y orden de `Exportar.filasEnsayos`.
- `test/Models/recibir_peso_model_test.dart` y `test/widgets/home/batery_widget_test.dart`: batería.
- `test/controllers/ensayo_controller_test.dart`: valores iniciales de `EnsayoController`, `iniciarEnsayo`, `tomarEstatico` (con `leerPesos` inyectado), `borrarEstatico`, iniciar / terminar / descartar maniobra (con `platos` inyectado), pantalla encendida durante la maniobra (con `pantallaEncendida` inyectado), guardado de las maniobras (con `ensayos` inyectado: un ensayo por tolva, umbral y capacidad copiados, reintento si falla) y `alarma` (peso actual, máximo durante la maniobra, sin capacidad, umbral del ensayo).
- `test/widgets/nueve_platos/plato_widget_alarma_test.dart`: colores del título y el borde de `PlatoWidget` según `nivelAlarma`, en un teléfono chico sin desbordes, y el mínimo (izq) y máximo (der) dentro del plato (con valores y con `-`).
- `test/Models/calibracion_model_test.dart`: parseo clásico (ejemplo del documento con `correccion` entero) y ESP32 (ejemplo, tabla de `floatDesdeU64`, `type` que no es `u64`, `kgFiltroMov` truncado, sin `Configuracion.Balanza`), `toSaveQuery` (nombres, orden, `10.0`, sin capacidad), `completa` y `copyWith`.
- `test/Models/maniobra_plato_test.dart`: factor de cresta, % cap y estado (ejemplo del documento, = umbral, = 100 %, > 100 %, capacidad vacía o 0, estático 0, sin lecturas, redondeo).
- `test/widgets/nueve_platos/dialog_maniobra_test.dart`: `formatoDuracion` y el diálogo con la tabla en un teléfono angosto.
- `test/widgets/nueve_platos/dialog_salir_test.dart`: `mensajeSalida` en cada situación (sin maniobras, con estático, maniobras guardadas, maniobra en curso).
- `test/domain/registro_max_min_test.dart`: secuencia de pesos, primera lectura, negativos y reinicio.
- `test/controllers/peso_controller_registro_test.dart`: `iniciarRegistro` / `registrarLectura` / `detenerRegistro` / `limpiarRegistro` de `PesoController` (sin UDP).
- `test/Providers/calibracion_wifi_test.dart`: `CalibracionWifi` con `MockClient` (lectura clásica, fallback a ESP32 por excepción, 404, JSON inválido y timeout, ESP32 inválido, los dos fallan; envío con la URL del documento y el reset, reset que falla, código ≠ 200 y error de red sin reset, modelo incompleto sin peticiones).
- `test/widgets/calibracion/calibracion_page_test.dart`: `CalibracionPage` en un teléfono angosto con servicio falso (valores leídos, campo que no vino, sin IP y Reintentar, error de lectura, campo inválido que no envía, envío del modelo editado con botones deshabilitados y relectura, envío fallido, cancelar).
- `test/helpers/comandos_plato_test.dart`: `ComandosPlato.ipPlato` (IP conocida, `'0'` o vacío, plato no registrado).
- `test/helpers/preferencias_ensayo_test.dart`: `PreferenciasEnsayo` con `SharedPreferences.setMockInitialValues` (valores por defecto, guardar y leer, claves).
- `integration_test/app_test.dart` está vacío.

## Pendientes conocidos

- `ConnectionWidget` muestra siempre un ícono de WiFi (solo visual, heredado de cuando había BLE).
- `Conexion.enviarCalibracion` no tiene UI que lo use.
- No hay pruebas automáticas de UDP ni de la base real (sqflite); se prueban con las balanzas en un teléfono (ver la verificación en `docs/plan_9_platos.md` y `docs/plan_ensayo.md`).

## Legacy y trampas

- `HelpersConfig.upDateConfig` hace `Navigator.pop` antes de guardar. `HelpersConfig.guardarConfig` (insert) quedó de la app vieja; la configuración se crea en `main.dart`.
- En `CalculosController` quedaron nombres de la época de ejes: `calculoPorcentajePorEje` calcula el % de un juego y `EjeWidget` dibuja el recuadro "JUEGO N" (usa `calculoEje`).
- `RecibirPesoModel.setTension` convierte voltios en nivel 1..5 con `Bateria.porcentaje`; `BateryWidget` dibuja el ícono según ese nivel.
- Hay dos temas (`ThemeApp` en `config/theme.dart` y `ThemePlatos` en `Theme/theme.dart`); se usan mezclados.
- `assets/` tiene splash viejos (`splashviejo.png`, `splash12viejo.png`) que no usa el código.
- `.github/modernize/` es basura de una extensión de VS Code (Java upgrade), no CI del proyecto.

## Documentación de referencia

- `README.md`: descripción e historial.
- `docs/plan_9_platos.md`: plan de la reforma de 4 a 9 platos (PRs 1..10) y checklist de verificación con las balanzas.
- `docs/plan_ensayo.md`: plan **pendiente** del modo ensayo de tolva (inicio con tolva y capacidad nominal por celda sobre `assets/tolva.png`, guardadas en SharedPreferences; estático, maniobra con máx/mín, alarma, historial de ensayos). Se implementa de a un paso por PR; leer el paso pedido antes de empezar.
- `docs/CALIBRACION_WIFI.md`: protocolo HTTP de lectura (`/config?json=1` clásico, `/configjson?json=1` ESP32) y
  envío (`/save`) de la calibración del indicador.
- `docs/plan_calibracion.md`: plan de la calibración de cada plato por WiFi (modelos de parseo, servicio HTTP,
  pantalla de calibración y botón en la configuración). Se implementa de a un paso por PR.
