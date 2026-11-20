# svg_oberflaeche

Gemeinsame Oberfläche der Apps des Stadtverbands der Gartenfreunde Halle/Saale
(Kleingartenverwaltung, Gartenvergabe, Gartenbegehung, Kassenbuch).
Version 0.1.0 – Stand 20.11.2026. Referenz für Farben und Aufbau ist die
Kleingartenverwaltung.

Jede App bleibt für sich lauffähig: Der Baustein wird beim Bauen fest in die
App eingebunden, eine Verbindung zu den anderen Apps braucht es nicht.

## Grundregel

**Rund = Aktion, eckig = Eingabe.**

| Rolle | Aussehen | Flutter |
|---|---|---|
| Hauptaktion (höchstens eine je Bereich) | blau gefüllt, rund, 40 px | `FilledButton` |
| Nebenaktion (Export, Import, PDF …) | weiß, grauer Rahmen, rund | `OutlinedButton` |
| Zurückhaltend (Abbrechen) | nur Text | `TextButton` |
| Gefährlich | roter Rahmen / im Dialog rot gefüllt | `svgGefahrRahmen()` / `svgGefahrBestaetigen()` |
| Eingabe | eckig, weiß, Rahmen, 48 px | `TextField` (über das Thema) |

Schrift: nur vier Größen – 22 Seitentitel, 17 Abschnitt, 14 Text, 12 Hinweis.

## Was es kann

| Baustein | Aufgabe |
|---|---|
| `svgThema()` | Komplettes `ThemeData` nach der Grundregel |
| `SvgFarben` | Alle Farben (Blau #2F80ED, Text, Rahmen, Einnahme/Ausgabe zart …) |
| `zeigeSnackBar(context, SnackBar(...))` | Bestätigung als Leiste **oben** im bearbeiteten Bereich, Fehler/Hinweise als Fenster mit OK. Schaltflächen wie „Öffnen“ bleiben erhalten. |
| `SvgSortierung`, `svgSpalte()` | Tabellen über die Spaltenköpfe sortieren (Zahlen natürlich: 2 vor 10) |
| `SvgTabelle` | Tabelle nutzt immer die volle Breite, bei Bedarf waagerecht schiebbar |

## Standard für Tabellen

* **Listen** (Konten, Regeln, Journal, Parzellen, Mitglieder …): immer über die
  Spaltenköpfe sortierbar, ein Klick sortiert, ein zweiter dreht die Richtung.
  Spalten mit Beträgen als `numeric`. Aktions-Spalten nicht sortierbar.
* **Berichte mit Summenzeilen** (EÜR, Plan/Ist, Jahresvergleich): feste
  Reihenfolge wie im Formular – dort nicht sortieren.
* Alle Tabellen über `SvgTabelle` in voller Breite.
* Zeilen nur bei Ausnahmen tönen (gelöscht, storniert, nicht zugeordnet),
  nie für den Normalfall.

## Einbinden

```yaml
dependencies:
  svg_oberflaeche:
    git:
      url: https://github.com/SVGSiegmar/svg_oberflaeche.git
      ref: v0.1.0
```

```dart
import 'package:svg_oberflaeche/svg_oberflaeche.dart';

MaterialApp(theme: svgThema(), ...);
zeigeSnackBar(context, const SnackBar(content: Text('Gespeichert.')));
```

Apps, die bisher eine eigene `zeigeSnackBar` haben (Kleingartenverwaltung),
löschen ihre Fassung und importieren den Baustein – die Aufrufe bleiben gleich.

## Tests

```
flutter pub get
flutter test
```
