import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'farben.dart';

// Meldungen wie in der Kleingartenverwaltung (zeigeSnackBar):
// • Fehler und Hinweise, bei denen etwas zu tun ist → Hinweisfenster in der
//   Mitte, bleibt stehen bis „OK“ (auch über offenen Dialogen).
// • Bestätigungen („gespeichert“, „importiert“) → gut sichtbare Leiste oben im
//   bearbeiteten Bereich mit Haken, verschwindet nach einigen Sekunden.
// Damit wird nichts mehr am unteren Rand verdeckt.

OverlayEntry? _aktuelleMeldung;
Timer? _meldungsTimer;

String _meldungsText(Widget w) {
  if (w is Text) return w.data ?? w.textSpan?.toPlainText() ?? '';
  if (w is SelectableText) return w.data ?? '';
  return '';
}

final RegExp _fehlerMuster = RegExp(
  r'(fehl|nicht |nicht$|konnte|ungültig|falsch|fehler|bitte|keine |kein |unbekannt|abgebrochen|blockiert|bereits vergeben|bereits vorhanden|maximal|achtung|zuerst|exception|error|keine schreibrechte)',
  caseSensitive: false,
);

/// Ersetzt `ScaffoldMessenger.of(context).showSnackBar(bar)`.
/// [istFehler] erzwingt die Art; sonst wird sie am Text erkannt.
void zeigeSnackBar(BuildContext context, SnackBar bar, {bool? istFehler}) {
  if (!context.mounted) return;
  final text = _meldungsText(bar.content);
  final fehler = istFehler ?? (text.isNotEmpty && _fehlerMuster.hasMatch(text));
  final aktion = bar.action;

  if (fehler) {
    final nav = Navigator.maybeOf(context, rootNavigator: true);
    if (nav == null) return;
    // Erst nach dem aktuellen Ablauf öffnen – falls der Aufrufer gleich danach
    // einen Dialog schließt, darf er nicht versehentlich diese Meldung schließen.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!nav.mounted) return;
      showDialog<void>(
        context: nav.context,
        barrierColor: Colors.black54,
        builder: (d) => AlertDialog(
          backgroundColor: const Color(0xFFFFF3E0),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: SvgFarben.warnungOrange, width: 2),
          ),
          icon: const Icon(Icons.warning_amber_rounded,
              color: SvgFarben.warnungOrange, size: 40),
          title: const Text('Hinweis',
              style: TextStyle(
                  color: Color(0xFFBF360C), fontWeight: FontWeight.bold)),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: text.isNotEmpty
                ? SelectableText(text,
                    style: const TextStyle(fontSize: 15, height: 1.4))
                : bar.content,
          ),
          actions: [
            if (aktion != null)
              TextButton(
                onPressed: () {
                  Navigator.of(d).pop();
                  aktion.onPressed();
                },
                child: Text(aktion.label),
              ),
            FilledButton(
                autofocus: true,
                onPressed: () => Navigator.of(d).pop(),
                child: const Text('OK')),
          ],
        ),
      );
    });
    return;
  }

  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  _meldungsTimer?.cancel();
  _aktuelleMeldung?.remove();
  _aktuelleMeldung = null;

  final overlayBox = overlay.context.findRenderObject() as RenderBox?;
  final gesamt = overlayBox?.size ?? MediaQuery.sizeOf(context);
  Rect bereich = Offset.zero & gesamt;
  try {
    final box = context.findRenderObject();
    if (box is RenderBox && box.hasSize && overlayBox != null) {
      final oben = box.localToGlobal(Offset.zero, ancestor: overlayBox);
      bereich = (oben & box.size).intersect(Offset.zero & gesamt);
      if (bereich.width < 200 || bereich.height < 80) {
        bereich = Offset.zero & gesamt;
      }
    }
  } catch (_) {}

  final breite = min(560.0, bereich.width - 32);
  final links = bereich.left + (bereich.width - breite) / 2;
  final top = bereich.top + 16;

  late final OverlayEntry eintrag;
  void schliessen() {
    if (_aktuelleMeldung == eintrag) {
      eintrag.remove();
      _aktuelleMeldung = null;
    }
  }

  eintrag = OverlayEntry(
    builder: (_) => Positioned(
      left: links,
      width: breite,
      top: top,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 200),
        builder: (_, wert, kind) => Opacity(
            opacity: wert,
            child: Transform.translate(
                offset: Offset(0, (1 - wert) * -12), child: kind)),
        child: Material(
          color: Colors.white,
          elevation: 10,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: schliessen,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: const Border(
                    left: BorderSide(color: SvgFarben.erfolg, width: 5)),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle,
                    color: SvgFarben.erfolg, size: 26),
                const SizedBox(width: 12),
                Expanded(
                  child: DefaultTextStyle(
                    style: const TextStyle(
                        color: SvgFarben.text,
                        fontSize: 15,
                        fontWeight: FontWeight.w500),
                    child: bar.content,
                  ),
                ),
                if (aktion != null)
                  TextButton(
                    onPressed: () {
                      schliessen();
                      aktion.onPressed();
                    },
                    child: Text(aktion.label),
                  ),
                const Icon(Icons.close, size: 18, color: Colors.black38),
              ]),
            ),
          ),
        ),
      ),
    ),
  );
  _aktuelleMeldung = eintrag;
  overlay.insert(eintrag);
  // Mit Schaltfläche (z. B. „Öffnen“) etwas länger stehen lassen.
  final dauer = bar.duration == const Duration(milliseconds: 4000)
      ? Duration(seconds: aktion == null ? 5 : 8)
      : bar.duration;
  _meldungsTimer = Timer(dauer, schliessen);
}
