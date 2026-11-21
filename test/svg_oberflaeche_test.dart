import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:svg_oberflaeche/svg_oberflaeche.dart';

Widget _app(Widget kind) =>
    MaterialApp(theme: svgThema(), home: Scaffold(body: kind));

void main() {
  testWidgets('Bestätigung erscheint oben als Leiste und verschwindet',
      (tester) async {
    await tester.pumpWidget(_app(Builder(
      builder: (context) => FilledButton(
        onPressed: () => zeigeSnackBar(
            context, const SnackBar(content: Text('Gespeichert.'))),
        child: const Text('Speichern'),
      ),
    )));
    await tester.tap(find.text('Speichern'));
    await tester.pump();
    expect(find.text('Gespeichert.'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    await tester.pump(const Duration(seconds: 6));
    expect(find.text('Gespeichert.'), findsNothing);
  });

  testWidgets('Fehler erscheint als Hinweisfenster mit OK', (tester) async {
    await tester.pumpWidget(_app(Builder(
      builder: (context) => FilledButton(
        onPressed: () => zeigeSnackBar(context,
            const SnackBar(content: Text('Datei konnte nicht gelesen werden.'))),
        child: const Text('Import'),
      ),
    )));
    await tester.tap(find.text('Import'));
    await tester.pumpAndSettle();
    expect(find.text('Hinweis'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Hinweis'), findsNothing);
  });

  test('Sortierung: Zahlen natürlich, Umlaute wie Grundbuchstaben', () {
    final s = SvgSortierung();
    expect(s.sortiere(['10 Zaun', '2 Weg', '1 Tor'], (e, _) => e),
        ['1 Tor', '2 Weg', '10 Zaun']);
    expect(s.sortiere(['Zaun', 'Äpfel', 'Birne'], (e, _) => e),
        ['Äpfel', 'Birne', 'Zaun']);
    s.setze(0, false);
    expect(s.sortiere(['a', 'c', 'b'], (e, _) => e), ['c', 'b', 'a']);
  });

  testWidgets('SvgTabelle nutzt die volle Breite', (tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 600));
    await tester.pumpWidget(_app(SvgTabelle(
      tabelle: DataTable(
          columns: const [DataColumn(label: Text('A'))],
          rows: const [DataRow(cells: [DataCell(Text('1'))])]),
    )));
    expect(tester.getSize(find.byType(DataTable)).width, 1200);
    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Liste: Kopf bleibt stehen, nur Zeilen scrollen', (tester) async {
    int? sortiert;
    await tester.pumpWidget(_app(SvgListenSeite(
      kopf: const Text('Kopfbereich'),
      liste: SvgListe(
        spalten: const [
          SvgListenSpalte('Nr.', breite: 80),
          SvgListenSpalte('Name', breite: 200),
          SvgListenSpalte('Betrag', breite: 120, zahl: true),
        ],
        anzahl: 200,
        beiSortieren: (s, a) => sortiert = s,
        zelle: (i, s) => Text('Z$i S$s'),
      ),
    )));
    expect(find.text('Name'), findsOneWidget);
    await tester.drag(find.text('Z3 S1'), const Offset(0, -2000));
    await tester.pump();
    // Kopf und Kopfbereich sind weiterhin sichtbar
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Kopfbereich'), findsOneWidget);
    expect(find.text('Z3 S1'), findsNothing);
    await tester.tap(find.text('Betrag'));
    expect(sortiert, 2);
    expect(tester.takeException(), isNull);
  });
}
