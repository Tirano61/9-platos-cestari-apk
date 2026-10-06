# Plan: calibración de cada plato por WiFi

Plan escrito el 06/10/2026 a partir de [CALIBRACION_WIFI.md](CALIBRACION_WIFI.md).
Cada paso es una rama corta en camelCase que termina en un PR a `main`. Los commits van en español, en una línea.
Al cerrar cada PR se marca su casilla.

**Cómo usar este plan:** pedir "hacé el paso N de docs/plan_calibracion.md". Antes de implementarlo, se lee el paso
y, si hace falta, se cambia acá mismo. Cada paso deja la app compilando, con `flutter analyze` sin problemas nuevos y
`flutter test` en verde.

## Contexto

Hoy no se puede cambiar la calibración de los platos desde la app. `Conexion.enviarCalibracion` existe, pero no tiene
UI, le faltan parámetros (`correccion`, `resethold`) y escribe a mano en el socket TCP del cero.

Se agrega, en el diálogo de configuración, un **botón al lado del puerto de cada plato** que abre una **pantalla de
calibración**: lee la calibración de ese plato, deja editarla y la envía.

El indicador puede tener dos firmwares, y la lectura es distinta en cada uno:

| | Firmware clásico | Firmware ESP32 |
|---|---|---|
| Lectura | `GET /config?json=1` | `GET /configjson?json=1` |
| Respuesta | JSON plano, valores numéricos | JSON anidado en `Configuracion.Balanza`, cada campo `{type, value}` con `value` como texto |
| Decimales | número JSON (`1` o `1.0`) | `u64` cuyos 32 bits bajos son un float IEEE-754 |
| Escritura | `GET /save?...` | igual |

Por eso hay un **modelo de parseo para cada firmware**, y los dos se convierten a un **modelo común** que es el que
usan la pantalla y el envío.

### Decisiones tomadas

- Solo se envía la **calibración completa** (los 10 parámetros). No se hace el botón "enviar solo la corrección"
  (sección 3.3 del documento).
- Se aplican las recomendaciones de la sección 4 del documento:
  - timeout de **5 s** en todas las peticiones, también en `/save`, y errores de red capturados;
  - **validar** todos los campos antes de enviar (nunca se manda `null` en la URL);
  - si `/config` responde con un código distinto de 200, también se prueba `/configjson`.
- `capacidad_maxima` se muestra como solo lectura y **no se envía**.
- La IP del plato es la de origen de sus datagramas UDP (`pesoModel.adreess` del `PesoController` del plato), no la
  del puerto 5900 que nombra el documento: acá cada plato emite a su puerto (8001..8009).
- `adreess` vale `'0'` hasta que llega el primer datagrama: `'0'` o vacío = **sin IP**, y no se manda nada.
- Las peticiones HTTP van con el paquete `http` (ya estaba como dependencia transitiva), con el `Client` inyectable
  para probarlo con `MockClient`.
- Después de enviar, con éxito o con error, se **vuelve a leer** para mostrar lo que realmente quedó en el equipo.

---

## Pasos

### [x] Paso 0 · `planCalibracion`: este documento
- Crear `docs/plan_calibracion.md` y nombrarlo en `CLAUDE.md` (Documentación de referencia).

### [x] Paso 1 · `modeloCalibracion`: modelos y parseo de las dos respuestas
Carpeta nueva `lib/models/calibracion/`:
- `calibracion_model.dart` — `CalibracionModel`, el modelo común (sección 2.4 del documento):
  - enteros (`int?`): `totalCelda`, `sensibilidad`, `conversiones`, `recortes`, `ventanaMovil`, `kgFiltro`,
    `tiempoEstable`;
  - decimales (`double?`): `division`, `correccion`, `kgResetHold`, `capacidadMaxima`;
  - `firmware`: enum `FirmwareCalibracion { clasico, esp32 }`;
  - `completa`: los 10 campos que se envían tienen valor;
  - `toSaveQuery()`: `Map<String, String>` con los parámetros de `/save` en el orden y con los nombres del documento
    (`celdas`, `sensibilidad`, `division`, `conversiones`, `recortes`, `ventanam`, `gkfiltro`, `correccion`,
    `tiempoestable`, `resethold`). Decimales con punto; un decimal entero va como `10.0`. Sin `capacidad_maxima`;
  - `copyWith`, para armar el modelo editado en la pantalla.
- `calibracion_clasica_model.dart` — `CalibracionClasicaModel.fromJson(Map)`: las 17 claves planas (`total_celda` …
  `alimentacion`, incluidas las 6 que se leen y no se usan). Los números se leen como `num` y se pasan a `int` /
  `double`, así `correccion`, `kg_reset_hold` y `capacidad_maxima` aceptan `1` y `1.0`. `toCalibracion()` devuelve el
  `CalibracionModel` (firmware clásico).
- `calibracion_esp32_model.dart` — `CalibracionEsp32Model.fromJson(Map)`:
  - sin `Configuracion.Balanza` lanza `FormatException` (respuesta inválida);
  - campos enteros: `int.tryParse(value)`; `capMax` se usa como decimal;
  - campos `u64` (`divisiones`, `factorCorrec`, `pIniCalcH`, `kgFiltroMov`): solo si `type == 'u64'`, si no quedan
    vacíos. Función pura `floatDesdeU64(String value)`: entero → `& 0xFFFFFFFF` → mismo patrón de bits leído como
    float de 32 bits (`ByteData`) → redondeo a 2 decimales. `kgFiltroMov` además se trunca a entero;
  - `toCalibracion()` devuelve el `CalibracionModel` (firmware ESP32).
- Test `test/Models/calibracion_model_test.dart`: ejemplo clásico del documento (con `correccion` entero), ejemplo
  ESP32 del documento, tabla de decodificación (`1056964608` → 0.5, `1065353216` → 1.0, `1084227584` → 5.0,
  `1092616192` → 10.0), `type` que no es `u64`, falta `Configuracion.Balanza`, `kgFiltroMov` truncado,
  `toSaveQuery` (nombres, orden y `10.0`) y `completa` con un campo vacío.
- Hecho: `toSaveQuery` lanza `StateError` si el modelo no está completo; `floatDesdeU64` devuelve `null` con un
  texto que no es entero o un float no finito, y lee el `u64` con `BigInt`, porque puede no entrar en un `int` de Dart.

### [x] Paso 2 · `servicioCalibracion`: lectura y envío por HTTP
- `pubspec.yaml`: `http` como dependencia directa.
- `lib/Providers/calibracion_wifi.dart` — `CalibracionWifi` (`http.Client` inyectable, timeout de 5 s):
  - `leer(ip)` → `CalibracionModel?`: `GET http://<ip>/config?json=1`; con 200 se parsea como clásico. Si falla la
    conexión, se agota el tiempo, el JSON no se puede interpretar o el código no es 200, se prueba
    `GET http://<ip>/configjson?json=1` y con 200 se parsea como ESP32. Cualquier otro resultado → `null`;
  - `enviar(ip, calibracion)` → `bool`: con un modelo incompleto no manda nada. `GET /save?<toSaveQuery>`; con 200
    manda `GET /save?reset=1` (no revisa su respuesta) y devuelve `true`; con otro código o error de red devuelve
    `false` y no manda el reset.
- `lib/helpers/comandos_plato.dart`: `ipPlato(n)` público (hoy `_ipPlato`), que devuelve `null` también con `'0'` o
  vacío. Lo usan el cero y la pantalla de calibración.
- Test `test/Providers/calibracion_wifi_test.dart` con `MockClient`: lectura clásica, fallback por excepción y por
  404, ESP32 inválido, los dos fallan; envío con la URL exacta del documento y el reset, código ≠ 200 sin reset,
  error de red y modelo incompleto sin peticiones.

### [ ] Paso 3 · `pantallaCalibracion`: pantalla de calibración de un plato
- `lib/Pages/calibracion/calibracion_page.dart` — `CalibracionPage(plato:)`, ruta `'calibracion'` (el número de plato
  va en los `arguments`). Servicio e IP inyectables para los tests.
  - AppBar `Calibración <nombrePlato>`; arriba, la IP y el firmware leído.
  - Sin IP: aviso "El plato todavía no mandó datos: no se conoce su IP" y botón Reintentar.
  - Al abrir lee la calibración (indicador de carga). Si falla: mensaje y botón "Leer de nuevo".
  - Formulario con scroll: los 10 campos editables (enteros solo dígitos; decimales aceptan coma y se pasa a punto) y
    la capacidad máxima solo lectura. Un campo que el firmware no mandó queda vacío.
  - **Enviar calibración**: valida los 10 campos (vacío o inválido → marcado en rojo y SnackBar, no se envía), pide
    confirmación ("El indicador se va a reiniciar"), deshabilita los botones mientras envía, avisa el resultado con
    SnackBar y vuelve a leer.
- `lib/main.dart`: registrar la ruta `'calibracion'`.
- Test `test/widgets/calibracion/calibracion_page_test.dart` en un teléfono angosto con servicio falso: valores
  leídos, sin IP, error de lectura, campo inválido que no envía, envío con el modelo editado y relectura.

### [ ] Paso 4 · `botonCalibracionConfig`: botón de calibrar en la configuración
- `DialogConfig`: al lado del puerto de cada plato, un `IconButton` (`Icons.tune`, tooltip `Calibrar <nombrePlato>`)
  que hace `Navigator.pushNamed(context, 'calibracion', arguments: n)`. El diálogo queda abierto debajo: al volver,
  los puertos sin guardar siguen como estaban.
- `Conexion` (`Providers/tcp_conexion.dart`): borrar `enviarCalibracion` (lo reemplaza `CalibracionWifi`) y sacarlo
  de "Pendientes conocidos" en `CLAUDE.md`. Agregar en `CLAUDE.md` el flujo de la calibración.
- Test del diálogo: 9 botones de calibrar; tocar uno abre `'calibracion'` con su número de plato.

---

## Verificación con las balanzas

Con las balanzas reales y la app en un teléfono (`fvm flutter run`):

- [ ] Abrir la configuración: cada plato tiene su botón de calibrar.
- [ ] Plato con firmware clásico: los valores leídos coinciden con los del equipo.
- [ ] Plato con firmware ESP32 (si hay alguno): los decimales (división, corrección, reset hold, kg filtro) se ven
      bien decodificados.
- [ ] Cambiar un valor y enviar: el indicador se reinicia y la relectura muestra el valor nuevo.
- [ ] Un campo vacío o inválido no se envía.
- [ ] Plato apagado: la lectura falla con aviso, sin colgar la pantalla (timeout de 5 s).
- [ ] Plato que todavía no mandó datos: aviso de "sin IP".
- [ ] Las peticiones `http://` en claro funcionan en Android sin `usesCleartextTraffic` (`package:http` usa
      `dart:io`, que no pasa por la network security config).
