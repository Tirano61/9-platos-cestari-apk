# CLAUDE.md — Platos Cestari (Balanzas Hook)

Referencia rápida del proyecto para trabajar con Claude Code. Código, comentarios, commits y esta guía están en español.

## Reforma en curso: 9 platos por WiFi UDP

Este repo arrancó como copia de la app "Cuatro Platos" y se está reformando para Cestari. La app final pesa una tolva de 3 ejes con **9 celdas** y **solo WiFi UDP** (una balanza por puerto, 8001..8009, mismo protocolo UDP de hoy). Las 9 celdas son:

- plato 1: enganche;
- platos 2..9: 4 juegos de celdas izq/der (J1 = platos 2/3, J2 = 4/5, J3 = 6/7, J4 = 8/9). Los juegos no corresponden a ejes.

Se quitan BLE y el pesaje por ejes. Cero y reset hold se mantienen por TCP. App nueva:

- package Dart `nueve_platos_cestari`;
- `applicationId` `com.dramirez.nueveplatoscestari`;
- label "Platos Cestari";
- base de datos desde cero.

**El plan paso a paso, con un PR por paso, está en [docs/plan_9_platos.md](docs/plan_9_platos.md).** Seguir ese orden y marcar cada paso al terminarlo.

Lo que sigue en este archivo todavía describe el código heredado (4 platos). BLE se quitó en el PR 3, el pesaje por ejes en el PR 4 y los 4 controllers de peso se unificaron en el PR 5. Cada PR del plan actualiza la sección que toca, y el PR 10 lo reescribe completo.

## Qué es la app (código heredado)

App Flutter (Android es el único target real) para pesar vehículos con balanzas inalámbricas de plataforma ("platos") de Balanzas Hook. Un solo modo de pesaje: **4 platos**, un plato por rueda (DEL IZQ, DEL DER, TRAS IZQ, TRAS DER). Calcula peso por eje, por lado, porcentajes y total.

Cada plato se conecta por **WiFi (UDP)**: emite datagramas UDP a un puerto configurado (8001..8004 por defecto). Cero y reset hold se envían por TCP a la IP del plato.

La app no va al Play Store. `applicationId`/namespace `com.dramirez.nueveplatoscestari` (se instala como app nueva, separada de la vieja "Platos"). Versión en `pubspec.yaml`: `1.0.1+1`. Nombre del package Dart: `nueve_platos_cestari`. Label Android y título: "Platos Cestari".

## Ramas y flujo de trabajo

- `main` es la rama principal (`origin/main`) y la base de todos los PRs.
- Flujo: rama feature corta con nombre camelCase (los nombres de cada paso están en `docs/plan_9_platos.md`) → PR → merge a `main`. Commits en español, una línea.
- Remotos:
  - `origin` = Balanzas-Hook/9-platos-cestari-apk;
  - `gittirano` = Tirano61/9-platos-cestari-apk (espejo).
- Las ramas de la app vieja (`porEjes`, `conexionBLE`) no existen en este repo.

## Toolchain y comandos

- Flutter fijado con FVM: `3.41.6` (`.fvmrc`). Dart SDK `>=3.0.0`. VS Code usa `.fvm/flutter_sdk`.
- `fvm` es un `.bat` (Pub cache): funciona desde PowerShell/cmd, no desde Git Bash. Desde Git Bash usar `.fvm/flutter_sdk/bin/flutter.bat`.
- Android: AGP 8.11.1, Kotlin 2.2.20, `minifyEnabled true` en release, firma con `android/key.properties`.
- `android/key.properties` y `local.properties` están versionados en git (el primero con credenciales del keystore). No los toques ni los muestres salvo que se pida.

```powershell
fvm flutter pub get
fvm flutter analyze
fvm flutter test
fvm flutter run                      # dispositivo Android conectado
fvm flutter build apk --debug
fvm flutter build apk --release      # usa android/key.properties
fvm dart run flutter_native_splash:create   # regenerar splash (assets/splash*.png, color #153a65)
```

Para probar la conexión real hacen falta las balanzas físicas: UDP no se puede simular desde el emulador sin las antenas.

Estado de `flutter analyze` al 02/10/2026: 0 errores, 0 warnings, 6 `info` preexistentes (`use_build_context_synchronously` en helpers_pesadas, `file_names` en `homePage.dart` y `SizeScreen.dart`, `withOpacity` deprecado en cuatro_platos_page, 2 × `prefer_typing_uninitialized_variables` en fila_platos). No introducir nuevos; no hace falta corregir estos salvo que se pida.

## Mapa del código (`lib/`)

Las carpetas viejas usan mayúscula inicial (`Controllers`, `Pages`, `BaseDeDatos`, `Providers`, `Widgets`, `Theme`); las nuevas usan minúscula (`data`, `domain`, `models`, `helpers`, `config`). Mantener el estilo de la carpeta donde se toca.

```
lib/main.dart                      Bootstrap: Get.put de todos los controllers, carga config de DB,
                                   registra un PesoController por plato (tag 'plato1'..'plato4'),
                                   arranca recibirPeso() de cada uno, define rutas.
lib/Controllers/
  config_controller.dart           Lista de RxString con los puertos: puerto(n) / setPuerto(n, v),
                                   cantidadPlatos (hoy 4).
  peso_controller.dart             PesoController(plato: n), uno por plato. Escucha UDP, actualiza
                                   pesoModel (RecibirPesoModel), timer de 1 s que marca
                                   desconexion a los 5 s sin datos y reabre el socket si hace falta.
                                   Get.find<PesoController>(tag: 'plato$n').
  calculos_controllers.dart        Singleton CalculosController.cn: totales, porcentajes, fecha/hora y
                                   armado del payload tipado (Pesada4PlatosPayload).
lib/data/
  udp/udp_scale_parser.dart        Parsea datagrama "ADC = peso,estable,x,tension" -> ScaleReading.
lib/domain/
  entities/scale_reading.dart      Lectura normalizada (peso, estable, tension, sourceId).
lib/Providers/
  tcp_conexion.dart                Conexion.cn: socket TCP puerto 80 a la IP del plato para enviar
                                   cero / reset hold / calibracion por HTTP GET. No usarlo directo
                                   desde la UI: pasar por ComandosPlato.
  pesadas/                         PesadasProvider: stream de List<Pesaje> para el historial.
lib/BaseDeDatos/
  connections/db_conexion.dart     DBconeccion.db (sqflite, archivo platos.db, dbVersion 1). Implementa
                                   PesadasInterface y ConfigInterface.
  tables/                          SQL de cada tabla (ver seccion Base de datos).
  interfaces/ services/ helpers/   Cadena: DBconeccion -> ServicePesadas/ServiceConfig -> HelpersPesadas/
                                   HelpersConfig (los helpers muestran SnackBar y actualizan GetX).
lib/models/
  config_model.dart                ConfigModel: puertos plato1..plato4. Claves JSON = columnas tconfig.
  recibir_peso_model.dart          Estado Rx de un plato: peso, estable, tension (nivel 1..5), adreess, conexion.
  pesaje_model.dart                Pesaje: modelo MIXTO legacy que todavia usan historial y exportacion.
  pesadas/                         Modelos nuevos: PesadaBase, Pesada4PlatosDetalle, payload.
lib/Pages/
  Home/homePage.dart               Card con el puerto y el estado de conexion de cada plato, boton
                                   "Iniciar Pesaje" (ruta 'platos'), barra inferior (ver pesadas /
                                   compartir XLSX).
  Home/widgets/dialog_config.dart  Configuracion: un puerto por plato. Solo OK -> HelpersConfig.upDateConfig
                                   los guarda y reconecta.
  cuatro_platos/                   CuatroPlatosPage + widgets compartidos (PlatoWidget, EjeWidget,
                                   FilaPlatos, SumaLados con chasis.png, RecuadroPesoTotal, BateryWidget,
                                   DialogWidget para pedir identificacion al guardar).
  pesadas/                         Historial: lista con Dismissible para borrar, exportar XLSX, borrar todo.
lib/helpers/exportar_xml.dart      A pesar del nombre exporta XLSX (pesadas.xlsx) y lo comparte con share_plus.
lib/helpers/comandos_plato.dart    ComandosPlato.enviarCero / enviarResetHold(plato): TCP a la IP del plato.
lib/config/ + lib/Theme/           Dos clases de tema (ThemeApp y ThemePlatos) y SizeScreen (singleton,
                                   isMinWidth = pantalla >= 420 px, se usa como "tablet vs telefono").
lib/generated/ + lib/l10n/         intl configurado pero casi sin uso (solo la clave "titulo").
```

Rutas registradas en `main.dart`: `home`, `pesadas`, `platos`.

## Estado y patrones

- Estado con **GetX**: `Get.put` en `main.dart`, `Get.find` en widgets, `Obx` para reactividad. No hay otro gestor de estado.
- Singletons con constructor privado: `CalculosController.cn`, `Conexion.cn`, `ThemePlatos.cn`, `SizeScreen.sc()`, `DBconeccion.db`.
- Los pesos viajan como `String` con 2 decimales (`"0.00"`); se parsean con `double.tryParse` para calcular. Porcentajes también como `String`.
- `tipoPesada` es siempre `'4_platos'` (pasa a `'9_platos'` en el PR 7).
- Feedback al usuario con `SnackBar` desde los helpers; colores en `ThemePlatos.errorColor` / `positiveColor`.
- Layout responsive a mano con `SizeScreen.sc().screenWidth * factor` y `isMinWidth`.

## Flujo de datos de los platos (WiFi / UDP)

1. `PesoController.recibirPeso()` hace `UDP.bind(Endpoint.any(port: puerto(plato)))`. Un contador `_udpGeneracion` descarta binds viejos (OK repetido mientras se abría el socket). Si el bind falla, el timer lo reintenta a los 5 s mientras `_receiver` siga en null.
2. Cada datagrama pasa por `UdpScaleParser` (`ADC = peso,estable,?,tension` + terminador; se toma lo que sigue al `=`).
3. Se actualiza `RecibirPesoModel`: `adreess` = IP de origen del datagrama, `conexion = true`, `contador = 0`.
4. Reconexión: el timer de cada controller (arranca en `onInit`, se cancela en `onClose`, corre también en el Home) marca desconexión a los 5 s sin datos. Si ya estaba desconectado, llama `_tryReconnect`, que solo reabre si no hay socket (`_receiver == null`). Los 5 s se cuentan desde que termina el intento.
5. Los botones `> 0 <` y `< H >` de `PlatoWidget` llaman a `ComandosPlato`, que abre un socket TCP al puerto 80 de esa IP (`Conexion.cn`) y manda `GET /peso?cero=1` o `GET /peso?resethold=1`. El número de plato sale del `buttonKeyPlato` ('1'..'4').

## Base de datos (sqflite, `platos.db`, versión 1)

Esquema nuevo creado desde cero en `onCreate` (sin `onUpgrade`, porque la app se instala como nueva):

| Tabla | Contenido |
|---|---|
| `tconfig` | Una sola fila (`id = 1`): `plato1..plato4` (puertos). |
| `tpesadas_base` | Cabecera común: fecha, hora, identificacion, `tipo_pesada`, total, created_at. Índices por fecha y tipo. |
| `tpesadas_4platos` | Detalle 1:1 de 4 platos (pesos, ejes, lados y porcentajes). FK `ON DELETE CASCADE`. |

- Inserción en transacción (`insertPesada4Platos`). `getPesadas` delega en `getPesadas4Platos`. El borrado se hace solo sobre `tpesadas_base` y confía en el CASCADE.
- `PRAGMA foreign_keys = ON` se ejecuta solo dentro de `onCreate`. En sqflite ese pragma es por conexión, así que en aperturas posteriores puede no estar activo: si se ven filas huérfanas, moverlo a `onConfigure`.
- `lib/BaseDeDatos/tables/db_pesadas.dart` (tabla `tpesadas`) es legacy: ya no se crea, solo lo referencia un test.
- Si hace falta cambiar el esquema: subir `dbVersion` y escribir `onUpgrade`, o desinstalar la app en el dispositivo de prueba.
- Plan y bitácora completa de la reforma: `docs/cambios_db.md` (todas las fases marcadas como hechas el 24/08/2026).

## Flujo de guardado de una pesada

1. La pantalla llama `CalculosController.cn.calcularPayload4Platos(...)`.
2. Abre `DialogWidget` pidiendo identificación; `onConfirm` llama `HelpersPesadas.guardarPesada4PlatosPayload`.
3. El helper inserta vía `ServicePesadas` y muestra SnackBar.
4. El historial (`PesadasPage`) lee con `getPesadas()`, que devuelve `Pesaje` legacy.
5. Exportación: `Exportar.writeFile` genera `pesadas.xlsx` con una sola hoja `4_platos`. `compartirArchivo` lo comparte con share_plus.

## Pendientes conocidos

- `ConnectionWidget` muestra siempre un ícono de WiFi (solo visual).

## Legacy y trampas

- `Pesaje` (`lib/models/pesaje_model.dart`) sigue siendo el modelo de lectura del historial y de la exportación (se quita en el PR 9).
- `HelpersConfig.upDateConfig` hace `Navigator.pop` antes de guardar y luego `_refreshScaleConnections()` reconecta los 4 platos.
- `lib/BaseDeDatos/pesadas_export.dart` está vacío.
- Tests que fallan desde antes (se resuelven en el PR 9 del plan): `test/BaseDeDatos/pesadas_export_test.dart` está vacío (sin `main`, y al compilarlo tira abajo también `service_pesadas_test` si se corren juntos) y `db_pesadas_test` espera largo 481 de la tabla legacy y hoy mide 607.
- `test/BaseDeDatos/pesadas/tables/db_pesadas_test.dart` testea la tabla legacy `tpesadas`.
- `integration_test/app_test.dart` y `test/BaseDeDatos/pesadas_export_test.dart` están vacíos.
- `RecibirPesoModel.setTension` convierte voltios de batería en nivel 1..5 (`Bateria.min = 2.5`, rango 1.7 V); `BateryWidget` dibuja el ícono según ese nivel.
- Hay dos temas (`ThemeApp` en `config/theme.dart` y `ThemePlatos` en `Theme/theme.dart`); se usan mezclados.
- `.github/modernize/` es basura de una extensión de VS Code (Java upgrade), no CI del proyecto.

## Documentación de referencia

- `README.md`: historial de ramas.
- `docs/cambios_db.md`: plan de la reforma de DB, decisiones de producto y bitácora por fases.
