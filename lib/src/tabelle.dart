import 'package:flutter/material.dart';

/// Tabelle, die immer die volle verfügbare Breite nutzt.
///
/// Ist die Tabelle schmaler als der Platz, wird sie auf die volle Breite
/// gestreckt (Spalten verteilen sich). Ist sie breiter, kann man sie
/// waagerecht schieben. So enden alle Tabellen einer App am selben Rand.
class SvgTabelle extends StatelessWidget {
  const SvgTabelle({super.key, required this.tabelle});

  /// Die eigentliche [DataTable].
  final DataTable tabelle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, grenzen) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          // Bei unbegrenzter Breite (z. B. in einer Zeile) nicht strecken.
          constraints: BoxConstraints(
              minWidth: grenzen.hasBoundedWidth ? grenzen.maxWidth : 0),
          child: tabelle,
        ),
      ),
    );
  }
}
