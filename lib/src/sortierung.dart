import 'package:flutter/material.dart';

/// Sortierung einer Tabelle über die Spaltenköpfe.
///
/// ```dart
/// final sortierung = SvgSortierung(spalte: 0);
/// ...
/// final zeilen = sortierung.sortiere(konten, (k, spalte) => switch (spalte) {
///   0 => k.nummer, 1 => k.name, _ => k.bereich });
/// DataTable(
///   sortColumnIndex: sortierung.spalte,
///   sortAscending: sortierung.aufsteigend,
///   columns: [
///     svgSpalte('Nr.', (i, a) => setState(() => sortierung.setze(i, a))),
///     ...
/// ```
class SvgSortierung {
  SvgSortierung({this.spalte = 0, this.aufsteigend = true});

  int spalte;
  bool aufsteigend;

  void setze(int neueSpalte, bool neuAufsteigend) {
    spalte = neueSpalte;
    aufsteigend = neuAufsteigend;
  }

  /// Gibt eine sortierte Kopie zurück. [schluessel] liefert den Text der
  /// Zelle für die gewählte Spalte. Zahlen am Anfang (Kontonummern,
  /// Parzellen 2 / 10) werden als Zahl verglichen, Groß/klein ignoriert.
  List<T> sortiere<T>(
      List<T> liste, String Function(T eintrag, int spalte) schluessel) {
    final kopie = [...liste];
    kopie.sort((a, b) {
      final c = svgVergleiche(schluessel(a, spalte), schluessel(b, spalte));
      return aufsteigend ? c : -c;
    });
    return kopie;
  }
}

final _fuehrendeZahl = RegExp(r'^\s*(\d+)');

/// Vergleicht zwei Zellen „natürlich“: 2 vor 10, „Äpfel“ wie „Apfel“.
int svgVergleiche(String a, String b) {
  final za = _fuehrendeZahl.firstMatch(a);
  final zb = _fuehrendeZahl.firstMatch(b);
  if (za != null && zb != null) {
    final c = int.parse(za.group(1)!).compareTo(int.parse(zb.group(1)!));
    if (c != 0) return c;
  }
  return _normal(a).compareTo(_normal(b));
}

String _normal(String s) => s
    .toLowerCase()
    .replaceAll('ä', 'a')
    .replaceAll('ö', 'o')
    .replaceAll('ü', 'u')
    .replaceAll('ß', 'ss');

/// Spaltenkopf, der beim Anklicken sortiert.
DataColumn svgSpalte(String titel, void Function(int spalte, bool aufsteigend) beimSortieren,
        {bool zahl = false}) =>
    DataColumn(label: Text(titel), numeric: zahl, onSort: beimSortieren);
