import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:nueve_platos_cestari/BaseDeDatos/helpers/pesadas/helpers_pesadas.dart';
import 'package:nueve_platos_cestari/Controllers/controllers_export.dart';
import 'package:nueve_platos_cestari/Controllers/multi_ejes_controller.dart';
import 'package:nueve_platos_cestari/models/pesadas/pesada_payload_model.dart';
import 'package:nueve_platos_cestari/Pages/cuatro_platos/widgets/export_home_wigets.dart';
import 'package:nueve_platos_cestari/Pages/por_ejes/widgets/fila_platos_ejes.dart';
import 'package:nueve_platos_cestari/config/SizeScreen.dart';
import 'package:nueve_platos_cestari/config/theme.dart';

class PorMultiEjesPage extends StatelessWidget {
  PorMultiEjesPage({
    super.key,
    required this.numEjes,
    required this.title,
    required this.controllerTag,
  });

  final int numEjes;
  final String title;
  final String controllerTag;

  final peso1GetxController = Get.find<Peso1Controller>();
  final peso2GetxController = Get.find<Peso2Controller>();

  @override
  Widget build(BuildContext context) {
    final ejesController = Get.find<MultiEjesController>(tag: controllerTag);
    final media = MediaQuery.of(context);
    final isSmallPhone = media.size.height < 700;
    final fabReserveSpace = isSmallPhone ? 120.0 : 92.0;

    return Obx(() {
      final plato1 = peso1GetxController.getPesoModel1;
      final plato2 = peso2GetxController.getPesoModel2;

      ejesController.syncPesosEjeActual(
        pesoIzquierdo: _toFixedPeso(plato1.peso),
        pesoDerecho: _toFixedPeso(plato2.peso),
      );

      final ejes = ejesController.snapshotEjes();
      final ejesCompletados = ejes.where((eje) => eje.status == EstadoEje.completed);

      final totalCompletado = ejesCompletados.fold<double>(
        0,
        (sum, eje) => sum + (double.tryParse(eje.totalWeight) ?? 0),
      );

      final ejeActivo = ejesController.currentAxleIndex;
      final siguienteEje = ejesController.siguienteEjePendiente(fromEje: ejeActivo);

      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: fabReserveSpace),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: SizeScreen.sc().screenWidth * 0.02,
                  bottom: SizeScreen.sc().screenWidth * 0.035,
                ),
                child: RecuadroPesoTotal(
                  suma: totalCompletado.toStringAsFixed(2),
                ),
              ),
              _buildIndicacionCambioEje(
                context: context,
                ejeActivo: ejeActivo,
                siguienteEje: siguienteEje,
              ),
              for (final eje in ejes)
                _buildEjeContainer(
                  context: context,
                  axle: eje,
                  ejesController: ejesController,
                  plato1: plato1,
                  plato2: plato2,
                ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: Container(
          decoration: BoxDecoration(
            boxShadow: const [
              BoxShadow(
                color: Color.fromARGB(107, 3, 3, 3),
                offset: Offset(0.3, 3),
                blurRadius: 3,
                spreadRadius: 0.3,
                blurStyle: BlurStyle.normal,
              ),
            ],
            borderRadius: BorderRadius.circular(50),
          ),
          child: IconButton(
            padding: EdgeInsets.all(SizeScreen.sc().isMinWidth ? 25 : 15),
            color: ThemeApp.colorPesoPlatos,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
                if (states.contains(WidgetState.pressed)) {
                  return Theme.of(context).colorScheme.primary.withValues(alpha: 0.5);
                }
                return ThemeApp.colorPesoPlatos;
              }),
            ),
            icon: const Icon(
              Icons.save,
              color: Color.fromARGB(172, 255, 255, 255),
            ),
            onPressed: () async {
              if (!ejesController.allEjesGuardados) {
                final siguientePendiente = ejesController.siguienteEjePendiente(fromEje: 1);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Primero guarde todos los ejes. Pendiente: eje ${siguientePendiente ?? ejeActivo}.',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
                return;
              }

              final pesos = ejesController.snapshotPesos();
              final payload = await CalculosController.cn.calcularPayloadPorEjes(
                pesosPorPlato: pesos,
              );

              if (!context.mounted) return;
              await showDialogGuardarPesada(
                payload: payload,
                context: context,
                ejesController: ejesController,
              );
            },
          ),
        ),
      );
    });
  }

  Widget _buildEjeContainer({
    required BuildContext context,
    required AxleData axle,
    required MultiEjesController ejesController,
    required dynamic plato1,
    required dynamic plato2,
  }) {
    final labels = _labelsPorEje(axle.index);
    final leftIndex = ejesController.platoIzquierdoIndex(axle.index);
    final rightIndex = ejesController.platoDerechoIndex(axle.index);
    final Color colorEstado = _colorPorEstado(axle.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: colorEstado,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderPorEstado(axle.status)),
      ),
      child: GestureDetector(
        onTap: () {
          final ejeActual = ejesController.currentAxleIndex;
          final ejeActualGuardado = ejesController.isEjeGuardado(ejeActual);

          if (!ejeActualGuardado && axle.index != ejeActual) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Primero guarde el eje $ejeActual para continuar.'),
                duration: const Duration(seconds: 2),
              ),
            );
            return;
          }

          ejesController.setEjeActivo(axle.index);

          if (ejesController.isEjeGuardado(axle.index)) {
            ejesController.setSaveEje(axle.index, false);
          }
        },
        child: FilaPlatosEjes(
          widget: Column(
            children: [
              _chipEstado(axle),
              EjeWidget(
                peso1: ejesController.getPlatoPeso(leftIndex),
                peso2: ejesController.getPlatoPeso(rightIndex),
                eje: axle.index.toString(),
                label: labels.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: axle.index == ejesController.currentAxleIndex
                    ? () {
                        final ejeActual = ejesController.currentAxleIndex;

                        ejesController.guardarEjeActual(
                          pesoIzquierdo: _toFixedPeso(plato1.peso),
                          pesoDerecho: _toFixedPeso(plato2.peso),
                        );

                        final siguiente = ejesController.currentAxleIndex == ejeActual
                            ? null
                            : ejesController.currentAxleIndex;

                        if (siguiente != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Eje $ejeActual guardado. Eje $siguiente activo.',
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ultimo eje guardado. Ya puede finalizar la pesada.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    : null,
                child: Text('Guardar Eje ${axle.index}'),
              ),
            ],
          ),
          pesoPlato1: ejesController.getPlatoPeso(leftIndex),
          pesoPlato2: ejesController.getPlatoPeso(rightIndex),
          activo: axle.status == EstadoEje.active,
          plato1: plato1,
          plato2: plato2,
          label1: labels.left,
          label2: labels.right,
          // En pesaje por ejes siempre se usan los platos fisicos 1 y 2.
          buttonKeyPlato1: const ValueKey('1'),
          buttonKeyPlato2: const ValueKey('2'),
          estable1: plato1.estable,
          estable2: plato2.estable,
        ),
      ),
    );
  }

  Widget _chipEstado(AxleData axle) {
    final text = switch (axle.status) {
      EstadoEje.active => 'EJE ACTIVO',
      EstadoEje.completed => 'EJE COMPLETADO',
      EstadoEje.pending => 'EJE PENDIENTE',
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        '$text - ${axle.index}',
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  ({String left, String right, String center}) _labelsPorEje(int eje) {
    return (
      left: 'EJE $eje IZQ',
      right: 'EJE $eje DER',
      center: 'EJE $eje',
    );
  }

  Color _colorPorEstado(EstadoEje estado) {
    switch (estado) {
      case EstadoEje.active:
        return const Color.fromARGB(72, 9, 172, 96);
      case EstadoEje.completed:
        return const Color.fromARGB(40, 39, 129, 255);
      case EstadoEje.pending:
        return Colors.transparent;
    }
  }

  Color _borderPorEstado(EstadoEje estado) {
    switch (estado) {
      case EstadoEje.active:
        return const Color.fromARGB(160, 9, 172, 96);
      case EstadoEje.completed:
        return const Color.fromARGB(140, 39, 129, 255);
      case EstadoEje.pending:
        return const Color.fromARGB(45, 0, 0, 0);
    }
  }

  Widget _buildIndicacionCambioEje({
    required BuildContext context,
    required int ejeActivo,
    required int? siguienteEje,
  }) {
    final mensaje = siguienteEje == null
        ? 'Todos los ejes guardados. Presione guardar para finalizar la pesada.'
        : 'Eje activo: $ejeActivo. Al guardar, avanza al eje $siguienteEje.';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color.fromARGB(22, 9, 172, 96),
        border: Border.all(color: const Color.fromARGB(130, 9, 172, 96)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(
                fontSize: SizeScreen.sc().isMinWidth ? 14 : 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showDialogGuardarPesada({
    required PesadaEjesPayload payload,
    required BuildContext context,
    required MultiEjesController ejesController,
  }) async {
    final guardado = await showDialog<bool>(
      context: context,
      builder: (_) {
        return DialogWidget(
          onConfirm: (identificacion) {
            return HelpersPesadas.guardarPesadaEjesPayload(
              payload: payload,
              identificacion: identificacion,
              context: context,
            );
          },
        );
      },
    );

    if (guardado == true) {
      ejesController.resetPesaje();
    }
  }

  String _toFixedPeso(String peso) {
    return (double.tryParse(peso) ?? 0).toStringAsFixed(2);
  }
}
