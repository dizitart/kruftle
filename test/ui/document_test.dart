// SPDX-License-Identifier: GPL-3.0-or-later

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kruftle/src/ui/theme.dart';
import 'package:kruftle/src/ui/widgets/document.dart';

Future<void> pumpDocument(
  WidgetTester tester,
  String source, {
  double width = 1200,
}) async {
  tester.view.physicalSize = Size(width, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: KruftleTheme.dark(),
      home: Scaffold(body: MarkdownDocument(source)),
    ),
  );
  await tester.pump();
}

/// The text of every `SelectableText` on screen, in order.
List<String> linesOn(WidgetTester tester) => tester
    .widgetList<SelectableText>(find.byType(SelectableText))
    .map((t) => t.textSpan!.toPlainText())
    .toList();

void main() {
  testWidgets('a hard-wrapped paragraph is joined back together', (
    tester,
  ) async {
    // The documents are written at 76 columns; the reader's window is not.
    await pumpDocument(tester, '''
This is one paragraph that happens
to be written across three
source lines.
''');

    expect(linesOn(tester), [
      'This is one paragraph that happens to be written across three source '
          'lines.',
    ]);
  });

  testWidgets('a hard-wrapped bullet stays inside its own bullet', (
    tester,
  ) async {
    // The bug this exists for: continuation lines used to become separate
    // paragraphs, so half of every long bullet fell out from under its dot.
    await pumpDocument(tester, '''
- **Your name, email, or any other contact detail** — the App has no field
  for any of them, so there is nothing to send
- A short one
''');

    expect(linesOn(tester), [
      'Your name, email, or any other contact detail — the App has no field '
          'for any of them, so there is nothing to send',
      'A short one',
    ]);
  });

  testWidgets('a blank line ends a bullet', (tester) async {
    await pumpDocument(tester, '''
- A bullet

And a paragraph that follows it.
''');

    expect(linesOn(tester), ['A bullet', 'And a paragraph that follows it.']);
  });

  testWidgets('headings are separated from the text around them', (
    tester,
  ) async {
    await pumpDocument(tester, '''
# Title

Some words.

## A section

More words.
''');

    expect(linesOn(tester), [
      'Title',
      'Some words.',
      'A section',
      'More words.',
    ]);
  });

  testWidgets('a heading ends whatever was open', (tester) async {
    await pumpDocument(tester, '''
- A bullet with no blank line after it
## Straight into a heading
''');

    expect(linesOn(tester), [
      'A bullet with no blank line after it',
      'Straight into a heading',
    ]);
  });

  testWidgets('bold and code markers are removed from the rendered text', (
    tester,
  ) async {
    await pumpDocument(tester, 'Run **cargo** with `--release` set.');

    expect(linesOn(tester), ['Run cargo with --release set.']);
  });

  testWidgets('a link shows its label, not its URL', (tester) async {
    await pumpDocument(
      tester,
      'See [the repository](https://github.com/dizitart/kruftle) for more.',
    );

    expect(linesOn(tester), ['See the repository for more.']);
  });

  testWidgets('a bare URL is shown as itself', (tester) async {
    await pumpDocument(tester, 'Read https://example.invalid/policy for more.');

    expect(linesOn(tester), ['Read https://example.invalid/policy for more.']);
  });

  testWidgets('text does not run the full width of a wide window', (
    tester,
  ) async {
    // A legal document set across 1400 pixels is unreadable. `ListView` hands
    // its children a tight cross-axis width, so a bare `ConstrainedBox` is not
    // enough — this is the regression test for that.
    await pumpDocument(tester, 'A paragraph of text.', width: 1400);

    final rendered = tester.getSize(find.byType(SelectableText).first);
    expect(rendered.width, lessThanOrEqualTo(760));
  });

  testWidgets('an empty document renders nothing rather than throwing', (
    tester,
  ) async {
    await pumpDocument(tester, '');
    expect(find.byType(SelectableText), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a horizontal rule becomes a divider', (tester) async {
    await pumpDocument(tester, 'Above.\n\n---\n\nBelow.');
    expect(find.byType(Divider), findsOneWidget);
  });
}
