# Plan: de "Cuatro Platos" a "Platos Cestari" (9 platos por WiFi UDP)

Plan de la reforma, escrito el 01/10/2026. Cada paso es una rama corta en camelCase que termina en un PR a `main` (rama principal, `origin/main`). Los commits van en español, en una línea. Al cerrar cada PR se marca su casilla.

## Contexto

Este repo arrancó como copia de la app de Balanzas Hook que pesa con 4 platos o con 2 platos por ejes, conectados por WiFi UDP o por Bluetooth LE.

Para Cestari hay que pesar una tolva muy grande de 3 ejes con **9 celdas**: 4 por lado y 1 en el enganche. Las celdas no están sobre los ejes, así que se agrupan en 4 **juegos** (izq/der). Por ejemplo, J1 es el primer juego de celdas, no el eje delantero.

Decisiones:

- **Se quita BLE.** Queda solo WiFi UDP, una balanza por puerto, con el mismo protocolo de hoy (`UdpScaleParser`, datagrama `ADC = peso,estable,x,tension`).
- **Se quita el pesaje por ejes.** Queda un único tipo de pesaje: 9 platos.
- **Cero y reset hold se mantienen** por TCP al puerto 80 de la IP del plato (`ComandosPlato` → `Conexion.cn`).
- **App nueva:**
  - package Dart `nueve_platos_cestari`;
  - `applicationId` `com.dramirez.nueveplatoscestari`;
  - label "Platos Cestari";
  - base de datos nueva desde cero (`dbVersion` 1, sin migración).

### Disposición de los platos (puertos por defecto 8001..8009)

```
            [1 ENGANCHE]
   [2 J1 IZQ]  JUEGO 1  [3 J1 DER]
   [4 J2 IZQ]  JUEGO 2  [5 J2 DER]
   [6 J3 IZQ]  JUEGO 3  [7 J3 DER]
   [8 J4 IZQ]  JUEGO 4  [9 J4 DER]
     LADO IZQ             LADO DER
```

Cálculos que se muestran y se guardan en cada pesada:

- Peso y % sobre el total de cada uno de los 9 platos.
- Subtotal y % de cada juego (J1..J4).
- Lado izquierdo (platos 2+4+6+8) y lado derecho (3+5+7+9), cada uno con su %. El enganche no suma a ningún lado.
- Enganche con su %, mostrado aparte.
- Total de los 9 platos.

---

## Pasos

Cada PR debe dejar la app compilando.

### [x] PR 1 · `planNuevePlatos`: plan y CLAUDE.md inicial
- Este archivo.
- `CLAUDE.md`: explicar que la app está en transición, actualizar ramas y remotos, y apuntar a este plan.
- `README.md`: nuevo historial.

### [x] PR 2 · `renombrarPaquete`: paquete, applicationId y nombre
- `pubspec.yaml`: `name: nueve_platos_cestari` y `description` nueva.
- Reemplazar `package:cuatro_platos/` por `package:nueve_platos_cestari/` en `lib/` y `test/`.
- `test/Models/recibir_peso_model_test.dart`: corregir el import `Models` → `models`.
- Android:
  - `namespace` y `applicationId` `com.dramirez.nueveplatoscestari` en `android/app/build.gradle`;
  - mover `MainActivity.kt` a `kotlin/com/dramirez/nueveplatoscestari/` con el `package` nuevo;
  - `android:label="Platos Cestari"`.
- Título "Platos Cestari" en `main.dart`, en la clave `titulo` de `lib/l10n/*.arb` y en `lib/generated/intl/messages_*.dart`.

### [x] PR 3 · `quitarBle`: quitar Bluetooth LE
- Borrar:
  - `lib/data/ble/`;
  - `dialog_scan_ble.dart` y `dialog_ble_bindings.dart`;
  - `docs/protocolo_ble.md`;
  - `lib/domain/ports/scale_data_source.dart`.
- `ConfigModel`, `ConfigController` y `tconfig`: quitar `ConnectionType`, `connectionType` y `platoN_ble_name`, incluido el fallback `platoN_ble_device_id`.
- `db_conexion`, `ConfigInterface` y `ServiceConfig`: quitar `updateBleNameForPlato`.
- `HelpersConfig`: quitar `guardarNombreBlePrimerVinculo` y los setters BLE.
- `Peso1..4Controller`:
  - quitar la rama BLE, `stopListening` e `_intentosBle`;
  - el chequeo posterior al bind queda solo con `_udpGeneracion`;
  - `_tryReconnect` queda solo con `if (_receiver != null) return;`.
- `RecibirPesoModel`: quitar `conectando`.
- `homePage` y `dialog_config`: quitar el `SegmentedButton`, los campos BLE, `isBle` y el estado naranja.
- `ComandosPlato`: queda solo TCP.
- `main.dart`: quitar `connectionType` y los setters BLE.
- `pubspec`: quitar `flutter_blue_plus`, `device_info_plus` y `external_path`. `permission_handler` queda porque lo usa la exportación.
- `AndroidManifest.xml`: quitar los permisos BLUETOOTH* y ACCESS_FINE_LOCATION y el `uses-feature` `bluetooth_le`.
- Limpiar los comentarios que mencionan BLE y las secciones BLE de `CLAUDE.md`.

### [x] PR 4 · `quitarEjes`: quitar el pesaje por ejes
- Borrar:
  - `ejes_controller.dart` y `multi_ejes_controller.dart`;
  - `lib/Pages/por_ejes/`;
  - `pesada_ejes_model.dart` y `pesada_eje_detalle_model.dart`;
  - `db_pesadas_ejes.dart` y `db_pesadas_ejes_detalle.dart`.
- `main.dart`: quitar `EjesController`, los `MultiEjesController` (tags `2ejes`..`6ejes`) y las rutas `ejes`, `ejes2`..`ejes6`.
- Borrar `dialog_inicio.dart`. "Iniciar Pesaje" navega directo a `'platos'`.
- `CalculosController`: quitar `calcularPayloadPorEjes`, `_pesajeFromEjesPayload`, `claculosParaGuardar`, `calculosParaGuardarPorEjes`, `_pesajeFrom4PlatosPayload` y `calculoPorcentajeEjePorValores`.
- Quitar `PesadaEjesPayload`.
- `db_conexion`, interfaz, servicio y `HelpersPesadas`: quitar todo lo de ejes.
- `Pesaje`: quitar `eje3*`, `ejeTer`, `detalleEjes` y `cantidadEjes`.
- Historial y exportación:
  - `pesadas_page` e `items_pesadas`: quitar `isPorEjes` y `_buildEjesDinamicos`;
  - `exportar_xml`: quitar las hojas `ejes_N`.
- `PlatoWidget` y `EjeWidget`: quitar `showPorcentaje`. El `label` de `EjeWidget` queda para "JUEGO N".
- Actualizar `test/moks/db_connection_mock.dart` y `CLAUDE.md`.

### [x] PR 5 · `unificarPesoController`: un solo controller por plato (todavía con 4)
- Reemplazar `peso1..4_controller.dart` por `lib/Controllers/peso_controller.dart`:
  - `PesoController({required this.plato})` con un `RecibirPesoModel pesoModel` tipado;
  - el mismo cuerpo UDP: `_udpGeneracion`, timer de 1 s, desconexión a los 5 s y `_tryReconnect`.
- Registro: `Get.put(PesoController(plato: n), tag: 'plato$n')`. Búsqueda: `Get.find<PesoController>(tag: 'plato$n')`.
- `ConfigController`: puertos en una lista indexada, con `puerto(n)` / `setPuerto(n, v)`.
- Adaptar:
  - `HelpersConfig._refreshScaleConnections`;
  - `ComandosPlato._ipPlato`;
  - `homePage`, `cuatro_platos_page` y `controllers_export.dart`.
- Es solo un refactor: el comportamiento queda idéntico.

### [x] PR 6 · `configNuevePlatos`: 9 platos en configuración y conexión
- Nuevo `lib/config/platos.dart` con `cantidadPlatos = 9` y el nombre de cada plato (`ENGANCHE`, `J1 IZQ` … `J4 DER`).
- `tconfig` y `ConfigModel`: `plato1..plato9`.
- `first_data.dart`: valores por defecto 8001..8009.
- `main.dart`: registrar y arrancar los 9 `PesoController`.
- `dialog_config`: 9 `InputTextConfig` con su etiqueta, en el `ListView` con scroll.
- Card del Home: una fila para el enganche y 4 filas izq/der, con el estado de conexión de cada plato.
- Estado intermedio aceptado: la pantalla de pesaje sigue mostrando los platos 1..4 hasta el PR 8.

### [ ] PR 7 · `pesadaNuevePlatos`: modelo, cálculos y base de datos
- `Pesada9PlatosDetalle` reemplaza a `pesada_4platos_model.dart`. Campos:
  - `enganche`, `j1Izq`..`j4Der`;
  - `juego1..4`, `ladoIzq`, `ladoDer`;
  - un `por*` (porcentaje) por cada uno.
- Agregar `Pesada9PlatosPayload`.
- `CalculosController`:
  - nuevo `calcularPayload9Platos(pesos: List<String>)`, que recibe los 9 pesos en el orden de los platos y usa `setPesoTotalByList`;
  - quitar `calcularPayload4Platos` y el `setPesoTotal` de 4 argumentos.
- Nueva tabla `tpesadas_9platos` (`db_pesadas_9platos.dart`) en lugar de `tpesadas_4platos`, con FK `ON DELETE CASCADE` a `tpesadas_base`. `tipo_pesada` es siempre `'9_platos'`.
- `db_conexion`: `insertPesada9Platos` y `getPesadas9Platos`.
- Actualizar la interfaz, el servicio, `HelpersPesadas.guardarPesada9PlatosPayload` y el mock.
- Mover `PRAGMA foreign_keys = ON` a `onConfigure`.
- Test nuevo `test/controllers/calculos_9platos_test.dart`: totales, juegos, lados y porcentajes.

### [ ] PR 8 · `pantallaNuevePlatos`: pantalla de pesaje
- Renombrar `lib/Pages/cuatro_platos/` a `lib/Pages/nueve_platos/` y `CuatroPlatosPage` a `NuevePlatosPage`. La ruta sigue siendo `'platos'`.
- Contenido, en este orden:
  - `RecuadroPesoTotal`;
  - `PlatoWidget` del enganche, centrado, con su %;
  - 4 × `FilaPlatos(izq, der, label: 'JUEGO N')`;
  - recuadro de lados izq/der.
- `SumaLados` deja de usar `assets/chasis.png` (es un dibujo de 2 ejes). Si el asset queda sin uso, se borra.
- `PlatoWidget` se reutiliza con los botones `> 0 <` y `< H >` por TCP, con `buttonKeyPlato` '1'..'9'. Si queda muy alto en el teléfono, se compactan los tamaños.
- FAB Guardar: `calcularPayload9Platos` → `DialogWidget` → `guardarPesada9PlatosPayload`.

### [ ] PR 9 · `historialNuevePlatos`: historial y exportación
- `PesadasPage` / `ItemsPesadas` leen el modelo nuevo (base + `Pesada9PlatosDetalle`).
- La tarjeta del historial muestra el enganche, los 4 juegos (izq | juego | der), los lados y el total.
- Quitar el `Pesaje` legacy. `getPesadasExportacion` pasa a usar el modelo nuevo.
- `exportar_xml.dart`:
  - una sola hoja `9_platos` con `id`, `fecha`, `hora`, `identificacion`, `total`, los 9 pesos, los juegos, los lados y todos los porcentajes;
  - asunto al compartir: "Balanzas Hook, 9 platos".
- Borrar el legacy:
  - `db_pesadas.dart` y su test;
  - `pesadas_export.dart` y `pesadas_export_test.dart`, que están vacíos.
- Adaptar `test/list_pesajes`.

### [ ] PR 10 · `claudeMdNuevePlatos`: documentación final
- Reescribir `CLAUDE.md` completo según la app final:
  - qué es la app;
  - ramas;
  - toolchain;
  - mapa de `lib/`;
  - flujo UDP y TCP;
  - esquema de la base;
  - guardado, historial y exportación;
  - pendientes;
  - estado actual de `flutter analyze`.
- Borrar o resumir `docs/cambios_db.md`, que corresponde a la app vieja.
- Marcar todos los pasos de este plan como hechos.

---

## Verificación en cada PR

1. Correr `fvm flutter pub get`, `fvm flutter analyze` y `fvm flutter test`. Desde Git Bash se usa `.fvm/flutter_sdk/bin/flutter.bat`. Resultado esperado:
   - ningún error ni warning nuevo;
   - los `info` preexistentes no aumentan.
2. Correr `fvm flutter build apk --debug`.
3. Desde el PR 6, probar en un teléfono con las balanzas o antenas reales:
   - los 9 puertos conectan y el Home los muestra en verde;
   - la app marca la desconexión a los 5 s y reconecta;
   - cero y reset hold funcionan en cada plato.
4. Desde los PR 8 y 9, comprobar:
   - una pesada guardada aparece en el historial con juegos, lados y enganche;
   - el XLSX exportado tiene las columnas correctas;
   - al borrar una pesada, la cascada borra también su detalle.
5. La app se instala junto a la app vieja "Platos" sin pisarla, porque tiene un `applicationId` nuevo.
