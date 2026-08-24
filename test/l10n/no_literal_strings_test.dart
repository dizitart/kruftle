// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Stops English creeping back into the UI.
///
/// Localisation rots one `Text('Done')` at a time, and nothing else catches it:
/// the app compiles, the tests pass, and the string is simply never translated.
/// This walks the UI source and fails on a user-visible literal.
///
/// It is a lint, not a parser — it reads the source as text and looks for the
/// handful of shapes that put a string on screen. That is enough to catch the
/// mistake actually being made (typing a literal instead of a key) without
/// pulling in the analyzer.
void main() {
  /// Strings that reach the screen but are deliberately not translated.
  ///
  /// Each one is here for a reason, not because translating it was awkward.
  const allowed = {
    'Kruftle', // A product name is the same in every language.
    'monospace', // Font family fallbacks.
    'SF Mono', 'Menlo', 'Monaco',
    'Cascadia Mono', 'Consolas', 'Courier New',
    'Ubuntu Mono', 'DejaVu Sans Mono',
    'English', 'Deutsch', 'Español', 'Français', 'Português', // endonyms —
    'Русский', '中文', '日本語', 'العربية', 'हिन्दी', // see languageName()
  };

  final sources = Directory('lib/src/ui')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  test('there is UI source to check', () => expect(sources, isNotEmpty));

  for (final file in sources) {
    test('${file.path} has no untranslated user-facing string', () {
      final offenders = <String>[];

      for (final (index, line) in file.readAsLinesSync().indexed) {
        final trimmed = line.trim();
        if (trimmed.startsWith('//') || trimmed.startsWith('///')) continue;

        for (final match in _userFacing.allMatches(line)) {
          final literal = match.group(2)!;

          // Not prose: punctuation, an em dash, a lone symbol, an
          // interpolation-only string, or something that reads as an
          // identifier rather than a sentence.
          if (allowed.contains(literal)) continue;
          if (!_looksLikeProse(literal)) continue;

          offenders.add('  line ${index + 1}: ${match.group(1)}(\'$literal\')');
        }
      }

      expect(
        offenders,
        isEmpty,
        reason:
            'these strings never reach a translator — move them to '
            'lib/l10n/app_en.arb and read them through L.of(context):\n'
            '${offenders.join('\n')}',
      );
    });
  }
}

/// The shapes that put a bare string in front of a user.
final _userFacing = RegExp(
  r'\b(Text|SelectableText|tooltip:|hintText:|labelText:|semanticLabel:)'
  r"""\s*\(?\s*'([^'$\\]*)'""",
);

/// True when a literal reads as something a person would want in their own
/// language: at least two letters, and either a space or an initial capital.
bool _looksLikeProse(String literal) {
  if (literal.length < 3) return false;
  if (!RegExp(r'[A-Za-z]{2}').hasMatch(literal)) return false;
  // A path, a command, or a code fragment is not prose.
  if (RegExp(r'^[a-z0-9_.\-/\\]+$').hasMatch(literal)) return false;
  return literal.contains(' ') || RegExp(r'^[A-Z]').hasMatch(literal);
}
