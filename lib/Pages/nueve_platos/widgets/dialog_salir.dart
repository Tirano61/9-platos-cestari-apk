import 'package:flutter/material.dart';

import 'package:nueve_platos_cestari/Controllers/ensayo_controller.dart';

/// Titulo, mensaje y texto del boton para confirmar la salida de la
/// pantalla de pesaje, segun en que punto esta el ensayo. [numeroManiobra]
/// es el de `EnsayoController` (con una maniobra en curso, es el de esa).
({String titulo, String mensaje, String accion}) mensajeSalida({
  required EstadoEnsayo estado,
  required int numeroManiobra,
  required bool hayEstatico,
}) {
  final registrando = estado == EstadoEnsayo.registrando;
  final guardadas = registrando ? numeroManiobra - 1 : numeroManiobra;
  final lineas = [
    if (registrando) 'La maniobra $numeroManiobra, que está en curso, se descarta y no se guarda.',
    if (guardadas > 0)
      guardadas == 1
          ? 'La maniobra que ya terminaste queda guardada en el historial.'
          : 'Las $guardadas maniobras que ya terminaste quedan guardadas en el historial.'
    else if (!registrando)
      'Todavía no registraste ninguna maniobra: este ensayo no se guarda.',
    if (hayEstatico) 'El estático tomado se pierde.',
    'Para seguir midiendo vas a tener que iniciar un ensayo nuevo.',
  ];
  return (
    titulo: registrando ? 'Maniobra en curso' : 'Salir del ensayo',
    mensaje: lineas.join('\n\n'),
    accion: registrando ? 'Descartar y salir' : 'Salir',
  );
}

/// Pide confirmacion para salir de la pantalla de pesaje. Devuelve true si
/// el usuario acepto.
Future<bool> confirmarSalida(BuildContext context, EnsayoController ensayo) async {
  final texto = mensajeSalida(
    estado: ensayo.estado.value,
    numeroManiobra: ensayo.numeroManiobra.value,
    hayEstatico: ensayo.hayEstatico,
  );
  final salir = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(texto.titulo),
      content: Text(texto.mensaje),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Seguir'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(texto.accion),
        ),
      ],
    ),
  );
  return salir ?? false;
}
