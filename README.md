# Platos Cestari

App Android de Balanzas Hook para pesar con 9 balanzas ("platos") por WiFi UDP. La usa una tolva grande de 3 ejes que tiene 9 celdas: 4 juegos de celdas izquierda/derecha y 1 celda en el enganche.

## Ramas

`main` es la rama principal (`origin/main`). Los cambios llegan en ramas cortas, cada una con su PR a `main`.

## Historial

01/10/2026: el repo arranca como copia de la app "Cuatro Platos" (4 platos / ejes, WiFi y BLE). El plan para pasarla a 9 platos solo por WiFi UDP está en [docs/plan_9_platos.md](docs/plan_9_platos.md).

02/10/2026: paquete `nueve_platos_cestari`, applicationId `com.dramirez.nueveplatoscestari` y nombre "Platos Cestari" (PR 2). Se quita Bluetooth LE: queda solo WiFi UDP (PR 3). Se quita el pesaje por ejes (PR 4).
Un solo `PesoController` por plato (PR 5). Configuración y conexión de 9 platos, puertos 8001..8009 (PR 6). Modelo, cálculos y tabla `tpesadas_9platos` (PR 7). Pantalla de pesaje con enganche, 4 juegos y lados (PR 8). Historial y exportación XLSX de 9 platos (PR 9). `CLAUDE.md` reescrito para la app final y se borra `docs/cambios_db.md` (PR 10). La reforma está completa.
