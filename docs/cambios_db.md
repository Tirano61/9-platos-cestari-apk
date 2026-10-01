# Plan de Reforma DB (Android Nueva Instalacion)

## 1. Objetivo
Implementar una arquitectura nueva de persistencia para pesadas, separando:

1. Pesaje de 4 platos (estructura rica con porcentajes y totales por lado/eje).
2. Pesaje por ejes con 2 platos (cantidad dinamica de ejes).

La app Android se trata como instalacion nueva (package distinto), por lo tanto no se hara migracion automatica de datos locales desde la app anterior.

## 2. Alcance

1. Solo Android por ahora.
2. Instalacion nueva con identidad distinta.
3. Base de datos nueva desde cero para pesadas.
4. Mantener tabla de configuracion de conectividad.
5. Sin compatibilidad runtime con tabla legacy de pesadas.

## 3. Estado actual (referencia)

1. Tabla legacy de pesadas en `lib/BaseDeDatos/tables/db_pesadas.dart`.
2. Conexion y CRUD actuales en `lib/BaseDeDatos/connections/db_conexion.dart`.
3. Modelo legado mixto en `lib/models/pesaje_model.dart`.
4. Calculos actuales en `lib/Controllers/calculos_controllers.dart`.
5. Historial actual en `lib/Pages/pesadas/pesadas_page.dart` y `lib/Pages/pesadas/widgets/items_pesadas.dart`.
6. Exportacion actual en `lib/helpers/exportar_xml.dart`.

## 4. Decisiones de producto

1. Android-only en esta etapa.
2. Instalacion nueva (convive con app vieja).
3. Sin migracion automatica de DB local vieja.
4. Opcional futuro: importador desde XML exportado por la app anterior.
5. La exportacion se mueve al final y cambia a XLSX (no XML).
6. En XLSX se usara una hoja para `4_platos` y hojas separadas por cantidad de ejes (por ejemplo `ejes_2`, `ejes_3`, ...), creando solo las hojas que tengan datos.

## 5. Diseno de datos nuevo

### 5.1 Tabla base de pesadas (`tpesadas_base`)

Campos:

1. `id` INTEGER PRIMARY KEY AUTOINCREMENT
2. `fecha` TEXT NOT NULL
3. `hora` TEXT NOT NULL
4. `identificacion` TEXT NOT NULL DEFAULT ''
5. `tipo_pesada` TEXT NOT NULL (`4_platos` | `2_platos_ejes`)
6. `total` TEXT NOT NULL DEFAULT '0.00'
7. `created_at` TEXT NOT NULL (ISO8601)

Indices:

1. `idx_tpesadas_base_fecha` sobre `fecha`
2. `idx_tpesadas_base_tipo` sobre `tipo_pesada`

### 5.2 Tabla detalle 4 platos (`tpesadas_4platos`)

Relacion:

1. `pesada_id` FK unica a `tpesadas_base(id)`

Campos:

1. `pesada_id` INTEGER PRIMARY KEY
2. `del_izq` TEXT NOT NULL
3. `del_der` TEXT NOT NULL
4. `tras_izq` TEXT NOT NULL
5. `tras_der` TEXT NOT NULL
6. `eje_del` TEXT NOT NULL
7. `eje_tras` TEXT NOT NULL
8. `lado_izq` TEXT NOT NULL
9. `lado_der` TEXT NOT NULL
10. `por_del_izq` TEXT NOT NULL
11. `por_del_der` TEXT NOT NULL
12. `por_tras_izq` TEXT NOT NULL
13. `por_tras_der` TEXT NOT NULL
14. `por_eje_del` TEXT NOT NULL
15. `por_eje_tras` TEXT NOT NULL
16. `por_lado_izq` TEXT NOT NULL
17. `por_lado_der` TEXT NOT NULL

### 5.3 Tabla cabecera de pesaje por ejes (`tpesadas_ejes`)

Relacion:

1. `pesada_id` FK unica a `tpesadas_base(id)`

Campos:

1. `pesada_id` INTEGER PRIMARY KEY
2. `cantidad_ejes` INTEGER NOT NULL
3. `lado_izq_total` TEXT NOT NULL
4. `lado_der_total` TEXT NOT NULL

### 5.4 Tabla detalle de ejes (`tpesadas_ejes_detalle`)

Relacion:

1. FK `pesada_id` a `tpesadas_base(id)`

Campos:

1. `id` INTEGER PRIMARY KEY AUTOINCREMENT
2. `pesada_id` INTEGER NOT NULL
3. `nro_eje` INTEGER NOT NULL
4. `peso_izq` TEXT NOT NULL
5. `peso_der` TEXT NOT NULL
6. `peso_total_eje` TEXT NOT NULL

Restricciones e indices:

1. Unique `(pesada_id, nro_eje)`
2. Index `idx_tpesadas_ejes_detalle_pesada` sobre `pesada_id`

## 6. Plan de implementacion por fases

### Fase 1: Identidad Android nueva

Objetivo:

1. Asegurar que la app nueva se instala en paralelo con la vieja.

Cambios:

1. Verificar package en `android/app/src/main/AndroidManifest.xml`.
2. Ajustar `applicationId` y `namespace` en `android/app/build.gradle`.
3. Verificar package Kotlin de `MainActivity` en `android/app/src/main/kotlin`.
4. Cambiar icono y label Android.

Checklist de salida:

1. APK nueva instala sin desinstalar app anterior.
2. Icono y nombre correctos en launcher.

### Fase 2: Crear esquema DB nuevo (sin migracion legacy)

Objetivo:

1. Crear tablas nuevas en primera instalacion.

Cambios:

1. Definir SQL de tablas nuevas en `lib/BaseDeDatos/tables/db_pesadas.dart` (o archivo nuevo de tablas v2).
2. Actualizar `onCreate` en `lib/BaseDeDatos/connections/db_conexion.dart` para crear:
	- tablas pesadas nuevas
	- tabla config
3. Mantener/limpiar `onUpgrade` para config solamente si aplica.

Checklist de salida:

1. La DB se crea sin errores en instalacion limpia.
2. Existen las tablas nuevas con sus indices.

### Fase 3: Modelos de dominio nuevos

Objetivo:

1. Separar modelos de 4 platos y ejes dinamicos.

Cambios:

1. Crear modelos nuevos en `lib/models/`:
	- modelo base de pesada
	- modelo detalle 4 platos
	- modelo cabecera ejes
	- modelo detalle eje
2. Reducir dependencia de `lib/models/pesaje_model.dart` (solo transitional si hace falta).

Checklist de salida:

1. Serializacion/deserializacion valida para ambos tipos.

### Fase 4: Interfaces y servicios de persistencia

Objetivo:

1. Exponer CRUD por tipo sobre esquema nuevo.

Cambios:

1. Ampliar `lib/BaseDeDatos/interfaces/pesadas/pesadas_interfaces.dart`.
2. Actualizar `lib/BaseDeDatos/services/pesadas/service_pesadas.dart`.
3. Implementar en `lib/BaseDeDatos/connections/db_conexion.dart`:
	- insertar pesada 4 platos
	- insertar pesada por ejes (transaccion)
	- leer listado unificado
	- borrar individual y total

Checklist de salida:

1. Guardado de ambos tipos funciona.
2. Guardado por ejes se hace de forma atomica.

### Fase 5: Calculo y armado de payload por tipo

Objetivo:

1. Separar la logica de construccion de datos de guardado.

Cambios:

1. Ajustar `lib/Controllers/calculos_controllers.dart` para generar:
	- payload 4 platos completo
	- payload por ejes dinamico con lista de ejes

Checklist de salida:

1. No hay truncamiento de ejes (2..6).
2. 4 platos conserva todos sus porcentajes/totales.

### Fase 6: Historial y render por tipo

Objetivo:

1. Mostrar correctamente ambas clases de pesada.

Cambios:

1. Adaptar provider en `lib/Providers/pesadas/connections/pesadas_provider.dart`.
2. Ajustar `lib/Pages/pesadas/pesadas_page.dart`.
3. Rehacer `lib/Pages/pesadas/widgets/items_pesadas.dart` con render por `tipo_pesada`.

Checklist de salida:

1. Historial lista y renderiza 4 platos y ejes dinamicos correctamente.

### Fase 7: Exportacion nueva

Objetivo:

1. Exportar desde el esquema nuevo sin perder detalle en formato XLSX.

Cambios:

1. Reemplazar exportacion XML por exportacion XLSX.
2. Crear una hoja para `4_platos`.
3. Crear hojas por cantidad de ejes (`ejes_2`, `ejes_3`, ... `ejes_6`) solo si existen pesadas de ese grupo.
4. Mantener compatibilidad de accion de compartir/guardar archivo desde Android.

Checklist de salida:

1. XLSX incluye datos completos de 4 platos.
2. XLSX incluye datos completos de ejes dinamicos agrupados por cantidad de ejes en hojas separadas.
3. No se generan hojas vacias.

### Fase 8: Limpieza tecnica

Objetivo:

1. Eliminar deuda legacy no usada en la app nueva.

Cambios:

1. Marcar y retirar rutas legacy de pesadas no utilizadas.
2. Mantener solo lo necesario para configuracion.

Checklist de salida:

1. Codigo sin ramas muertas ni modelos mixtos ambiguos.

## 7. Lista de pruebas obligatorias

### 7.1 Funcionales

1. Guardar pesada 4 platos.
2. Guardar pesada por ejes con 2 ejes.
3. Guardar pesada por ejes con 3 ejes.
4. Guardar pesada por ejes con 4 ejes.
5. Guardar pesada por ejes con 5 ejes.
6. Guardar pesada por ejes con 6 ejes.
7. Listar historial con mezcla de tipos.
8. Borrar pesada individual.
9. Borrar todas las pesadas.
10. Exportar XLSX con hojas separadas por tipo/cantidad de ejes.

### 7.2 Tecnicas

1. `flutter analyze` sin errores nuevos bloqueantes.
2. `fvm flutter build apk --debug` exitoso.
3. Instalacion de APK en Android limpia.

## 8. Riesgos y mitigaciones

1. Riesgo: perdida de historicos de app vieja.
	- Mitigacion: documentar que no hay migracion local automatica; opcional importador XML.
2. Riesgo: inconsistencia cabecera/detalle por ejes.
	- Mitigacion: transacciones DB y constraints unique.
3. Riesgo: exportaciones incompletas.
	- Mitigacion: pruebas de export con casos 2..6 ejes y 4 platos.

## 9. Criterio de aceptacion final

1. App Android nueva instalada y operativa.
2. Persistencia nueva separada por tipo funcionando.
3. Historial y exportacion completos en ambos tipos.
4. Sin dependencia funcional de tabla legacy de pesadas.

## 10. Bitacora de ejecucion

Usar esta seccion para registrar avances por fase.

### Registro

1. Fecha: 24/08/2026
2. Fase: Fase 3 (Modelos de dominio nuevos)
3. Archivos tocados:
	- lib/models/pesadas/pesada_base_model.dart
	- lib/models/pesadas/pesada_4platos_model.dart
	- lib/models/pesadas/pesada_ejes_model.dart
	- lib/models/pesadas/pesada_eje_detalle_model.dart
	- lib/models/pesaje_model.dart
	- lib/BaseDeDatos/connections/db_conexion.dart
4. Resultado: Modelos separados por tipo creados y utilizados en la capa DB, manteniendo compatibilidad transicional con Pesaje.
5. Pendientes: Reducir progresivamente el uso del modelo mixto Pesaje en capas superiores.

1. Fecha: 24/08/2026
2. Fase: Fase 4 (Interfaces y servicios de persistencia)
3. Archivos tocados:
	- lib/BaseDeDatos/interfaces/pesadas/pesadas_interfaces.dart
	- lib/BaseDeDatos/services/pesadas/service_pesadas.dart
	- lib/BaseDeDatos/connections/db_conexion.dart
	- test/moks/db_connection_mock.dart
4. Resultado: Contrato de persistencia ampliado con operaciones tipadas para 4 platos y por ejes; DB y servicio implementados con compatibilidad legacy.
5. Pendientes: Empezar a consumir los metodos tipados desde capas de aplicacion para desacoplar insert/get legacy.

1. Fecha: 24/08/2026
2. Fase: Fase 5 (Calculo y armado de payload por tipo)
3. Archivos tocados:
	- lib/models/pesadas/pesada_payload_model.dart
	- lib/Controllers/calculos_controllers.dart
4. Resultado: El controlador ahora genera payloads tipados para 4 platos y por ejes; los metodos legacy de calculo se mantienen como adaptadores para no romper UI actual.
5. Pendientes: Empezar a guardar usando payload tipado desde el flujo UI (en lugar de pasar Pesaje mixto), como paso previo a limpieza final.

1. Fecha: 24/08/2026
2. Fase: Fase 6 (Historial y render por tipo)
3. Archivos tocados:
	- lib/Pages/cuatro_platos/widgets/dialog_widget.dart
	- lib/BaseDeDatos/helpers/pesadas/helpers_pesadas.dart
	- lib/Pages/cuatro_platos/cuatro_platos_page.dart
	- lib/Pages/por_ejes/por_multi_ejes_page.dart
	- lib/Pages/por_ejes/por_ejes_page.dart
4. Resultado: El flujo de guardado de UI ahora consume payloads tipados (4 platos/ejes) y usa metodos tipados del servicio, manteniendo feedback de guardado y compatibilidad de dialogo.
5. Pendientes: Consolidar exportacion final XLSX por hojas (fase 7).

1. Fecha: 24/08/2026
2. Fase: Fase 8 (Limpieza tecnica parcial)
3. Archivos tocados:
	- lib/models/pesaje_model.dart
	- lib/BaseDeDatos/connections/db_conexion.dart
	- lib/Pages/pesadas/widgets/items_pesadas.dart
	- lib/Pages/pesadas/pesadas_page.dart
4. Resultado: Historial y altura de tarjetas migrados a tipo/cantidad de ejes explicitos (`tipoPesada`, `cantidadEjes`) reduciendo heuristicas legacy basadas en campos mixtos.
5. Pendientes: Retirar usos legacy restantes de `Pesaje` y completar exportacion XLSX para cierre final.

1. Fecha: 24/08/2026
2. Fase: Fase 7 (Exportacion nueva)
3. Archivos tocados:
	- pubspec.yaml
	- lib/helpers/exportar_xml.dart
4. Resultado: Exportacion migrada a XLSX (`pesadas.xlsx`) con creacion condicional de hojas: `4_platos` solo si hay datos de 4 platos y `ejes_N` solo si hay pesadas de esa cantidad de ejes.
5. Pendientes: Ninguno para exportacion XLSX.

1. Fecha: 24/08/2026
2. Fase: Fase 8 (Limpieza tecnica)
3. Archivos tocados:
	- lib/helpers/exportar_xml.dart
	- lib/helpers/xml_variables.dart (eliminado)
4. Resultado: Se elimino deprecacion de compartir (`shareFiles` -> `shareXFiles`) y se retiro helper XML legacy sin referencias activas.
5. Pendientes: Continuar limpieza de lints generales fuera del alcance de exportacion.

