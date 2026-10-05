import 'package:flutter/material.dart';

import 'package:nueve_platos_cestari/Theme/theme.dart';
import 'package:nueve_platos_cestari/models/ensayos/maniobra_model.dart';

class HelpersEnsayos {

  /// Avisa si la [maniobra] que devolvio EnsayoController.terminarManiobra
  /// quedo guardada en la base.
  static void avisarGuardado(ScaffoldMessengerState messenger, ManiobraModel maniobra) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          maniobra.guardada
              ? 'Maniobra ${maniobra.numero} guardada.'
              : 'No se pudo guardar la maniobra ${maniobra.numero}.',
        ),
        backgroundColor: maniobra.guardada ? ThemePlatos.positiveColor : ThemePlatos.errorColor,
        duration: Duration(seconds: maniobra.guardada ? 2 : 4),
      ),
    );
  }

}
