import 'package:flutter/material.dart';

/// Farben der SVG-Apps (Referenz: Kleingartenverwaltung).
class SvgFarben {
  SvgFarben._();

  /// Hauptaktion, Auswahl, Fokus (kAppBlau)
  static const blau = Color(0xFF2F80ED);
  static const blauZart = Color(0xFFEAF2FD);

  /// Überschriften und Text (kTextDunkel)
  static const text = Color(0xFF1F2D3D);
  static const textGedaempft = Color(0xFF5B6B7C);

  /// Rahmen von Karten und Nebenaktionen (kRahmen)
  static const rahmen = Color(0xFFD5DEE8);

  /// Rahmen von Eingabefeldern (etwas kräftiger, damit Felder erkennbar sind)
  static const feldRahmen = Color(0xFFB8C4D2);

  /// Seitenhintergrund
  static const hintergrund = Color(0xFFF4F7FB);

  /// Kopfzellen von Tabellen (kFlaecheLabel)
  static const tabellenKopf = Color(0xFFF1F4F8);

  /// Auszufüllende Felder, dezent gelb (kFlaecheEingabe)
  static const eingabe = Color(0xFFFFF6D9);

  /// Einnahme / Ausgabe / Prüfen: zarte Tönung mit dunkler Schrift
  static const einnahmeZart = Color(0xFFE6F4EC);
  static const einnahmeText = Color(0xFF1E6B45);
  static const ausgabeZart = Color(0xFFFBE9E7);
  static const ausgabeText = Color(0xFF9B2C20);
  static const hinweisZart = Color(0xFFFFF3DC);
  static const hinweisText = Color(0xFF7A4D00);

  /// Bestätigung (Haken in der Meldungsleiste)
  static const erfolg = Color(0xFF1B7F5A);

  /// Gefährliche Aktionen (Löschen, Zurücksetzen)
  static const gefahr = Color(0xFFC0392B);
  static const warnungOrange = Color(0xFFE65100);
}
