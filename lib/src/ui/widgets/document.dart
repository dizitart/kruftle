// SPDX-License-Identifier: GPL-3.0-or-later

import 'dart:async';
import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme.dart';

/// Renders the subset of Markdown the legal documents actually use:
/// `#`/`##`/`###` headings, paragraphs, `-` bullets, `**bold**`, `` `code` ``,
/// `[text](url)` links, bare URLs, and `---` rules.
///
/// **Not a Markdown library.** `flutter_markdown` was discontinued, and its
/// successors bring a parser, an HTML model and a syntax-highlighting
/// dependency to render two documents we write ourselves. This is the shape
/// of those documents, in a hundred lines, with no third party to audit. If a
/// document ever needs tables or images, that is the moment to reconsider —
/// not before.
class MarkdownDocument extends StatelessWidget {
  const MarkdownDocument(this.source, {super.key});

  final String source;

  @override
  Widget build(BuildContext context) {
    final blocks = <Widget>[];
    final buffer = StringBuffer();
    // Whether what is being accumulated is a bullet or a paragraph. A
    // hard-wrapped bullet's continuation lines look exactly like a paragraph,
    // so the only way to tell is to remember what started the run.
    var inBullet = false;

    void flush() {
      if (buffer.isEmpty) return;
      final text = buffer.toString().trim();
      blocks.add(inBullet ? _Bullet(text) : _Paragraph(text));
      buffer.clear();
      inBullet = false;
    }

    void append(String text) {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(text);
    }

    for (final line in const LineSplitter().convert(source)) {
      final trimmed = line.trim();

      if (trimmed.isEmpty) {
        flush();
        continue;
      }
      if (trimmed.startsWith('---')) {
        flush();
        blocks.add(const Divider(height: 34));
        continue;
      }
      if (trimmed.startsWith('#')) {
        flush();
        final level = trimmed.indexOf(' ');
        blocks.add(
          _Heading(
            text: trimmed.substring(level + 1),
            level: level.clamp(1, 3),
          ),
        );
        continue;
      }
      if (trimmed.startsWith('- ')) {
        flush();
        inBullet = true;
        append(trimmed.substring(2));
        continue;
      }

      // Anything else continues whatever is open — a bullet or a paragraph.
      // This is what lets the documents be written at 76 columns and still
      // reflow to the window without a wrapped bullet falling out of its own
      // bullet point.
      append(trimmed);
    }
    flush();

    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 20, 32, 60),
      children: [
        // Centred, not merely constrained: a ListView hands its children a
        // tight cross-axis width, which a bare ConstrainedBox cannot shrink
        // below. Without this the text runs the full width of the window and
        // becomes unreadable on a wide display.
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: blocks,
            ),
          ),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading({required this.text, required this.level});

  final String text;
  final int level;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: level == 1 ? 0 : 26, bottom: 10),
    child: _RichLine(
      text,
      style: TextStyle(
        fontSize: switch (level) {
          1 => 24,
          2 => 16,
          _ => 14,
        },
        height: 1.3,
        fontWeight: FontWeight.w700,
        letterSpacing: level == 1 ? -0.5 : -0.2,
        color: context.colors.onSurface,
      ),
    ),
  );
}

class _Paragraph extends StatelessWidget {
  const _Paragraph(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: _RichLine(
      text,
      style: TextStyle(
        fontSize: 13.5,
        height: 1.65,
        color: context.colors.onSurfaceVariant,
      ),
    ),
  );
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 6, bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7, right: 12),
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.onSurfaceVariant.withValues(alpha: 0.55),
            ),
          ),
        ),
        Expanded(
          child: _RichLine(
            text,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.6,
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    ),
  );
}

/// One line of text with the inline spans resolved.
class _RichLine extends StatefulWidget {
  const _RichLine(this.text, {required this.style});

  final String text;
  final TextStyle style;

  @override
  State<_RichLine> createState() => _RichLineState();
}

class _RichLineState extends State<_RichLine> {
  /// Recognisers have to outlive the build that created them, and be disposed
  /// with the widget — a leaked `TapGestureRecognizer` is a real leak, and
  /// Flutter asserts about it in debug.
  final _recognisers = <TapGestureRecognizer>[];

  @override
  void dispose() {
    for (final recogniser in _recognisers) {
      recogniser.dispose();
    }
    super.dispose();
  }

  /// `**bold**`, `` `code` ``, `[text](url)`, and bare `https://…`.
  static final _inline = RegExp(
    r'\*\*(.+?)\*\*'
    r'|`(.+?)`'
    r'|\[(.+?)\]\((\S+?)\)'
    r'|(https?://[^\s)]+)',
  );

  @override
  Widget build(BuildContext context) {
    for (final recogniser in _recognisers) {
      recogniser.dispose();
    }
    _recognisers.clear();

    final spans = <InlineSpan>[];
    var cursor = 0;

    for (final match in _inline.allMatches(widget.text)) {
      if (match.start > cursor) {
        spans.add(TextSpan(text: widget.text.substring(cursor, match.start)));
      }

      if (match.group(1) != null) {
        spans.add(
          TextSpan(
            text: match.group(1),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: context.colors.onSurface,
            ),
          ),
        );
      } else if (match.group(2) != null) {
        spans.add(
          TextSpan(
            text: match.group(2),
            style: context.mono(
              size: widget.style.fontSize! - 1,
              color: context.colors.onSurface,
            ),
          ),
        );
      } else {
        final label = match.group(3) ?? match.group(5)!;
        final url = match.group(4) ?? match.group(5)!;
        spans.add(
          TextSpan(
            text: label,
            style: _linkStyle(context),
            recognizer: _open(url),
          ),
        );
      }

      cursor = match.end;
    }
    if (cursor < widget.text.length) {
      spans.add(TextSpan(text: widget.text.substring(cursor)));
    }

    return SelectableText.rich(TextSpan(style: widget.style, children: spans));
  }

  TextStyle _linkStyle(BuildContext context) => TextStyle(
    color: context.colors.primary,
    decoration: TextDecoration.underline,
    decorationColor: context.colors.primary.withValues(alpha: 0.4),
  );

  TapGestureRecognizer _open(String url) {
    final recogniser = TapGestureRecognizer()
      ..onTap = () {
        final uri = Uri.tryParse(url);
        // Only ever http(s), and only ever in the user's own browser. A
        // document is data; a `file:` or `mailto:` scheme smuggled into one
        // is not something to hand to the shell.
        if (uri == null) return;
        if (uri.scheme != 'http' && uri.scheme != 'https') return;
        unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
      };
    _recognisers.add(recogniser);
    return recogniser;
  }
}
