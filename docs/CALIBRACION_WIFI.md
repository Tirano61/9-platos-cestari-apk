# Calibración de la balanza por WiFi (HTTP)

## 1. Requisitos previos

- **IP del indicador:** el indicador envía tramas de peso por UDP al puerto **5900**. La IP del indicador es la dirección de origen de esas tramas.
- **Comunicación:** todas las peticiones son `HTTP GET` al puerto 80, del tipo `http://<IP>/<endpoint>?<parámetros>`. No llevan cuerpo; todo va en la query string.
- **Dos tipos de firmware:** el indicador puede tener uno de estos dos. La **lectura** es distinta en cada uno. El **envío** es el mismo para los dos.

| | Firmware clásico | Firmware ESP32 |
|---|---|---|
| Endpoint de lectura | `/config?json=1` | `/configjson?json=1` |
| Formato de respuesta | JSON plano | JSON anidado con `type`/`value` |
| Endpoint de escritura | `/save` | `/save` (igual) |

---

## 2. Lectura de la calibración

### 2.1 Orden de intentos

1. Se envía `GET http://<IP>/config?json=1` con **timeout de 5 s**.
   - Si responde **200**, se procesa como firmware clásico (sección 2.2). Fin.
   - Si responde con otro código, la lectura falla. **No** se prueba el segundo endpoint.
   - Si falla la conexión, se agota el tiempo o el JSON no se puede interpretar, se pasa al paso 2.
2. Se envía `GET http://<IP>/configjson?json=1` con **timeout de 5 s**.
   - Si responde **200**, se procesa como firmware ESP32 (sección 2.3). Fin.
   - Con cualquier otro resultado, la lectura falla.

> Sugerencia para la nueva implementación: probar también el segundo endpoint cuando el primero responda con un código distinto de 200.

### 2.2 Respuesta del firmware clásico (`/config?json=1`)

Es un JSON plano y los valores son números JSON.

```json
{
  "total_celda": 4,
  "sensibilidad": 2000,
  "division": 0.5,
  "conversiones": 10,
  "recortes": 2,
  "ventana_movil": 8,
  "kg_filtro": 5,
  "correccion": 1.0,
  "tiempo_estable": 3,
  "kg_reset_hold": 10.0,
  "capacidad_maxima": 3000,
  "invertido": 0,
  "unidad": 0,
  "logica_sensor": 0,
  "tipo_peso": 0,
  "teclado": 0,
  "alimentacion": 0
}
```

| Clave | Tipo | Descripción |
|---|---|---|
| `total_celda` | entero | Cantidad de celdas de carga |
| `sensibilidad` | entero | Sensibilidad de la celda |
| `division` | decimal | División (resolución) del peso |
| `conversiones` | entero | Cantidad de conversiones del ADC |
| `recortes` | entero | Cantidad de recortes del filtro |
| `ventana_movil` | entero | Tamaño de la ventana móvil |
| `kg_filtro` | entero | Kg del filtro móvil |
| `correccion` | decimal | Factor de corrección |
| `tiempo_estable` | entero | Tiempo de estabilidad |
| `kg_reset_hold` | decimal | Kg para el reset del hold |
| `capacidad_maxima` | decimal | Capacidad máxima (puede venir como entero) |
| `invertido` | entero | Se lee pero no se muestra ni se envía |
| `unidad` | entero | Se lee pero no se muestra ni se envía |
| `logica_sensor` | entero | Se lee pero no se muestra ni se envía |
| `tipo_peso` | entero | Se lee pero no se muestra ni se envía |
| `teclado` | entero | Se lee pero no se muestra ni se envía |
| `alimentacion` | entero | Se lee pero no se muestra ni se envía |

> Cuidado: `correccion` y `kg_reset_hold` pueden llegar como entero (`1`) en lugar de decimal (`1.0`). Hay que aceptar los dos y convertirlos a decimal.

### 2.3 Respuesta del firmware ESP32 (`/configjson?json=1`)

Es un JSON anidado. Los datos están en `Configuracion → Balanza` y cada campo es un objeto con:

- `type`: tipo nativo en el equipo, por ejemplo `"u16"` o `"u64"`.
- `value`: el valor **siempre como texto (string)**.

```json
{
  "Configuracion": {
    "Balanza": {
      "totalCelda":      { "type": "u16", "value": "4" },
      "sensiCelda":      { "type": "u16", "value": "2000" },
      "sizeConv":        { "type": "u16", "value": "10" },
      "sizeRecortes":    { "type": "u16", "value": "2" },
      "sizeVentMovil":   { "type": "u16", "value": "8" },
      "timeEstabilidad": { "type": "u16", "value": "3" },
      "capMax":          { "type": "u16", "value": "3000" },
      "divisiones":      { "type": "u64", "value": "1056964608" },
      "factorCorrec":    { "type": "u64", "value": "1065353216" },
      "kgFiltroMov":     { "type": "u64", "value": "1084227584" },
      "pIniCalcH":       { "type": "u64", "value": "1092616192" }
    }
  }
}
```

*(En los campos enteros, el `type` exacto lo define el firmware; `u16` es solo un ejemplo.)*

Si no existe `Configuracion.Balanza`, la respuesta se considera inválida.

#### Campos enteros

En estos campos basta con convertir `value` de texto a entero.

| Clave ESP32 | Equivale a | Tipo final |
|---|---|---|
| `totalCelda` | total_celda | entero |
| `sensiCelda` | sensibilidad | entero |
| `sizeConv` | conversiones | entero |
| `sizeRecortes` | recortes | entero |
| `sizeVentMovil` | ventana_movil | entero |
| `timeEstabilidad` | tiempo_estable | entero |
| `capMax` | capacidad_maxima | entero, que se usa como decimal |

#### Campos `u64`, que en realidad son decimales codificados

| Clave ESP32 | Equivale a | Tipo final |
|---|---|---|
| `divisiones` | division | decimal |
| `factorCorrec` | correccion | decimal |
| `pIniCalcH` | kg_reset_hold | decimal |
| `kgFiltroMov` | kg_filtro | decimal, **truncado a entero** |

**Cómo se decodifican.** Solo se aplica si `type == "u64"`; si no, el campo queda vacío.

1. Convertir `value` (texto) a entero.
2. Quedarse con los 32 bits bajos: `n & 0xFFFFFFFF`.
3. Reinterpretar esos 32 bits como un **float IEEE-754 de 32 bits**. No es una conversión numérica, es el mismo patrón de bits leído como float, como `Float.intBitsToFloat` en Java/Kotlin o `struct.unpack('<f', struct.pack('<I', n))` en Python.
4. Redondear a **2 decimales**.

Ejemplos:

| `value` | Hex | Float |
|---|---|---|
| `1056964608` | 0x3F000000 | 0.5 |
| `1065353216` | 0x3F800000 | 1.0 |
| `1084227584` | 0x40A00000 | 5.0 |
| `1092616192` | 0x41200000 | 10.0 |

#### Campos que no vienen en ESP32

`invertido`, `unidad`, `logica_sensor`, `tipo_peso`, `teclado` y `alimentacion` no existen en este formato y quedan vacíos.

### 2.4 Modelo común después de la lectura

Los dos formatos se convierten a la misma estructura, que es la que se muestra en pantalla:

| Campo | Tipo | Se muestra/edita |
|---|---|---|
| total_celda | entero | Sí |
| sensibilidad | entero | Sí |
| division | decimal | Sí |
| conversiones | entero | Sí |
| recortes | entero | Sí |
| ventana_movil | entero | Sí |
| kg_filtro | entero | Sí |
| correccion | decimal | Sí |
| tiempo_estable | entero | Sí |
| kg_reset_hold | decimal | Sí |
| capacidad_maxima | decimal | Se lee, **no se envía** por WiFi |

---

## 3. Envío de la calibración

Es **igual para los dos tipos de firmware**.

### 3.1 Guardar

```
GET http://<IP>/save?celdas=4&sensibilidad=2000&division=0.5&conversiones=10&recortes=2&ventanam=8&gkfiltro=5&correccion=1.0&tiempoestable=3&resethold=10.0
```

| Parámetro | Campo | Tipo | Formato del texto |
|---|---|---|---|
| `celdas` | total_celda | entero | `4` |
| `sensibilidad` | sensibilidad | entero | `2000` |
| `division` | division | decimal | `0.5` |
| `conversiones` | conversiones | entero | `10` |
| `recortes` | recortes | entero | `2` |
| `ventanam` | ventana_movil | entero | `8` |
| `gkfiltro` | kg_filtro | entero | `5` |
| `correccion` | correccion | decimal | `1.0` |
| `tiempoestable` | tiempo_estable | entero | `3` |
| `resethold` | kg_reset_hold | decimal | `10.0` |

- Los nombres de los parámetros **no coinciden** con las claves de lectura. Respetarlos tal cual, incluido `gkfiltro`, que lleva "gk" y no "kg".
- Los decimales se envían **con punto**. Un decimal entero se envía como `10.0`.
- Se envían los 10 parámetros siempre en la misma petición. `capacidad_maxima` **no** se envía.

### 3.2 Resultado y reinicio

- Si `/save` responde **200**, se considera guardado y se envía `GET http://<IP>/save?reset=1` para reiniciar el indicador. No se revisa la respuesta del reset.
- Con cualquier otro código, se informa el error y **no** se envía el reset.
- Después del envío, con éxito o con error, se vuelve a ejecutar la **lectura** (sección 2) para mostrar los valores que realmente quedaron en el equipo.

### 3.3 Enviar solo la corrección

También se puede enviar solo el factor de corrección:

1. Normalizar el texto: quitar espacios y cambiar la coma por punto (`1,05` → `1.05`). Si no es un número válido, no se envía.
2. `GET http://<IP>/save?correccion=1.05`
3. Si responde 200, enviar `GET http://<IP>/save?reset=1`.

---

## 4. Recomendaciones para la nueva implementación

- **Timeout en el envío:** la app actual no tiene timeout ni manejo de errores en las peticiones de `/save`. Conviene poner unos 5 s y capturar los errores de red.
- **Validar antes de enviar:** si un campo está vacío o no es numérico, la app actual manda el texto literal `null` en la URL. Hay que validar todos los campos antes de armar la petición.
- **Fallback por código HTTP:** usar `/configjson` también cuando `/config` responda con un código distinto de 200, no solo cuando haya una excepción.
