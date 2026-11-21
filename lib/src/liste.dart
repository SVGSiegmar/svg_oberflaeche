import 'package:flutter/material.dart';

import 'farben.dart';

/// Eine Spalte einer [SvgListe].
class SvgListenSpalte {
  const SvgListenSpalte(
    this.titel, {
    this.breite = 120,
    this.flex = 1,
    this.zahl = false,
    this.sortierbar = true,
  });

  final String titel;

  /// Mindestbreite in Pixeln.
  final double breite;

  /// Anteil am übrigen Platz, wenn die Liste breiter ist als alle
  /// Mindestbreiten zusammen (0 = Spalte wächst nicht mit).
  final int flex;

  /// Rechtsbündig (Beträge).
  final bool zahl;

  /// Spaltenkopf zum Sortieren anklickbar.
  final bool sortierbar;
}

/// Lange Tabelle mit **festem Spaltenkopf**: Nur die Zeilen scrollen, Kopf,
/// Bearbeitungsleiste ([unterKopf]) und Summenzeile ([fuss]) bleiben stehen.
///
/// Braucht eine begrenzte Höhe (z. B. in [SvgListenSeite] oder `Expanded`).
/// Ohne begrenzte Höhe wird die Liste vollständig untereinander gezeichnet.
///
/// Die Liste springt nie von selbst: Wird eine Zeile zum Bearbeiten
/// ausgewählt ([ausgewaehlt]), bleibt sie an ihrer Stelle und wird markiert.
class SvgListe extends StatefulWidget {
  const SvgListe({
    super.key,
    required this.spalten,
    required this.anzahl,
    required this.zelle,
    this.sortSpalte,
    this.aufsteigend = true,
    this.beiSortieren,
    this.ausgewaehlt,
    this.zeilenFarbe,
    this.beiTippen,
    this.sonderZeile,
    this.unterKopf,
    this.fuss,
    this.leerText = 'Keine Einträge vorhanden.',
  });

  final List<SvgListenSpalte> spalten;
  final int anzahl;

  /// Inhalt der Zelle (Zeile, Spalte).
  final Widget Function(int zeile, int spalte) zelle;

  final int? sortSpalte;
  final bool aufsteigend;
  final void Function(int spalte, bool aufsteigend)? beiSortieren;

  /// Markierte Zeile (z. B. die gerade bearbeitete).
  final int? ausgewaehlt;
  final Color? Function(int zeile)? zeilenFarbe;
  final void Function(int zeile)? beiTippen;

  /// Ersetzt eine ganze Zeile (Zwischenüberschrift, Summe). `null` = normal.
  final Widget? Function(int zeile, List<double> breiten)? sonderZeile;

  /// Fest unter dem Kopf, z. B. eine Bearbeitungsleiste mit Feldern in
  /// derselben Reihenfolge wie die Spalten (siehe [SvgListenZeile]).
  final Widget? Function(List<double> breiten)? unterKopf;

  /// Fest unter den Zeilen, z. B. eine Summenzeile.
  final Widget? Function(List<double> breiten)? fuss;

  final String leerText;

  @override
  State<SvgListe> createState() => _SvgListeState();
}

class _SvgListeState extends State<SvgListe> {
  final _senkrecht = ScrollController();
  final _waagerecht = ScrollController();

  @override
  void dispose() {
    _senkrecht.dispose();
    _waagerecht.dispose();
    super.dispose();
  }

  List<double> _breiten(double verfuegbar) {
    final s = widget.spalten;
    final mindest = s.fold<double>(0, (a, b) => a + b.breite);
    final rest = verfuegbar > mindest ? verfuegbar - mindest : 0.0;
    final flexSumme = s.fold<int>(0, (a, b) => a + b.flex);
    return [
      for (final sp in s)
        sp.breite + (flexSumme == 0 ? 0 : rest * sp.flex / flexSumme)
    ];
  }

  Widget _kopf(List<double> breiten) {
    final w = widget;
    return Container(
      decoration: const BoxDecoration(
        color: SvgFarben.tabellenKopf,
        border: Border(bottom: BorderSide(color: SvgFarben.rahmen)),
      ),
      child: Row(children: [
        for (var i = 0; i < w.spalten.length; i++)
          SizedBox(
            width: breiten[i],
            child: _KopfZelle(
              spalte: w.spalten[i],
              sortiert: w.sortSpalte == i,
              aufsteigend: w.aufsteigend,
              beiTippen: (w.spalten[i].sortierbar && w.beiSortieren != null)
                  ? () => w.beiSortieren!(
                      i, w.sortSpalte == i ? !w.aufsteigend : true)
                  : null,
            ),
          ),
      ]),
    );
  }

  Widget _zeile(int i, List<double> breiten) {
    final w = widget;
    final sonder = w.sonderZeile?.call(i, breiten);
    if (sonder != null) return sonder;
    final farbe = i == w.ausgewaehlt
        ? SvgFarben.blauZart
        : (w.zeilenFarbe?.call(i) ?? Colors.white);
    return Material(
      color: farbe,
      child: InkWell(
        onTap: w.beiTippen == null ? null : () => w.beiTippen!(i),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          // Markierte Zeile zusätzlich mit blauem Streifen links
          decoration: BoxDecoration(
            border: Border(
              bottom: const BorderSide(color: SvgFarben.rahmen),
              left: i == w.ausgewaehlt
                  ? const BorderSide(color: SvgFarben.blau, width: 3)
                  : BorderSide.none,
            ),
          ),
          child: Row(children: [
            for (var s = 0; s < w.spalten.length; s++)
              SizedBox(
                width: breiten[s],
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Align(
                    alignment: w.spalten[s].zahl
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(color: SvgFarben.text),
                      child: w.zelle(i, s),
                    ),
                  ),
                ),
              ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: SvgFarben.rahmen),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(builder: (context, grenzen) {
        final mindest = w.spalten.fold<double>(0, (a, b) => a + b.breite);
        final breite = grenzen.hasBoundedWidth && grenzen.maxWidth > mindest
            ? grenzen.maxWidth
            : mindest;
        final breiten = _breiten(breite);
        final unter = w.unterKopf?.call(breiten);
        final fuss = w.fuss?.call(breiten);
        final leer = Padding(
          padding: const EdgeInsets.all(24),
          child: Text(w.leerText,
              style: const TextStyle(color: SvgFarben.textGedaempft)),
        );

        final Widget inhalt;
        if (grenzen.hasBoundedHeight) {
          inhalt = SizedBox(
            width: breite,
            height: grenzen.maxHeight,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _kopf(breiten),
              if (unter != null) unter,
              Expanded(
                child: w.anzahl == 0
                    ? Align(alignment: Alignment.topLeft, child: leer)
                    : Scrollbar(
                        controller: _senkrecht,
                        thumbVisibility: true,
                        child: ListView.builder(
                          controller: _senkrecht,
                          primary: false,
                          itemCount: w.anzahl,
                          itemBuilder: (c, i) => _zeile(i, breiten),
                        ),
                      ),
              ),
              if (fuss != null) fuss,
            ]),
          );
        } else {
          inhalt = SizedBox(
            width: breite,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _kopf(breiten),
              if (unter != null) unter,
              if (w.anzahl == 0) leer,
              for (var i = 0; i < w.anzahl; i++) _zeile(i, breiten),
              if (fuss != null) fuss,
            ]),
          );
        }
        if (breite <= (grenzen.hasBoundedWidth ? grenzen.maxWidth : breite)) {
          return inhalt;
        }
        return Scrollbar(
          controller: _waagerecht,
          child: SingleChildScrollView(
            controller: _waagerecht,
            scrollDirection: Axis.horizontal,
            child: inhalt,
          ),
        );
      }),
    );
  }
}

class _KopfZelle extends StatelessWidget {
  const _KopfZelle({
    required this.spalte,
    required this.sortiert,
    required this.aufsteigend,
    this.beiTippen,
  });

  final SvgListenSpalte spalte;
  final bool sortiert;
  final bool aufsteigend;
  final VoidCallback? beiTippen;

  @override
  Widget build(BuildContext context) {
    final text = Text(spalte.titel,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
            fontWeight: FontWeight.w600, color: SvgFarben.text));
    // Pfeil direkt neben dem Text, nicht am Spaltenrand
    final pfeil = Icon(
        aufsteigend ? Icons.arrow_upward : Icons.arrow_downward,
        size: 16,
        color: sortiert ? SvgFarben.blau : Colors.transparent);
    return InkWell(
      onTap: beiTippen,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          mainAxisAlignment:
              spalte.zahl ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(child: text),
            if (beiTippen != null) ...[const SizedBox(width: 4), pfeil],
          ],
        ),
      ),
    );
  }
}

/// Zeile mit denselben Spaltenbreiten wie die Liste – für Bearbeitungsleiste,
/// Zwischenüberschrift oder Summenzeile.
class SvgListenZeile extends StatelessWidget {
  const SvgListenZeile({
    super.key,
    required this.breiten,
    required this.kinder,
    this.farbe,
    this.fett = false,
    this.rechts = const {},
    this.vertikal = 6,
  });

  final List<double> breiten;

  /// Je Spalte ein Widget (fehlende Spalten bleiben leer).
  final List<Widget?> kinder;
  final Color? farbe;
  final bool fett;

  /// Spalten, die rechtsbündig stehen.
  final Set<int> rechts;
  final double vertikal;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
          color: farbe,
          border: const Border(bottom: BorderSide(color: SvgFarben.rahmen))),
      child: Row(children: [
          for (var i = 0; i < breiten.length; i++)
            SizedBox(
              width: breiten[i],
              child: Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: vertikal),
                child: Align(
                  alignment:
                      rechts.contains(i) ? Alignment.centerRight : Alignment.centerLeft,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                        color: SvgFarben.text,
                        fontWeight: fett ? FontWeight.w700 : null),
                    child: i < kinder.length
                        ? (kinder[i] ?? const SizedBox.shrink())
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
        ]),
    );
  }
}

/// Seite mit festem Kopfbereich (Überschrift, Filter, Formular) und einer
/// Liste, die den restlichen Platz füllt. Nur die Zeilen der Liste scrollen.
///
/// Ist das Fenster sehr niedrig, scrollt der Kopfbereich für sich (höchstens
/// 60 % der Höhe), damit für die Liste immer Platz bleibt.
class SvgListenSeite extends StatelessWidget {
  const SvgListenSeite({
    super.key,
    required this.kopf,
    required this.liste,
    this.rand = const EdgeInsets.all(24),
    this.abstand = 16,
  });

  final Widget kopf;
  final Widget liste;
  final EdgeInsets rand;
  final double abstand;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: rand,
      child: LayoutBuilder(builder: (context, grenzen) {
        if (!grenzen.hasBoundedHeight) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            kopf,
            SizedBox(height: abstand),
            SizedBox(height: 520, child: liste),
          ]);
        }
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxHeight: grenzen.maxHeight * 0.6),
            child: SingleChildScrollView(child: kopf),
          ),
          SizedBox(height: abstand),
          Expanded(child: liste),
        ]);
      }),
    );
  }
}
