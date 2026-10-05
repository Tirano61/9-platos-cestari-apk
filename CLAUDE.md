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
- Cálculos: peso y % de cada plato, subtotal y % de cada juego, lado izq (2+4+6+8) y lado der (3+5+7+9) con su %, y total. El enganche no suma a ningún lado.
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
- Dependencias principales: `get`, `udp`, `sqflite`, `shared_preferences`, `excel`, `share_plus`, `path_provider`, `permission_handler`, `intl`, `flutter_native_splash`.

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

Estado de `flutter analyze` al 05/10/2026: 0 errores, 0 warnings, 3 `info` preexistentes (`file_names` en `homePage.dart` y `SizeScreen.dart`, `withOpacity` deprecado en `nueve_platos_page.dart`). No introducir nuevos; no hace falta corregir estos salvo que se pida. `flutter test`: 38 tests en verde.

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
                                   RegistroMaxMin) y Rx maximo / minimo / lecturas para la UI.
  calculos_controllers.dart        Singleton CalculosController.cn: total (setPesoTotalByList /
                                   pesoTotal), porcentajes, fecha/hora y calcularPayload9Platos(pesos).
  ensayo_controller.dart           EnsayoController (Get.put en main.dart): tolva, capacidades (9 String,
                                   '' = sin alarma) y umbral del ensayo en curso; iniciarEnsayo(...).
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
  pesadas/                         PesadaBase (cabecera), Pesada9PlatosDetalle (enganche, j1Izq..j4Der,
                                   juego1..4, ladoIzq/Der y un por* por cada uno; toDb/fromDb) y
                                   Pesada9PlatosPayload (base + detalle; toExportRow arma la fila XLSX).
lib/helpers/
  comandos_plato.dart              ComandosPlato.enviarCero(plato): TCP a la IP del plato.
                                   enviarCeroGeneral(): cero a los 9 en secuencia; devuelve los que fallaron.
  exportar_xml.dart                A pesar del nombre exporta XLSX (pesadas.xlsx) y lo comparte.
  bateria.dart                     Bateria.porcentaje(voltios): 3.0 V = 0 %, 4.2 V = 100 %.
  preferencias_ensayo.dart         PreferenciasEnsayo: capacidad nominal de cada celda y umbral de alarma en
                                   SharedPreferences (leerCapacidades / leerUmbral / guardar). Los usa InicioEnsayoPage.
lib/Providers/
  tcp_conexion.dart                Conexion.cn: socket TCP al puerto 80 de la IP del plato; manda cero
                                   (y calibracion, sin uso) por HTTP GET. No usarlo directo
                                   desde la UI: pasar por ComandosPlato.
  pesadas/                         PesadasProvider -> ServiceProvider: stream de
                                   List<Pesada9PlatosPayload> para el historial.
lib/BaseDeDatos/
  connections/db_conexion.dart     DBconeccion.db (sqflite). Implementa PesadasInterface y ConfigInterface.
  tables/                          SQL de cada tabla (ver Base de datos).
  interfaces/ services/ helpers/   Cadena: DBconeccion -> ServicePesadas/ServiceConfig -> HelpersPesadas/
                                   HelpersConfig (los helpers muestran SnackBar y actualizan GetX).
  helpers/settings/first_data.dart puertosPorDefecto (8001..8009).
lib/Pages/
  Home/homePage.dart               Card con el puerto y el estado de conexion de cada plato (fila del
                                   enganche + 4 filas izq/der), boton "Iniciar ensayo" (ruta 'inicioEnsayo'),
                                   engranaje -> DialogConfig, barra inferior (ver pesadas / compartir XLSX).
  Home/widgets/dialog_config.dart  Un InputTextConfig por plato (9 campos con scroll). OK ->
                                   HelpersConfig.upDateConfig los guarda y reconecta.
  inicio_ensayo/                   InicioEnsayoPage (ruta 'inicioEnsayo'), con scroll: identificacion de la
                                   tolva (obligatoria), TolvaCapacidades (tolva.png centrado, como mucho 55 %
                                   del ancho y 65 % del alto de pantalla, con un campo en kg por celda a los
                                   costados, Positioned segun posicionCelda) y umbral (%). Precarga
                                   PreferenciasEnsayo; Comenzar ensayo valida, avisa las celdas sin
                                   capacidad, guarda, llama iniciarEnsayo y reemplaza la ruta por 'platos'.
  nueve_platos/                    NuevePlatosPage (ruta 'platos', AppBar con la tolva del ensayo):
                                   BarraEnsayo fija arriba (Cero general)
                                   y, con scroll, RecuadroPesoTotal, PlatoWidget del
                                   enganche, 4 x FilaPlatos (izq | EjeWidget 'JUEGO N' | der) y SumaLados.
                                   FAB Guardar -> DialogWidget (identificacion). Widgets: PlatoWidget
                                   (peso, bateria, estable, conexion, boton > 0 <), EjeWidget,
                                   FilaPlatos, SumaLados, RecuadroPesoTotal, BateryWidget, DialogWidget.
  pesadas/                         PesadasPage (ruta 'pesadas'): lista con Dismissible para borrar,
                                   exportar XLSX, borrar todo (DialogBorrar). ItemsPesadas: datos de la
                                   pesada | enganche, 4 filas (J izq | Juego N | J der) y lados, cada uno
                                   con PlatoPesadas (peso y %).
lib/Widgets/                       Comunes: BottonBarApp, IconBottonBarWidget, WidgetButton,
                                   ConnectionWidget.
lib/generated/ + lib/l10n/         intl (en/es/pt) configurado pero casi sin uso (solo la clave "titulo").
```

Rutas registradas en `main.dart`: `home`, `pesadas`, `platos`, `inicioEnsayo`. Home -> `inicioEnsayo` ->
(reemplazo) `platos`, así "atrás" desde los platos vuelve al Home.

## Estado y patrones

- Estado con **GetX**: `Get.put` en `main.dart`, `Get.find` en widgets, `Obx` para reactividad. No hay otro gestor de estado.
- Un plato se busca con `Get.find<PesoController>(tag: 'plato$n')`. Para recorrer los platos usar `cantidadPlatos` y `nombrePlato(n)` de `config/platos.dart`, no números sueltos.
- Singletons con constructor privado: `CalculosController.cn`, `Conexion.cn`, `ThemePlatos.cn`, `SizeScreen.sc()`, `DBconeccion.db`.
- Los pesos viajan como `String` con 2 decimales (`"0.00"`); se parsean con `double.tryParse` (un valor inválido cuenta como 0). Porcentajes también como `String`, con 1 decimal.
- `tipoPesada` es siempre `'9_platos'`.
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

## Base de datos (sqflite, `platos.db`, versión 1)

Esquema creado desde cero en `onCreate`; `onUpgrade` está vacío porque la app se instaló como nueva.

| Tabla | Contenido |
|---|---|
| `tconfig` | Una sola fila (`id = 1`): `plato1..plato9` con los puertos (por defecto 8001..8009). |
| `tpesadas_base` | Cabecera: `id`, `fecha` (dd/MM/yyyy), `hora` (HH:mm), `identificacion`, `tipo_pesada`, `total`, `created_at` (ISO 8601). Índices por `fecha` y `tipo_pesada`. |
| `tpesadas_9platos` | Detalle 1:1 (`pesada_id` PK y FK a `tpesadas_base(id)` `ON DELETE CASCADE`): `enganche`, `j1_izq`..`j4_der`, `juego1..4`, `lado_izq`, `lado_der` y un `por_*` por cada uno. |

- `insertPesada9Platos` inserta cabecera y detalle en una transacción y devuelve el id, o -1 si falla.
- `getPesadas9Platos` devuelve `List<Pesada9PlatosPayload>` ordenada por id descendente (historial). `getPesadasExportacion` devuelve las mismas pesadas como filas de `toExportRow`.
- El borrado (`deletePesada(id)` / `deletePesadas()`) se hace solo sobre `tpesadas_base` y confía en el CASCADE.
- `PRAGMA foreign_keys = ON` se ejecuta en `onConfigure`, o sea en cada apertura (en sqflite el pragma es por conexión).
- Si hace falta cambiar el esquema: subir `dbVersion` y escribir `onUpgrade`, o desinstalar la app en el dispositivo de prueba.

## Guardado, historial y exportación

1. `NuevePlatosPage` recalcula el total en cada `Obx` (`setPesoTotalByList` con los 9 pesos) y el FAB Guardar llama `CalculosController.cn.calcularPayload9Platos(pesos: ...)` con los pesos en orden de plato.
2. Abre `DialogWidget` pidiendo identificación; `onConfirm` llama `HelpersPesadas.guardarPesada9PlatosPayload`, que inserta vía `ServicePesadas` y muestra SnackBar.
3. Historial: `PesadasPage` lee `getPesadas9Platos()` a través de `PesadasProvider`. Al deslizar una tarjeta aparece un SnackBar: OK o timeout borran la pesada, cancel la conserva.
4. Exportación: `Exportar.writeFile` genera `pesadas.xlsx` (en `getExternalStorageDirectory()` en Android) con una sola hoja `9_platos`: `id`, `fecha`, `hora`, `identificacion`, `total` y las columnas de `tpesadas_9platos` (sin `pesada_id`). El encabezado sale de las claves de `toExportRow`. Sin pesadas devuelve -1.
5. `compartirArchivo` (botón compartir del Home) comparte el último `pesadas.xlsx` generado con share_plus (asunto "Balanzas Hook, 9 platos").

## Tests

- `test/controllers/calculos_9platos_test.dart`: total, pesos por plato, juegos, lados, porcentajes, total cero y pesos inválidos.
- `test/Models/pesada_9platos_payload_test.dart`: fila y orden de columnas de `toExportRow`.
- `test/BaseDeDatos/pesadas/services/service_pesadas_test.dart`: `ServicePesadas` contra `test/moks/db_connection_mock.dart`.
- `test/Models/recibir_peso_model_test.dart` y `test/widgets/home/batery_widget_test.dart`: batería.
- `test/controllers/ensayo_controller_test.dart`: valores iniciales de `EnsayoController` e `iniciarEnsayo`.
- `test/domain/registro_max_min_test.dart`: secuencia de pesos, primera lectura, negativos y reinicio.
- `test/controllers/peso_controller_registro_test.dart`: `iniciarRegistro` / `registrarLectura` / `detenerRegistro` de `PesoController` (sin UDP).
- `test/helpers/preferencias_ensayo_test.dart`: `PreferenciasEnsayo` con `SharedPreferences.setMockInitialValues` (valores por defecto, guardar y leer, claves).
- `test/list_pesajes/list_pesaje.dart`: pesada de ejemplo (`pesada9PlatosEjemplo`) y su fila de exportación esperada (`listPesaje`), usadas por el mock y los tests.
- `integration_test/app_test.dart` está vacío.

## Pendientes conocidos

- `ConnectionWidget` muestra siempre un ícono de WiFi (solo visual, heredado de cuando había BLE).
- `Conexion.enviarCalibracion` no tiene UI que lo use.
- No hay pruebas automáticas de UDP ni de la base real (sqflite); se prueban con las balanzas en un teléfono (ver la verificación en `docs/plan_9_platos.md`).

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
