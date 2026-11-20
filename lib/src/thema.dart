import 'package:flutter/material.dart';

import 'farben.dart';

const double _knopfHoehe = 40;
final _rund = RoundedRectangleBorder(borderRadius: BorderRadius.circular(20));
const _knopfPolster = EdgeInsets.symmetric(horizontal: 18);

/// Einheitliches Thema der SVG-Apps.
///
/// * Hauptaktion: blau gefüllt, rund ([FilledButton])
/// * Nebenaktion: grauer Rahmen, dunkle Schrift, rund ([OutlinedButton])
/// * Zurückhaltend: nur Text ([TextButton])
/// * Eingabe: eckig, weiß, deutlicher Rahmen, 48 px hoch
/// * Schrift: vier Größen – 22 Seitentitel, 17 Abschnitt, 14 Text, 12 Hinweis
ThemeData svgThema({Color grundfarbe = SvgFarben.blau}) {
  final scheme = ColorScheme.fromSeed(
      seedColor: grundfarbe, brightness: Brightness.light);
  final basis = ThemeData(useMaterial3: true).textTheme;
  final schrift = basis
      .copyWith(
        headlineLarge: basis.headlineLarge
            ?.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
        headlineMedium: basis.headlineMedium
            ?.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
        headlineSmall: basis.headlineSmall
            ?.copyWith(fontSize: 22, fontWeight: FontWeight.w600),
        titleLarge: basis.titleLarge
            ?.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
        titleMedium: basis.titleMedium
            ?.copyWith(fontSize: 17, fontWeight: FontWeight.w600),
        titleSmall: basis.titleSmall
            ?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
        bodyLarge: basis.bodyLarge?.copyWith(fontSize: 14),
        bodyMedium: basis.bodyMedium?.copyWith(fontSize: 14),
        bodySmall: basis.bodySmall
            ?.copyWith(fontSize: 12, color: SvgFarben.textGedaempft),
        labelLarge: basis.labelLarge?.copyWith(fontSize: 14),
        labelMedium: basis.labelMedium?.copyWith(fontSize: 12),
        labelSmall: basis.labelSmall?.copyWith(fontSize: 12),
      )
      .apply(bodyColor: SvgFarben.text, displayColor: SvgFarben.text);

  final eckig = OutlineInputBorder(
      borderRadius: BorderRadius.circular(4),
      borderSide: const BorderSide(color: SvgFarben.feldRahmen));

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme.copyWith(
        primary: grundfarbe, secondary: grundfarbe, error: SvgFarben.gefahr),
    textTheme: schrift,
    scaffoldBackgroundColor: SvgFarben.hintergrund,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: SvgFarben.rahmen)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: eckig,
      enabledBorder: eckig,
      focusedBorder: eckig.copyWith(
          borderSide: BorderSide(color: grundfarbe, width: 2)),
      labelStyle: const TextStyle(color: SvgFarben.textGedaempft),
      floatingLabelStyle: TextStyle(color: grundfarbe),
    ),
    filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
            backgroundColor: grundfarbe,
            foregroundColor: Colors.white,
            minimumSize: const Size(0, _knopfHoehe),
            padding: _knopfPolster,
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            shape: _rund)),
    outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
            foregroundColor: SvgFarben.text,
            backgroundColor: Colors.white,
            side: const BorderSide(color: SvgFarben.rahmen),
            minimumSize: const Size(0, _knopfHoehe),
            padding: _knopfPolster,
            textStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            shape: _rund)),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            elevation: 0,
            foregroundColor: SvgFarben.text,
            backgroundColor: Colors.white,
            side: const BorderSide(color: SvgFarben.rahmen),
            minimumSize: const Size(0, _knopfHoehe),
            padding: _knopfPolster,
            shape: _rund)),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
            foregroundColor: grundfarbe,
            minimumSize: const Size(0, _knopfHoehe),
            shape: _rund)),
    dataTableTheme: const DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(SvgFarben.tabellenKopf),
      headingTextStyle:
          TextStyle(fontWeight: FontWeight.w600, color: SvgFarben.text),
      dataRowMinHeight: 44,
      dataRowMaxHeight: 56,
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: Colors.white,
      side: BorderSide(color: SvgFarben.rahmen),
      labelStyle: TextStyle(fontSize: 12, color: SvgFarben.text),
    ),
  );
}

/// Gefährliche Aktion als Nebenaktion (roter Rahmen).
ButtonStyle svgGefahrRahmen() => OutlinedButton.styleFrom(
    foregroundColor: SvgFarben.gefahr,
    side: const BorderSide(color: SvgFarben.gefahr));

/// Gefährliche Aktion im Bestätigungsdialog (rot gefüllt).
ButtonStyle svgGefahrBestaetigen() => FilledButton.styleFrom(
    backgroundColor: SvgFarben.gefahr, foregroundColor: Colors.white);
