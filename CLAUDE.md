# CLAUDE.md — Cuatro Platos (Balanzas Hook)

Referencia rápida del proyecto para trabajar con Claude Code. Código, comentarios, commits y esta guía están en español.

## Qué es la app

App Flutter (Android es el único target real) para pesar vehículos con balanzas inalámbricas de plataforma ("platos") de Balanzas Hook. Dos modos de pesaje:

- **4 platos**: un plato por rueda (DEL IZQ, DEL DER, TRAS IZQ, TRAS DER). Calcula peso por eje, por lado, porcentajes y total.
- **2 platos por ejes**: solo los platos 1 y 2 (DEL IZQ / DEL DER). El vehículo avanza eje por eje (2 a 6 ejes) y se guarda cada eje; al final se guarda la pesada completa.

Cada plato se conecta a la app de una de dos formas, elegida globalmente en la configuración:

- **WiFi (UDP)**: modo histórico. Cada plato emite datagramas UDP a un puerto configurado (8001..8004 por defecto). Debe seguir funcionando siempre.
- **Bluetooth LE**: modo nuevo, en desarrollo en esta rama. Cada plato es un periférico BLE identificado por nombre.

La app no va al Play Store. Se cambió el `applicationId` a `com.dramirez.cuatroplatosejes` para que se instale como app nueva junto a la vieja, sin migrar datos (ver `docs/cambios_db.md`). Versión actual en `pubspec.yaml`: `3.0.1+5`. Nombre del package Dart: `cuatro_platos`. Label Android: "Platos".

## Ramas y flujo de trabajo

- `main`: versión vieja de 4 platos con puertos (obsoleta).
- `porEjes`: rama principal hasta julio 2026 (base de PRs según origin/HEAD).
- `conexionBLE`: rama actual de trabajo. Contiene la reforma de DB, el cambio de package y toda la conexión BLE. Está 40 commits adelante de `porEjes`.
- Flujo usado: rama feature corta con nombre camelCase (`scanBLE`, `flujoGuardado`, `limpiezaPesads`...) → PR → merge a `conexionBLE`. Commits en español, una línea.
- Remotos: `origin` = Balanzas-Hook/CuatroPlatos-apk, `gittirano` = Tirano61/BalanzaCuatroPlatos (espejo).
- Al terminar el trabajo BLE la idea es que `conexionBLE` pase a ser la principal (ver README.md).

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

Para probar la conexión real hacen falta las balanzas físicas: UDP no se puede simular desde el emulador sin las antenas, BLE requiere teléfono físico.

Estado de `flutter analyze` al 17/09/2026: 0 errores, 0 warnings, 9 `info` preexistentes (`use_build_context_synchronously` en helpers_pesadas y por_ejes_page, `file_names` en `homePage.dart` y `SizeScreen.dart`, `withOpacity` deprecado en cuatro_platos_page y por_ejes_page, `prefer_typing_uninitialized_variables` en fila_platos, un `prefer_const_constructors` en dialog_inicio). No introducir nuevos; no hace falta corregir estos salvo que se pida.

## Mapa del código (`lib/`)

Las carpetas viejas usan mayúscula inicial (`Controllers`, `Pages`, `BaseDeDatos`, `Providers`, `Widgets`, `Theme`); las nuevas usan minúscula (`data`, `domain`, `models`, `helpers`, `config`). Mantener el estilo de la carpeta donde se toca.

```
lib/main.dart                      Bootstrap: Get.put de todos los controllers, carga config de DB,
                                   arranca recibirPesoN() de los 4 platos, define rutas.
lib/Controllers/
  config_controller.dart           Rx: puertos 1..4, connectionType ('udp'|'ble'), nombre BLE por plato.
  peso1..peso4_controller.dart     Uno por plato, CASI IDENTICOS (copy-paste). Escuchan UDP o BLE segun
                                   config, actualizan RecibirPesoModel, timer de 1 s que marca
                                   desconexion a los 5 s sin datos y reintenta BLE.
  multi_ejes_controller.dart       Estado del pesaje por ejes dinamico (2..6): eje activo, pesos por
                                   plato, guardado por eje, snapshot para guardar.
  ejes_controller.dart             LEGACY (2 ejes fijos). Solo lo usa PorEjesPage.
  calculos_controllers.dart        Singleton CalculosController.cn: totales, porcentajes, fecha/hora y
                                   armado de payloads tipados (Pesada4PlatosPayload / PesadaEjesPayload).
lib/data/
  udp/udp_scale_parser.dart        Parsea datagrama "ADC = peso,estable,x,tension" -> ScaleReading.
  ble/ble_scale_parser.dart        Parsea JSON BLE {peso, estBalanza, vbat, nombre} -> ScaleReading.
  ble/ble_scale_service.dart       Singleton BleScaleService.instance: permisos, escaneo en vivo,
                                   busqueda por nombre, conexion, notify, cache de dispositivos.
lib/domain/
  entities/scale_reading.dart      Lectura normalizada (peso, estable, tension, sourceId).
  ports/scale_data_source.dart     Interfaz ScaleDataSource. Definida pero SIN implementaciones aun.
lib/Providers/
  tcp_conexion.dart                Conexion.cn: socket TCP puerto 80 a la IP del plato para enviar
                                   cero / reset hold / calibracion por HTTP GET. SOLO WiFi. No usarlo
                                   directo desde la UI: pasar por ComandosPlato.
  pesadas/                         PesadasProvider: stream de List<Pesaje> para el historial.
lib/BaseDeDatos/
  connections/db_conexion.dart     DBconeccion.db (sqflite, archivo platos.db, dbVersion 1). Implementa
                                   PesadasInterface y ConfigInterface.
  tables/                          SQL de cada tabla (ver seccion Base de datos).
  interfaces/ services/ helpers/   Cadena: DBconeccion -> ServicePesadas/ServiceConfig -> HelpersPesadas/
                                   HelpersConfig (los helpers muestran SnackBar y actualizan GetX).
lib/models/
  config_model.dart                ConfigModel + ConnectionType {udp, ble}. Claves JSON = columnas tconfig.
  recibir_peso_model.dart          Estado Rx de un plato: peso, estable, tension (nivel 1..5), adreess, conexion,
                                   conectando (intento BLE en curso; el Home lo muestra en naranja).
  pesaje_model.dart                Pesaje: modelo MIXTO legacy que todavia usan historial y exportacion.
  pesadas/                         Modelos nuevos por tipo: PesadaBase, Pesada4PlatosDetalle,
                                   PesadaEjesCabecera, EjeDetalle, payloads.
lib/Pages/
  Home/homePage.dart               Card con config por plato (puerto o BLE + estado conectado), boton
                                   "Iniciar Pesaje", barra inferior (ver pesadas / compartir XLSX).
  Home/widgets/dialog_config.dart  Configuracion: SegmentedButton WiFi(UDP)/BLE, puertos o nombres BLE
                                   con boton de escaneo por plato. El tipo y los nombres quedan en estado
                                   local; solo OK -> HelpersConfig.upDateConfig los aplica y reconecta.
  Home/widgets/dialog_scan_ble.dart  Selector de dispositivo BLE que abre el boton de escaneo. El stream
                                   de scanDevicesLive se crea una vez (late final), nunca en build.
  Home/widgets/dialog_inicio.dart  "2 PLATOS" -> selector de cantidad de ejes (2..6) -> ruta ejesN.
                                   "4 PLATOS" -> ruta 'platos'.
  Home/widgets/dialog_ble_bindings.dart  Dialogo alternativo de vinculacion BLE. NO referenciado hoy.
  cuatro_platos/                   CuatroPlatosPage + widgets compartidos (PlatoWidget, EjeWidget,
                                   FilaPlatos, SumaLados con chasis.png, RecuadroPesoTotal, BateryWidget,
                                   DialogWidget para pedir identificacion al guardar).
  por_ejes/por_multi_ejes_page.dart  Pantalla dinamica de N ejes (la que se usa).
  por_ejes/por_ejes_page.dart      LEGACY 2 ejes fijos, ruta 'ejes' registrada pero nadie navega a ella.
  pesadas/                         Historial: lista con Dismissible para borrar, exportar XLSX, borrar todo.
                                   ItemsPesadas renderiza distinto segun tipoPesada.
lib/helpers/exportar_xml.dart      A pesar del nombre exporta XLSX (pesadas.xlsx) y lo comparte con share_plus.
lib/helpers/comandos_plato.dart    ComandosPlato.enviarCero / enviarResetHold(plato): elige BLE o TCP segun
                                   el connectionType configurado. En BLE nunca cae a WiFi.
lib/config/ + lib/Theme/           Dos clases de tema (ThemeApp y ThemePlatos) y SizeScreen (singleton,
                                   isMinWidth = pantalla >= 420 px, se usa como "tablet vs telefono").
lib/generated/ + lib/l10n/         intl configurado pero casi sin uso (solo la clave "titulo").
```

Rutas registradas en `main.dart`: `home`, `pesadas`, `platos`, `ejes` (legacy), `ejes2`..`ejes6`. Los `MultiEjesController` se registran con tag `'2ejes'`..`'6ejes'`.

## Estado y patrones

- Estado con **GetX**: `Get.put` en `main.dart`, `Get.find` en widgets, `Obx` para reactividad. No hay otro gestor de estado.
- Singletons con constructor privado: `CalculosController.cn`, `Conexion.cn`, `ThemePlatos.cn`, `SizeScreen.sc()`, `DBconeccion.db`, `BleScaleService.instance`.
- Los pesos viajan como `String` con 2 decimales (`"0.00"`); se parsean con `double.tryParse` para calcular. Porcentajes también como `String`.
- `tipoPesada` toma solo dos valores: `'4_platos'` y `'2_platos_ejes'`.
- Feedback al usuario con `SnackBar` desde los helpers; colores en `ThemePlatos.errorColor` / `positiveColor`.
- Layout responsive a mano con `SizeScreen.sc().screenWidth * factor` y `isMinWidth`.

## Flujo de datos de los platos

### WiFi / UDP (debe seguir funcionando)

1. `PesoNController.recibirPesoN()` hace `UDP.bind(Endpoint.any(port: puertoN))`. Antes corta el BLE del plato con `stopListening` **sin await**: `disconnect()` de flutter_blue_plus 1.36.8 pasa por un mutex global y espera 2 s o más, y al pasar de BLE a WiFi eso demoraba el bind. Un contador `_udpGeneracion` descarta binds viejos (OK repetido o vuelta a BLE mientras se abría el socket). Si el bind falla, el timer lo reintenta a los 5 s mientras `_receiver` siga en null.
2. Cada datagrama pasa por `UdpScaleParser` (`ADC = peso,estable,?,tension` + terminador; se toma lo que sigue al `=`).
3. Se actualiza `RecibirPesoModel`: `adreess` = IP de origen del datagrama, `conexion = true`, `contador = 0`.
4. Los botones `> 0 <` y `< H >` de `PlatoWidget` llaman a `ComandosPlato`, que en WiFi abre un socket TCP al puerto 80 de esa IP (`Conexion.cn`) y manda `GET /peso?cero=1` o `GET /peso?resethold=1`.

### Bluetooth LE (en desarrollo)

1. Config guarda el **nombre** BLE de cada plato en `tconfig.platoN_ble_name` y `connection_type = 'ble'`.
2. `PesoNController.recibirPesoN()` cierra UDP y llama `BleScaleService.startListening(plato, preferredName, onReading)`.
3. `BleScaleService` pide permisos (Android 12+: BLUETOOTH_SCAN/CONNECT; Android ≤11: ubicación; la conexión automática los pide una sola vez por sesión y después solo consulta el estado), espera el **turno global** (un plato a la vez busca y conecta), busca el dispositivo por nombre sin distinguir mayúsculas (cache → conectados → bonded → system → scan de 5 s), conecta (timeout 10 s), descubre servicios y activa notify en servicio `ABF0` / característica `ABF1`.
   - Sesión por plato: `startListening`/`stopListening` la incrementan; un intento que queda viejo (cambio de nombre o paso a WiFi) se descarta y desconecta. Si ya hay un intento en curso con el mismo nombre, se reutiliza.
   - El escaneo es compartido (`_tomarEscaneo`/`_liberarEscaneo`): la reconexión y el selector de la config usan el mismo, sin reiniciarlo ni cortarlo. Durante el escaneo se cachean todos los dispositivos vistos.
   - Android bloquea en silencio los escaneos si la app arranca más de 5 en 30 s: la reconexión automática no escanea si ya hubo 4 en la ventana.
   - Si la conexión falla, el dispositivo sale del cache para que el próximo intento vuelva a escanear. Si falla después de conectar, se desconecta (un periférico conectado deja de anunciarse).
4. `BleScaleParser` parsea el JSON (`{"peso":..,"estBalanza":..,"vbat":..,"nombre":..}`), mapea `estBalanza` 1→"1", 5→"5", otro→"0".
5. Al primer vínculo se persiste el nombre real del dispositivo (`HelpersConfig.guardarNombreBlePrimerVinculo`, no sobrescribe si ya había uno).
6. Reconexión: el timer de cada controller (arranca en `onInit`, se cancela en `onClose`, corre también en el Home), al llegar a 5 s sin datos estando ya desconectado, vuelve a llamar `recibirPesoN()` (`_tryReconnect`, que en UDP solo reabre si no hay socket). Los 5 s se cuentan desde que termina el intento. `startListening` nunca lanza excepciones.
7. El escaneo para elegir dispositivo en la config usa `scanDevicesLive()` (8 s) y filtra los que no tienen nombre. Siempre pide permisos y, si el Bluetooth está apagado, pide encenderlo (`turnOn`, espera hasta 60 s la respuesta del usuario). Si se cierra el diálogo, el escaneo se corta. La conexión automática nunca intenta encender el Bluetooth.
8. Comandos: los botones `> 0 <` y `< H >` llaman a `ComandosPlato`, que en BLE escribe `AT+CERO\r\n` o `AT+RSTHOLD\r\n` en servicio `ABF6` / característica `ABF2` (`BleScaleService.enviarCero` / `enviarResetHold`). La característica se resuelve al conectar y se cachea por plato. Si el plato no está conectado o falla la escritura, se muestra un SnackBar y nunca se usa TCP.

Regla: con `connectionType == 'ble'` no se usa nada de WiFi (ni UDP ni TCP). El número de plato de los botones sale del `buttonKeyPlato` ('1'..'4'); en pesaje por ejes siempre son los platos físicos 1 y 2.

Protocolo completo (UUIDs de escritura, comandos AT, calibración, significado de `estBalanza`) en `docs/protocolo_ble.md`.

## Base de datos (sqflite, `platos.db`, versión 1)

Esquema nuevo creado desde cero en `onCreate` (sin `onUpgrade`, porque la app se instala como nueva):

| Tabla | Contenido |
|---|---|
| `tconfig` | Una sola fila (`id = 1`): `plato1..plato4` (puertos), `connection_type`, `plato1_ble_name..plato4_ble_name`. |
| `tpesadas_base` | Cabecera común: fecha, hora, identificacion, `tipo_pesada`, total, created_at. Índices por fecha y tipo. |
| `tpesadas_4platos` | Detalle 1:1 de 4 platos (pesos, ejes, lados y porcentajes). FK `ON DELETE CASCADE`. |
| `tpesadas_ejes` | Cabecera 1:1 de pesaje por ejes: cantidad_ejes, lado_izq_total, lado_der_total. |
| `tpesadas_ejes_detalle` | Una fila por eje: nro_eje, peso_izq, peso_der, peso_total_eje. UNIQUE(pesada_id, nro_eje). |

- Inserciones por tipo en transacción (`insertPesada4Platos`, `insertPesadaPorEjes`). El borrado se hace solo sobre `tpesadas_base` y confía en el CASCADE.
- `PRAGMA foreign_keys = ON` se ejecuta solo dentro de `onCreate`. En sqflite ese pragma es por conexión, así que en aperturas posteriores puede no estar activo: si se ven filas huérfanas, moverlo a `onConfigure`.
- `lib/BaseDeDatos/tables/db_pesadas.dart` (tabla `tpesadas`) es legacy: ya no se crea, solo lo referencia un test.
- Si hace falta cambiar el esquema: subir `dbVersion` y escribir `onUpgrade`, o desinstalar la app en el dispositivo de prueba.
- Plan y bitácora completa de la reforma: `docs/cambios_db.md` (todas las fases marcadas como hechas el 24/08/2026).

## Flujo de guardado de una pesada

1. La pantalla llama `CalculosController.cn.calcularPayload4Platos(...)` o `calcularPayloadPorEjes(pesosPorPlato: [...])` (lista plana izq/der por eje).
2. Abre `DialogWidget` pidiendo identificación; `onConfirm` llama `HelpersPesadas.guardarPesada4PlatosPayload` / `guardarPesadaEjesPayload`.
3. El helper inserta vía `ServicePesadas` y muestra SnackBar. En multi-ejes, si guardó, `ejesController.resetPesaje()`.
4. El historial (`PesadasPage`) lee con `getPesadas()` que devuelve `Pesaje` mixto con `tipoPesada`, `cantidadEjes` y `detalleEjes`.
5. Exportación: `Exportar.writeFile` genera `pesadas.xlsx` con hoja `4_platos` y una hoja `ejes_N` por cada cantidad de ejes con datos. `compartirArchivo` lo comparte con share_plus.

## Pendientes conocidos (BLE y alrededores)

- Comandos BLE de tara (`AT+TARA`) y calibración (`AT+CELDACFG?`) todavía no están implementados; cero y reset hold sí.
- `ConnectionWidget` muestra siempre un ícono de WiFi, también en BLE (solo visual).
- `ScaleDataSource` está definido pero no hay implementaciones UDP/BLE; los controllers siguen hablando directo con `UDP` y `BleScaleService`.
- Los 4 `PesoNController` son copias: cualquier cambio hay que replicarlo en los cuatro (candidato a unificar en un `PesoController(plato: n)`).
- `DialogBleBindings` no se usa desde ninguna pantalla; la vinculación se hace desde `DialogConfig`.
- En modo 2 platos por ejes los controllers 3 y 4 siguen intentando conectar a sus platos aunque no se muestren. En BLE, si esos platos están apagados, consumen turnos y cupo de escaneo y pueden demorar unos segundos la reconexión de los platos 1 y 2.
- `estBalanza` original no se conserva en `ScaleReading` (solo el mapeo a `estable`); `docs/protocolo_ble.md` recomienda guardarlo.
- Falta validar todo el flujo BLE con balanzas reales (escaneo, reconexión, varios platos a la vez).
- `scanDevicesLive` filtra en la UI los dispositivos sin nombre, pero `_findDeviceByName` también acepta el `remoteId` como nombre.

## Legacy y trampas

- `Pesaje` (`lib/models/pesaje_model.dart`) sigue siendo el modelo de lectura del historial y de la exportación; los campos `eje3Izq`/`ejeTer`/etc. y los porcentajes vacíos en pesadas por ejes son herencia. `detalleEjes` + `cantidadEjes` son la fuente de verdad para ejes.
- `ConfigModel.fromJson` acepta las claves viejas `platoN_ble_device_id` además de `platoN_ble_name`.
- `HelpersConfig.upDateConfig` hace `Navigator.pop` antes de guardar y luego `_refreshScaleConnections()` reconecta los 4 platos.
- `lib/BaseDeDatos/pesadas_export.dart` está vacío.
- `test/Models/recibir_peso_model_test.dart` importa `package:cuatro_platos/Models/...` con M mayúscula (funciona en Windows, falla en Linux/macOS).
- `test/BaseDeDatos/pesadas/tables/db_pesadas_test.dart` testea la tabla legacy `tpesadas`.
- `integration_test/app_test.dart` y `test/BaseDeDatos/pesadas_export_test.dart` están vacíos.
- `RecibirPesoModel.setTension` convierte voltios de batería en nivel 1..5 (`Bateria.min = 2.5`, rango 1.7 V); `BateryWidget` dibuja el ícono según ese nivel.
- Hay dos temas (`ThemeApp` en `config/theme.dart` y `ThemePlatos` en `Theme/theme.dart`); se usan mezclados.
- `.github/modernize/` es basura de una extensión de VS Code (Java upgrade), no CI del proyecto.

## Documentación de referencia

- `README.md`: historial de ramas.
- `docs/cambios_db.md`: plan de la reforma de DB, decisiones de producto y bitácora por fases.
- `docs/protocolo_ble.md`: UUIDs, formato JSON, valores de `estBalanza`, comandos AT y calibración de la balanza BLE.
