# Protocolo BLE de balanza

## UUID de conexion
```dart
final Guid serviceNotifyUuid       = Guid("0000ABF0-0000-1000-8000-00805F9B34FB");
final Guid caracteristicNotifyUuid = Guid("0000ABF1-0000-1000-8000-00805F9B34FB");
final Guid serviceWriteUuid        = Guid("0000ABF6-0000-1000-8000-00805F9B34FB");
final Guid caracteristicWriteUuid  = Guid("0000ABF2-0000-1000-8000-00805F9B34FB");
```

Uso:
- Notify: recepcion de peso/estado.
- Write: envio de comandos AT.

## Formato de entrada
El dispositivo BLE envia un JSON con esta estructura:

```json
{"tara":null,"hold":null,"vbat":null,"peso":35,"estBalanza":0,"humedad":60,"sensorInduc":0,"nombre":"plato1"}
```

## Campos
- tara: tara reportada por la balanza (puede ser null).
- hold: estado interno de hold (puede ser null).
- vbat: voltaje de bateria (puede ser null).
- peso: peso actual.
- estBalanza: estado de estabilidad de la balanza.
- humedad: humedad reportada por el dispositivo.
- sensorInduc: estado del sensor inductivo.

## Valores de estBalanza
- 0: inestable
- 1: estable
- 2: calculando estabilidad
- 3: holdeado
- 4: en cero
- 5: en pausa

## Comandos BLE
- Enviar cero: `AT+CERO\r\n`
- Enviar reset hold: `AT+RSTHOLD\r\n`
- Enviar tara: `AT+TARA\r\n`
- Pedir calibracion: `AT+CELDACFG?\r\n`

## Respuesta de calibracion
La balanza responde por BLE con un texto como:

```text
AT+CELDACFG=4000,6000,2000,0.01,6,200.00,10,2,1000
```
Regla de negocio: recortes <= (conversiones / 2) - 1.

Campos en orden:
1. Capacidad maxima
2. Total de celdas
3. Sensibilidad
4. Divisiones
5. Ventana movil
6. Kg reset filtro movimiento
7. Conversiones
8. Recortes
9. Tiempo de estabilidad

Rangos:
- Capacidad maxima: 1 - 999999
- Total de celdas: 1 - 999999
- Sensibilidad: 500 - 5000
- Divisiones: 0.01 - 999.9
- Ventana movil: 1 - 30
- Kg reset filtro movimiento: 1 - Capacidad maxima
- Conversiones: 1 - 80
- Recortes: 1 - 40
- Tiempo de estabilidad: 100 - 5000

## Compatibilidad con la app actual
La app hoy consume principalmente estos parametros:
- peso
- tara
- estable

Para mantener compatibilidad:
- peso se toma de peso.
- tara se toma de tara; si viene null, usar "0".
- estable se deriva de estBalanza para el flujo actual:
  - "1" cuando estBalanza == 1 (estable)
  - "5" cuando estBalanza == 5 (pausa/lock visual en BLE)
  - "0" cuando estBalanza == 3 (hold sin lock visual)
  - "0" para cualquier otro valor

Adicionalmente, se recomienda conservar el valor original de estBalanza para futuras pantallas/estados BLE.

## Ejemplo de mapeo
Entrada BLE:

```json
{"tara":null,"hold":null,"vbat":null,"peso":35,"estBalanza":0,"humedad":60,"sensorInduc":0,"nombre":"plato1"}
```

Salida compatible actual:
- peso = "35"
- tara = "0"
- estable = "0"

Ejemplo con estado hold:

Entrada BLE:

```json
{"tara":12,"hold":1,"vbat":3.9,"peso":35,"estBalanza":3,"humedad":60,"sensorInduc":0,"nombre":"plato1"}
```

Salida compatible actual:
- peso = "35"
- tara = "12"
- estable = "0"

Ejemplo con lock visual BLE:

Entrada BLE:

```json
{"tara":12,"hold":0,"vbat":3.9,"peso":35,"estBalanza":5,"humedad":60,"sensorInduc":0,"nombre":"plato1"}
```

Salida compatible actual:
- peso = "35"
- tara = "12"
- estable = "5"
